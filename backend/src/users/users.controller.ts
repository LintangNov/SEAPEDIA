import { Controller, Get, UseGuards, Request, Patch, Body } from '@nestjs/common';
import { AuthGuard } from "../auth/auth.guard";
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UpdateStoreDto } from './dto/update-store.dto';
import { UsersService } from './users.service';
import { UpdateUsernameDto } from './dto/update-username-dto';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
    constructor(private readonly userService: UsersService){}

    @ApiOperation({ summary: 'Get current user profile', description: 'Returns the profile details of the authenticated user based on their active role.' })
    @ApiResponse({ status: 200, description: 'Profile successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @UseGuards(AuthGuard)
    @Get('me')
    getProfile(@Request() req){
        return this.userService.getUserProfile(req.user.sub, req.user.activeRole);
    }

    @ApiOperation({ summary: 'Update store profile', description: 'Updates the store name of a seller. Requires active role as SELLER.' })
    @ApiResponse({ status: 200, description: 'Store profile successfully updated.' })
    @ApiResponse({ status: 400, description: 'Store name already taken or invalid input.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires SELLER role).' })
    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Patch('seller/store')
    updateStore(@Request() req, @Body() dto: UpdateStoreDto){
        return this.userService.updateStoreProfile(req.user.sub, dto);
    }

    @ApiOperation({ summary: 'Update username', description: 'Updates the unique username of the current user.' })
    @ApiResponse({ status: 200, description: 'Username successfully updated.' })
    @ApiResponse({ status: 400, description: 'Username already taken or invalid input.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @UseGuards(AuthGuard)
    @Patch('me/username')
    updateUsername(@Request() req, @Body() dto: UpdateUsernameDto){
        return this.userService.updateUsername(req.user.sub, dto.username);
    }
}
