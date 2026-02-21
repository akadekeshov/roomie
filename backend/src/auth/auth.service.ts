import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
  HttpException,
  HttpStatus,
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
import { OTPChannel, OTPPurpose } from '@prisma/client';

@Injectable()
export class AuthService {
  private readonly OTP_EXPIRY_MINUTES = 5;
  private readonly OTP_COOLDOWN_SECONDS = 30;
  private readonly MAX_OTP_ATTEMPTS = 5;

  private isProduction(): boolean {
    return this.configService.get<string>('NODE_ENV') === 'production';
  }

  private parseDurationToMs(duration: string): number {
    const match = /^(\d+)([mhd])$/.exec(duration.trim());
    if (!match) {
      return 7 * 24 * 60 * 60 * 1000;
    }
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

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

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
        channel_purpose_target: {
          channel,
          purpose,
          target,
        },
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
        channel_purpose_target: {
          channel,
          purpose,
          target,
        },
      },
    });

    if (!otpRecord) {
      throw new BadRequestException('Invalid code');
    }

    if (otpRecord.consumedAt) {
      throw new BadRequestException('Code already used');
    }

    if (otpRecord.expiresAt < new Date()) {
      throw new BadRequestException('Code expired');
    }

    if (otpRecord.attempts >= this.MAX_OTP_ATTEMPTS) {
      throw new BadRequestException('Too many attempts');
    }

    const isValid = await bcrypt.compare(code, otpRecord.codeHash);

    if (!isValid) {
      await this.prisma.otpCode.update({
        where: { id: otpRecord.id },
        data: { attempts: otpRecord.attempts + 1 },
      });
      throw new UnauthorizedException('Invalid code');
    }

    // Mark as consumed
    await this.prisma.otpCode.update({
      where: { id: otpRecord.id },
      data: { consumedAt: new Date() },
    });
  }

  async registerEmail(registerEmailDto: RegisterEmailDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: registerEmailDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    const hashedPassword = await bcrypt.hash(registerEmailDto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        email: registerEmailDto.email,
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
      registerEmailDto.email,
    );

    if (!this.isProduction()) {
      console.log(`[OTP EMAIL] ${registerEmailDto.email}: ${code}`);
    }

    return { next: 'VERIFY_EMAIL' };
  }

  async verifyEmail(verifyEmailDto: VerifyEmailDto) {
    await this.validateOtp(
      OTPChannel.EMAIL,
      OTPPurpose.REGISTER,
      verifyEmailDto.email,
      verifyEmailDto.code,
    );

    const user = await this.prisma.user.findUnique({
      where: { email: verifyEmailDto.email },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: user.id },
      data: { emailVerified: true },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        gender: true,
        age: true,
        city: true,
        bio: true,
        emailVerified: true,
        phoneVerified: true,
        onboardingStep: true,
        onboardingCompleted: true,
        createdAt: true,
      },
    });

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

  async registerPhone(registerPhoneDto: RegisterPhoneDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { phone: registerPhoneDto.phone },
    });

    if (existingUser) {
      throw new ConflictException('Phone already registered');
    }

    const hashedPassword = await bcrypt.hash(registerPhoneDto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        email: null,
        phone: registerPhoneDto.phone,
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
      registerPhoneDto.phone,
    );

    if (!this.isProduction()) {
      console.log(`[OTP SMS] ${registerPhoneDto.phone}: ${code}`);
    }

    return { next: 'VERIFY_PHONE' };
  }

  async verifyPhone(verifyPhoneDto: VerifyPhoneDto) {
    await this.validateOtp(
      OTPChannel.PHONE,
      OTPPurpose.REGISTER,
      verifyPhoneDto.phone,
      verifyPhoneDto.code,
    );

    const user = await this.prisma.user.findUnique({
      where: { phone: verifyPhoneDto.phone },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: user.id },
      data: { phoneVerified: true },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        gender: true,
        age: true,
        city: true,
        bio: true,
        emailVerified: true,
        phoneVerified: true,
        onboardingStep: true,
        onboardingCompleted: true,
        createdAt: true,
      },
    });

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

  async resendOtp(resendOtpDto: ResendOtpDto) {
    const otpRecord = await this.prisma.otpCode.findUnique({
      where: {
        channel_purpose_target: {
          channel: resendOtpDto.channel,
          purpose: resendOtpDto.purpose,
          target: resendOtpDto.target,
        },
      },
    });

    if (otpRecord) {
      const now = new Date();
      const timeSinceLastSent =
        (now.getTime() - otpRecord.lastSentAt.getTime()) / 1000;

      if (timeSinceLastSent < this.OTP_COOLDOWN_SECONDS) {
        throw new HttpException(
          'Please wait before requesting a new code',
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
    }

    const code = await this.upsertOtp(
      resendOtpDto.channel,
      resendOtpDto.purpose,
      resendOtpDto.target,
    );

    if (resendOtpDto.channel === OTPChannel.EMAIL) {
      if (!this.isProduction()) {
        console.log(`[OTP EMAIL] ${resendOtpDto.target}: ${code}`);
      }
      return { next: 'VERIFY_EMAIL' };
    } else {
      if (!this.isProduction()) {
        console.log(`[OTP SMS] ${resendOtpDto.target}: ${code}`);
      }
      return { next: 'VERIFY_PHONE' };
    }
  }

  async login(loginDto: LoginDto) {
    if (!loginDto.email && !loginDto.phone) {
      throw new BadRequestException('Either email or phone must be provided');
    }

    if (loginDto.email && loginDto.phone) {
      throw new BadRequestException(
        'Only one of email or phone should be provided',
      );
    }

    const user = loginDto.email
      ? await this.prisma.user.findUnique({
          where: { email: loginDto.email },
        })
      : await this.prisma.user.findUnique({
          where: { phone: loginDto.phone },
        });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.password,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check verification status
    if (loginDto.email && !user.emailVerified) {
      throw new UnauthorizedException('Email not verified');
    }

    if (loginDto.phone && !user.phoneVerified) {
      throw new UnauthorizedException('Phone not verified');
    }

    const tokens = await this.generateTokens(
      user.id,
      user.email || undefined,
      user.phone || undefined,
    );

    return {
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        firstName: user.firstName,
        lastName: user.lastName,
        gender: user.gender,
        age: user.age,
        city: user.city,
        bio: user.bio,
        emailVerified: user.emailVerified,
        phoneVerified: user.phoneVerified,
        onboardingStep: user.onboardingStep,
        onboardingCompleted: user.onboardingCompleted,
        createdAt: user.createdAt,
      },
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
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokenRecord = await this.prisma.refreshToken.findUnique({
      where: { token: refreshDto.refreshToken },
      include: { user: true },
    });

    if (!tokenRecord) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (tokenRecord.expiresAt < new Date()) {
      await this.prisma.refreshToken
        .delete({ where: { token: refreshDto.refreshToken } })
        .catch(() => {});
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    if (tokenRecord.userId !== payload.sub) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokens = await this.generateTokens(
      tokenRecord.userId,
      tokenRecord.user.email || undefined,
      tokenRecord.user.phone || undefined,
    );

    return tokens;
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

    return { message: 'Logged out successfully' };
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        gender: true,
        age: true,
        city: true,
        bio: true,
        emailVerified: true,
        phoneVerified: true,
        onboardingStep: true,
        onboardingCompleted: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return user;
  }

  private async generateTokens(userId: string, email?: string, phone?: string) {
    const payload = { sub: userId, email: email || null, phone: phone || null };

    const accessSecret = this.configService.get<string>('JWT_ACCESS_SECRET')!;
    const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET')!;

    const accessTtl =
      this.configService.get<string>('ACCESS_TOKEN_TTL') ?? '15m';
    const refreshTtl =
      this.configService.get<string>('REFRESH_TOKEN_TTL') ?? '7d';

    const accessToken = this.jwtService.sign(payload as any, {
      secret: accessSecret,
      expiresIn: accessTtl as any,
    });

    const refreshToken = this.jwtService.sign(payload as any, {
      secret: refreshSecret,
      expiresIn: refreshTtl as any,
    });

    // Delete old refresh tokens
    await this.prisma.refreshToken.deleteMany({
      where: { userId },
    });

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
