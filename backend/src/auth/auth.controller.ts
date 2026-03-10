import { Controller, Post, Body, Get, Request, UseGuards, HttpCode } from '@nestjs/common';
import { IsEmail, IsString } from 'class-validator';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';

export class LoginDto {
  @IsEmail()   email: string;
  @IsString()  password: string;
}

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  @HttpCode(200)
  async login(@Body() dto: LoginDto, @Request() req: any) {
    const ip        = req.ip || req.headers?.['x-forwarded-for'] || null;
    const userAgent = req.headers?.['user-agent'] || null;
    return this.authService.login(dto.email, dto.password, ip, userAgent);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Request() req) {
    return this.authService.getProfile(req.user.sub);
  }

  @Post('logout')
  @HttpCode(200)
  logout() { return { message: 'Erfolgreich abgemeldet' }; }
}
