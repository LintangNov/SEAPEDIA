import { Controller, Get, Param, Post, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { DriverService } from './driver.service';

@UseGuards(AuthGuard, RolesGuard)
@Roles('DRIVER')
@Controller('driver')
export class DriverController {
    constructor(private readonly driverService: DriverService) {}

    @Get('me')
    getProfile(@Request() req) {
        return this.driverService.getProfile(req.user.sub);
    }

    @Get('jobs/available')
    getAvailableJobs() {
        return this.driverService.getAvailableJobs();
    }

    @Get('jobs/:id/detail')
    getJobDetail(@Param('id') orderId: string) {
        return this.driverService.getJobDetail(orderId);
    }

    @Post('jobs/:id/take')
    takeJob(@Request() req, @Param('id') orderId: string) {
        return this.driverService.takeJob(req.user.sub, orderId);
    }

    @Post('jobs/:id/complete')
    completeJob(@Request() req, @Param('id') orderId: string) {
        return this.driverService.completeJob(req.user.sub, orderId);
    }

    @Get('jobs/history')
    getJobHistory(@Request() req) {
        return this.driverService.getJobHistory(req.user.sub);
    }
}