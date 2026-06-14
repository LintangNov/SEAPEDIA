import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from "../auth/auth.guard";
import { profile } from 'console';

@Controller('users')
export class UsersController {

    @UseGuards(AuthGuard)
    @Get('me')
    getProfile(@Request() req){
        return{
            message: "Profile successfully retrieved",
            profile: req.user,
        };
    }
}
