import { Controller, Get, UseGuards, Request, Patch, Body } from '@nestjs/common';
import { AuthGuard } from "../auth/auth.guard";
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UpdateStoreDto } from './dto/update-store.dto';
import { UsersService } from './users.service';
import { UpdateUsernameDto } from './dto/update-username-dto';

@Controller('users')
export class UsersController {
    constructor(private readonly userService: UsersService){}

    @UseGuards(AuthGuard)
    @Get('me')
    getProfile(@Request() req){
        return this.userService.getUserProfile(req.user.sub, req.user.activeRole);
    }

    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Patch('seller/store')
    updateStore(@Request() req, @Body() dto: UpdateStoreDto){
        return this.userService.updateStoreProfile(req.user.sub, dto);
    }

    @UseGuards(AuthGuard)
    @Patch('me/username')
    updateUsername(@Request() req, @Body() dto: UpdateUsernameDto){
        return this.userService.updateUsername(req.user.sub, dto.username);
    }
}
