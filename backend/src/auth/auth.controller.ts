import { Controller, Post, Body, HttpCode, HttpStatus, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SelectRoleDto } from './dto/select-role.dto';
import { AuthGuard } from "./auth.guard";
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @ApiOperation({ summary: 'Register a new user', description: 'Creates a new user profile with selected roles (SELLER, BUYER, DRIVER).' })
  @ApiResponse({ status: 201, description: 'User successfully registered.' })
  @ApiResponse({ status: 400, description: 'Invalid input data or username/email already exists.' })
  @Post('register')
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @ApiOperation({ summary: 'User login', description: 'Authenticates user credentials and returns a JWT access token.' })
  @ApiResponse({ status: 200, description: 'User successfully logged in.' })
  @ApiResponse({ status: 401, description: 'Invalid credentials.' })
  @HttpCode(HttpStatus.OK)
  @Post('login')
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Select/Switch active role', description: 'Sets the active role session for a multi-role user. Requires a valid JWT token.' })
  @ApiResponse({ status: 200, description: 'Active role successfully updated.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'User does not possess the requested role.' })
  @UseGuards(AuthGuard)
  @HttpCode(HttpStatus.OK)
  @Post('select-role')
  async selectRole(@Request() req, @Body() dto: SelectRoleDto) {
    const userId = req.user.sub; 
    return this.authService.selectRole(userId, dto.activeRole);
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'User logout', description: 'Logs the user out and prompts clearing of active local tokens.' })
  @ApiResponse({ status: 200, description: 'User successfully logged out.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @HttpCode(HttpStatus.OK)
  @Post('logout')
  @UseGuards(AuthGuard)
  logout() {
    return { message: "Successfully logged out. Please clear your local tokens." };
  }
}