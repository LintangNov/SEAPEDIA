import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { AdminService } from './admin.service';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger';

@ApiTags('Admin')
@ApiBearerAuth()
@UseGuards(AuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
    constructor(private readonly adminService: AdminService){}

    @ApiOperation({ summary: 'Get marketplace monitoring dashboard data', description: 'Retrieves operational metrics and transactional logs for administrators. Requires ADMIN role.' })
    @ApiResponse({ status: 200, description: 'Dashboard metrics successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires ADMIN role).' })
    @Get('monitoring')
    getMonitoringData() {
        return this.adminService.getMonitoringData();
    }

    @ApiOperation({ summary: 'Simulate overdue order processing', description: 'Advances system clocks to simulate order delivery timeout/overdue operations. Requires ADMIN role.' })
    @ApiResponse({ status: 200, description: 'Overdue simulation successfully executed.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires ADMIN role).' })
    @ApiBody({
        schema: {
            type: 'object',
            properties: {
                daysToAdvance: {
                    type: 'number',
                    description: 'Number of days to shift forward for checkout status checks',
                    default: 5,
                    example: 5
                }
            }
        }
    })
    @Post('simulate-overdue')
    simulateOverdue(@Body('daysToAdvance') daysToAdvance: number = 5) {
        return this.adminService.triggerOverdueSimulation(daysToAdvance);
    }
}