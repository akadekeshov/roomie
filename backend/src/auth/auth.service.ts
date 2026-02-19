import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshDto } from './dto/refresh.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    // В твоей схеме User.password — это hash
    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        email: registerDto.email,
        password: hashedPassword,
        firstName: registerDto.firstName,
        lastName: registerDto.lastName,
        gender: registerDto.gender,
        age: registerDto.age,
        bio: registerDto.bio,
      },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        gender: true,
        age: true,
        bio: true,
        createdAt: true,
      },
    });

    const tokens = await this.generateTokens(user.id, user.email);

    return { user, ...tokens };
  }

  async login(loginDto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: loginDto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const tokens = await this.generateTokens(user.id, user.email);

    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        gender: user.gender,
        age: user.age,
        bio: user.bio,
        createdAt: user.createdAt,
      },
      ...tokens,
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

    // В твоей схеме RefreshToken.token хранится как plain и unique
    const tokenRecord = await this.prisma.refreshToken.findUnique({
      where: { token: refreshDto.refreshToken },
      include: { user: true },
    });

    if (!tokenRecord) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (tokenRecord.expiresAt < new Date()) {
      // можно подчистить
      await this.prisma.refreshToken.delete({ where: { token: refreshDto.refreshToken } }).catch(() => {});
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    if (tokenRecord.userId !== payload.sub) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    // 1 активный токен: при генерации новый токен удалит старые
    const tokens = await this.generateTokens(tokenRecord.userId, tokenRecord.user.email);

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
        firstName: true,
        lastName: true,
        gender: true,
        age: true,
        bio: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return user;
  }

  private async generateTokens(userId: string, email: string) {
    const payload = { sub: userId, email };

    const accessSecret = this.configService.get<string>('JWT_ACCESS_SECRET')!;
    const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET')!;

    const accessTtl = this.configService.get<string>('ACCESS_TOKEN_TTL') ?? '15m';
    const refreshTtl = this.configService.get<string>('REFRESH_TOKEN_TTL') ?? '7d';

    // as any — чтобы TypeScript не ругался на "15m"/"7d"
    const accessToken = this.jwtService.sign(payload as any, {
      secret: accessSecret,
      expiresIn: accessTtl as any,
    });

    const refreshToken = this.jwtService.sign(payload as any, {
      secret: refreshSecret,
      expiresIn: refreshTtl as any,
    });

    // 1 активный refresh token на пользователя
    await this.prisma.refreshToken.deleteMany({
      where: { userId },
    });

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // MVP: 7 дней (можно потом парсить refreshTtl)

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
