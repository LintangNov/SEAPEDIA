import { Controller, Get, Param, Post, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { DriverService } from './driver.service';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';

@ApiTags('Driver')
@ApiBearerAuth()
@UseGuards(AuthGuard, RolesGuard)
@Roles('DRIVER')
@Controller('driver')
export class DriverController {
    constructor(private readonly driverService: DriverService) {}

    @ApiOperation({ summary: 'Get driver profile', description: 'Retrieves the driver profile and current status for the authenticated user. Requires active role as DRIVER.' })
    @ApiResponse({ status: 200, description: 'Driver profile successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires DRIVER role).' })
    @Get('me')
    getProfile(@Request() req) {
        return this.driverService.getProfile(req.user.sub);
    }

    @ApiOperation({ summary: 'List available jobs', description: 'Retrieves all orders that are awaiting shipment. Requires active role as DRIVER.' })
    @ApiResponse({ status: 200, description: 'Available jobs successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires DRIVER role).' })
    @Get('jobs/available')
    getAvailableJobs() {
        return this.driverService.getAvailableJobs();
    }

    @ApiOperation({ summary: 'Get job detail', description: 'Retrieves detailed information of an available job by Order ID. Requires active role as DRIVER.' })
    @ApiResponse({ status: 200, description: 'Job details successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires DRIVER role).' })
    @ApiResponse({ status: 404, description: 'Job not found.' })
    @ApiParam({ name: 'id', description: 'Order UUID' })
    @Get('jobs/:id/detail')
    getJobDetail(@Param('id') orderId: string) {
        return this.driverService.getJobDetail(orderId);
    }

    @ApiOperation({ summary: 'Take a job', description: 'Accepts an available shipping job. Sets order status to BEING_SHIPPED and assigns the driver. Requires active role as DRIVER.' })
    @ApiResponse({ status: 200, description: 'Job successfully accepted.' })
    @ApiResponse({ status: 400, description: 'Job is no longer available or driver already has an active delivery.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires DRIVER role).' })
    @ApiResponse({ status: 404, description: 'Job not found.' })
    @ApiParam({ name: 'id', description: 'Order UUID' })
    @Post('jobs/:id/take')
    takeJob(@Request() req, @Param('id') orderId: string) {
        return this.driverService.takeJob(req.user.sub, orderId);
    }

    @ApiOperation({ summary: 'Complete a job', description: 'Marks the active delivery job as completed. Sets order status to ORDER_COMPLETED. Requires active role as DRIVER.' })
    @ApiResponse({ status: 200, description: 'Job successfully completed.' })
    @ApiResponse({ status: 400, description: 'Order is not currently in BEING_SHIPPED status or not assigned to this driver.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires DRIVER role).' })
    @ApiResponse({ status: 404, description: 'Job not found.' })
    @ApiParam({ name: 'id', description: 'Order UUID' })
    @Post('jobs/:id/complete')
    completeJob(@Request() req, @Param('id') orderId: string) {
        return this.driverService.completeJob(req.user.sub, orderId);
    }

    @ApiOperation({ summary: 'Get job history', description: 'Retrieves history of all completed and past delivery jobs for the authenticated driver. Requires active role as DRIVER.' })
    @ApiResponse({ status: 200, description: 'Delivery job history successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires DRIVER role).' })
    @Get('jobs/history')
    getJobHistory(@Request() req) {
        return this.driverService.getJobHistory(req.user.sub);
    }
}