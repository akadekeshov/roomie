import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RefreshDto } from './dto/refresh.dto';
import { RegisterEmailDto } from './dto/register-email.dto';
import { RegisterPhoneDto } from './dto/register-phone.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { VerifyPhoneDto } from './dto/verify-phone.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { OTPChannel, OTPPurpose, UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
  private readonly OTP_EXPIRY_MINUTES = 5;
  private readonly OTP_COOLDOWN_SECONDS = 30;
  private readonly MAX_OTP_ATTEMPTS = 5;

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  private readonly authUserSelect = {
    id: true,
    email: true,
    phone: true,
    firstName: true,
    lastName: true,
    gender: true,
    age: true,
    city: true,
    bio: true,
    photos: true,
    verificationStatus: true,
    emailVerified: true,
    phoneVerified: true,
    onboardingStep: true,
    onboardingCompleted: true,
    createdAt: true,
    updatedAt: true,
  } as const;

  private isProduction(): boolean {
    return this.configService.get<string>('NODE_ENV') === 'production';
  }

  private normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }

  private normalizePhone(phone: string): string {
    return phone.trim();
  }

  private parseDurationToMs(duration: string): number {
    const match = /^(\d+)([mhd])$/.exec(duration.trim());
    if (!match) return 7 * 24 * 60 * 60 * 1000;

    const value = Number(match[1]);
    const unit = match[2];

    switch (unit) {
      case 'm':
        return value * 60 * 1000;
      case 'h':
        return value * 60 * 60 * 1000;
      case 'd':
        return value * 24 * 60 * 60 * 1000;
      default:
        return 7 * 24 * 60 * 60 * 1000;
    }
  }

  // Generate 6-digit OTP code
  private generateOtp(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Upsert OTP code and return plain code for logging
  private async upsertOtp(
    channel: OTPChannel,
    purpose: OTPPurpose,
    target: string,
  ): Promise<string> {
    const code = this.generateOtp();
    const codeHash = await bcrypt.hash(code, 10);

    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + this.OTP_EXPIRY_MINUTES);

    await this.prisma.otpCode.upsert({
      where: {
        channel_purpose_target: { channel, purpose, target },
      },
      create: {
        channel,
        purpose,
        target,
        codeHash,
        expiresAt,
        lastSentAt: new Date(),
        attempts: 0,
      },
      update: {
        codeHash,
        expiresAt,
        lastSentAt: new Date(),
        attempts: 0,
        consumedAt: null,
      },
    });

    return code;
  }

  // Validate OTP code
  private async validateOtp(
    channel: OTPChannel,
    purpose: OTPPurpose,
    target: string,
    code: string,
  ): Promise<void> {
    const otpRecord = await this.prisma.otpCode.findUnique({
      where: {
        channel_purpose_target: { channel, purpose, target },
      },
    });

    if (!otpRecord) throw new BadRequestException('Неверный код');
    if (otpRecord.consumedAt)
      throw new BadRequestException('Код уже использован');
    if (otpRecord.expiresAt < new Date())
      throw new BadRequestException('Срок действия кода истёк');
    if (otpRecord.attempts >= this.MAX_OTP_ATTEMPTS)
      throw new BadRequestException('Слишком много попыток');

    const isValid = await bcrypt.compare(code, otpRecord.codeHash);

    if (!isValid) {
      await this.prisma.otpCode.update({
        where: { id: otpRecord.id },
        data: { attempts: otpRecord.attempts + 1 },
      });
      throw new UnauthorizedException('Неверный код');
    }

    await this.prisma.otpCode.update({
      where: { id: otpRecord.id },
      data: { consumedAt: new Date() },
    });
  }

  private async buildAuthUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: this.authUserSelect,
    });

    if (!user) {
      throw new UnauthorizedException('Пользователь не найден');
    }

    return user;
  }

  // =========================
  // REGISTER (EMAIL)
  // =========================

  async registerEmail(registerEmailDto: RegisterEmailDto) {
    const email = this.normalizeEmail(registerEmailDto.email);
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    // existing and verified -> 409
    if (existingUser?.emailVerified) {
      throw new ConflictException('Почта уже зарегистрирована');
    }

    // existing but not verified -> resend OTP, do not create new user, do not change password
    if (existingUser && !existingUser.emailVerified) {
      const code = await this.upsertOtp(
        OTPChannel.EMAIL,
        OTPPurpose.REGISTER,
        email,
      );

      if (process.env.OTP_DEV_LOG === 'true') {
        // eslint-disable-next-line no-console
        console.log(`[OTP EMAIL] ${email}: ${code}`);
      }

      return { next: 'VERIFY_EMAIL', alreadyExists: true };
    }

    // new user
    const hashedPassword = await bcrypt.hash(registerEmailDto.password, 10);

    await this.prisma.user.create({
      data: {
        role: UserRole.USER,
        email,
        phone: null,
        password: hashedPassword,
        emailVerified: false,
        phoneVerified: false,
        firstName: null,
        lastName: null,
        onboardingStep: 'NAME_AGE',
        onboardingCompleted: false,
      },
    });

    const code = await this.upsertOtp(
      OTPChannel.EMAIL,
      OTPPurpose.REGISTER,
      email,
    );

    if (process.env.OTP_DEV_LOG === 'true') {
      // eslint-disable-next-line no-console
      console.log(`[OTP EMAIL] ${email}: ${code}`);
    }

    return { next: 'VERIFY_EMAIL', alreadyExists: false };
  }

  async verifyEmail(verifyEmailDto: VerifyEmailDto) {
    const email = this.normalizeEmail(verifyEmailDto.email);
    await this.validateOtp(
      OTPChannel.EMAIL,
      OTPPurpose.REGISTER,
      email,
      verifyEmailDto.code,
    );

    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) throw new BadRequestException('Пользователь не найден');

    await this.prisma.user.update({
      where: { id: user.id },
      data: { emailVerified: true },
    });
    const updatedUser = await this.buildAuthUser(user.id);

    const tokens = await this.generateTokens(
      user.id,
      user.email || undefined,
      user.phone || undefined,
    );

    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: updatedUser,
    };
  }

  // =========================
  // REGISTER (PHONE)
  // =========================

  async registerPhone(registerPhoneDto: RegisterPhoneDto) {
    const phone = this.normalizePhone(registerPhoneDto.phone);
    const existingUser = await this.prisma.user.findUnique({
      where: { phone },
    });

    // existing and verified -> 409
    if (existingUser?.phoneVerified) {
      throw new ConflictException('Телефон уже зарегистрирован');
    }

    // existing but not verified -> resend OTP
    if (existingUser && !existingUser.phoneVerified) {
      const code = await this.upsertOtp(
        OTPChannel.PHONE,
        OTPPurpose.REGISTER,
        phone,
      );

      if (process.env.OTP_DEV_LOG === 'true') {
        // eslint-disable-next-line no-console
        console.log(`[OTP SMS] ${phone}: ${code}`);
      }

      return { next: 'VERIFY_PHONE', alreadyExists: true };
    }

    // new user
    const hashedPassword = await bcrypt.hash(registerPhoneDto.password, 10);

    await this.prisma.user.create({
      data: {
        role: UserRole.USER,
        email: null,
        phone,
        password: hashedPassword,
        emailVerified: false,
        phoneVerified: false,
        firstName: null,
        lastName: null,
        onboardingStep: 'NAME_AGE',
        onboardingCompleted: false,
      },
    });

    const code = await this.upsertOtp(
      OTPChannel.PHONE,
      OTPPurpose.REGISTER,
      phone,
    );

    if (process.env.OTP_DEV_LOG === 'true') {
      // eslint-disable-next-line no-console
      console.log(`[OTP SMS] ${phone}: ${code}`);
    }

    return { next: 'VERIFY_PHONE', alreadyExists: false };
  }

  async verifyPhone(verifyPhoneDto: VerifyPhoneDto) {
    const phone = this.normalizePhone(verifyPhoneDto.phone);
    await this.validateOtp(
      OTPChannel.PHONE,
      OTPPurpose.REGISTER,
      phone,
      verifyPhoneDto.code,
    );

    const user = await this.prisma.user.findUnique({
      where: { phone },
    });

    if (!user) throw new BadRequestException('Пользователь не найден');

    await this.prisma.user.update({
      where: { id: user.id },
      data: { phoneVerified: true },
    });
    const updatedUser = await this.buildAuthUser(user.id);

    const tokens = await this.generateTokens(
      user.id,
      user.email || undefined,
      user.phone || undefined,
    );

    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: updatedUser,
    };
  }

  // =========================
  // RESEND OTP
  // =========================

  async resendOtp(resendOtpDto: ResendOtpDto) {
    const normalizedTarget =
      resendOtpDto.channel === OTPChannel.EMAIL
        ? this.normalizeEmail(resendOtpDto.target)
        : this.normalizePhone(resendOtpDto.target);

    if (resendOtpDto.purpose === OTPPurpose.REGISTER) {
      const user =
        resendOtpDto.channel === OTPChannel.EMAIL
          ? await this.prisma.user.findUnique({
              where: { email: normalizedTarget },
              select: {
                id: true,
                emailVerified: true,
                phoneVerified: true,
                isBanned: true,
              },
            })
          : await this.prisma.user.findUnique({
              where: { phone: normalizedTarget },
              select: {
                id: true,
                emailVerified: true,
                phoneVerified: true,
                isBanned: true,
              },
            });
      if (!user) {
        throw new NotFoundException(
          'Пользователь не найден, пожалуйста, зарегистрируйтесь',
        );
      }
      if (user.isBanned) {
        throw new ForbiddenException('Аккаунт заблокирован');
      }
      if (
        (resendOtpDto.channel === OTPChannel.EMAIL && user.emailVerified) ||
        (resendOtpDto.channel === OTPChannel.PHONE && user.phoneVerified)
      ) {
        throw new ConflictException(
          'Пользователь уже подтверждён, пожалуйста, войдите',
        );
      }
    }

    const otpRecord = await this.prisma.otpCode.findUnique({
      where: {
        channel_purpose_target: {
          channel: resendOtpDto.channel,
          purpose: resendOtpDto.purpose,
          target: normalizedTarget,
        },
      },
    });

    if (otpRecord) {
      const now = new Date();
      const timeSinceLastSent =
        (now.getTime() - otpRecord.lastSentAt.getTime()) / 1000;

      if (timeSinceLastSent < this.OTP_COOLDOWN_SECONDS) {
        throw new HttpException(
          'Пожалуйста, подождите перед повторным запросом кода',
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
    }

    const code = await this.upsertOtp(
      resendOtpDto.channel,
      resendOtpDto.purpose,
      normalizedTarget,
    );

    if (process.env.OTP_DEV_LOG === 'true') {
      // eslint-disable-next-line no-console
      if (resendOtpDto.channel === OTPChannel.EMAIL) {
        console.log(`[OTP EMAIL] ${normalizedTarget}: ${code}`);
      } else {
        console.log(`[OTP SMS] ${normalizedTarget}: ${code}`);
      }
    }

    if (resendOtpDto.channel === OTPChannel.EMAIL) {
      return { next: 'VERIFY_EMAIL' };
    }

    return { next: 'VERIFY_PHONE' };
  }

  // =========================
  // LOGIN / REFRESH / LOGOUT / ME
  // =========================

  async login(loginDto: LoginDto) {
    if (!loginDto.email && !loginDto.phone) {
      throw new BadRequestException(
        'Нужно указать почту или телефон для входа',
      );
    }

    if (loginDto.email && loginDto.phone) {
      throw new BadRequestException(
        'Нужно указать только один способ входа: почту или телефон',
      );
    }

    const normalizedEmail = loginDto.email
      ? this.normalizeEmail(loginDto.email)
      : undefined;
    const normalizedPhone = loginDto.phone
      ? this.normalizePhone(loginDto.phone)
      : undefined;

    const user = normalizedEmail
      ? await this.prisma.user.findUnique({ where: { email: normalizedEmail } })
      : await this.prisma.user.findUnique({ where: { phone: normalizedPhone } });

    if (!user) {
      throw new NotFoundException(
        'Пользователь не найден, пожалуйста, зарегистрируйтесь',
      );
    }
    if (user.isBanned) throw new ForbiddenException('Аккаунт заблокирован');

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    if (!isPasswordValid)
      throw new UnauthorizedException('Неверные данные для входа');

    if (loginDto.email && !user.emailVerified) {
      throw new UnauthorizedException('Почта не подтверждена');
    }
    if (loginDto.phone && !user.phoneVerified) {
      throw new UnauthorizedException('Телефон не подтверждён');
    }

    const tokens = await this.generateTokens(
      user.id,
      user.email || undefined,
      user.phone || undefined,
    );

    return {
      user: await this.buildAuthUser(user.id),
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    };
  }

  async refresh(refreshDto: RefreshDto) {
    const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET')!;

    let payload: any;
    try {
      payload = this.jwtService.verify(refreshDto.refreshToken, {
        secret: refreshSecret,
      });
    } catch {
      throw new UnauthorizedException('Неверный refresh token');
    }

    const tokenRecord = await this.prisma.refreshToken.findUnique({
      where: { token: refreshDto.refreshToken },
      include: { user: true },
    });

    if (!tokenRecord)
      throw new UnauthorizedException('Неверный refresh token');

    if (tokenRecord.expiresAt < new Date()) {
      await this.prisma.refreshToken
        .delete({ where: { token: refreshDto.refreshToken } })
        .catch(() => {});
      throw new UnauthorizedException(
        'Refresh token недействителен или истёк',
      );
    }

    if (tokenRecord.userId !== payload.sub) {
      throw new UnauthorizedException('Неверный refresh token');
    }
    if (tokenRecord.user.isBanned) {
      throw new ForbiddenException('Аккаунт заблокирован');
    }

    const tokens = await this.generateTokens(
      tokenRecord.userId,
      tokenRecord.user.email || undefined,
      tokenRecord.user.phone || undefined,
    );

    return {
      ...tokens,
      user: await this.buildAuthUser(tokenRecord.userId),
    };
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      await this.prisma.refreshToken.deleteMany({
        where: { userId, token: refreshToken },
      });
    } else {
      await this.prisma.refreshToken.deleteMany({
        where: { userId },
      });
    }

    return { message: 'Выход выполнен успешно' };
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        role: true,
        isBanned: true,
        ...this.authUserSelect,
      },
    });

    if (!user) throw new UnauthorizedException('Пользователь не найден');
    return user;
  }

  private async generateTokens(userId: string, email?: string, phone?: string) {
    const payload = { sub: userId, email: email || null, phone: phone || null };

    const accessSecret = this.configService.get<string>('JWT_ACCESS_SECRET')!;
    const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET')!;

    const accessTtl = this.configService.get<string>('ACCESS_TOKEN_TTL') ?? '15m';
    const refreshTtl = this.configService.get<string>('REFRESH_TOKEN_TTL') ?? '7d';

    const accessToken = this.jwtService.sign(payload as any, {
      secret: accessSecret,
      expiresIn: accessTtl as any,
    });

    const refreshToken = this.jwtService.sign(payload as any, {
      secret: refreshSecret,
      expiresIn: refreshTtl as any,
    });

    await this.prisma.refreshToken.deleteMany({ where: { userId } });

    const expiresAt = new Date(Date.now() + this.parseDurationToMs(refreshTtl));

    await this.prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId,
        expiresAt,
      },
    });

    return { accessToken, refreshToken };
  }
}
