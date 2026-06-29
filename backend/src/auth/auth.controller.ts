import { Controller, Post, Body, HttpCode, HttpStatus, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SelectRoleDto } from './dto/select-role.dto';
import { AuthGuard } from "./auth.guard";

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @HttpCode(HttpStatus.OK)
  @Post('login')
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @UseGuards(AuthGuard)
  @HttpCode(HttpStatus.OK)
  @Post('select-role')
  async selectRole(@Request() req, @Body() dto: SelectRoleDto) {
    const userId = req.user.sub; 
    return this.authService.selectRole(userId, dto.activeRole);
  }

  @Post('logout')
  @UseGuards(AuthGuard)
  logout() {
    return { message: "Successfully logged out. Please clear your local tokens." };
  }
}