import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { AdminService } from './admin.service';

@UseGuards(AuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
    constructor(private readonly adminService: AdminService){}

    @Get('monitoring')
    getMonitoringData() {
        return this.adminService.getMonitoringData();
    }

    @Post('simulate-overdue')
    simulateOverdue(@Body('daysToAdvance') daysToAdvance: number = 5) {
        return this.adminService.triggerOverdueSimulation(daysToAdvance);
    }
}