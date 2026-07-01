import { Body, Controller, Post, UseGuards, Request, Get } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { BuyerService } from './buyer.service';
import { TopUpDto } from './dto/top-up.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Buyer')
@ApiBearerAuth()
@UseGuards(AuthGuard, RolesGuard)
@Roles('BUYER')
@Controller('buyer')
export class BuyerController {
    constructor(private readonly buyerService: BuyerService) { }

    @ApiOperation({ summary: 'Top up wallet balance', description: 'Deposits funds into the buyer\'s e-wallet. Requires active role as BUYER.' })
    @ApiResponse({ status: 200, description: 'Wallet successfully topped up.' })
    @ApiResponse({ status: 400, description: 'Invalid deposit amount.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @Post('topup')
    topUp(@Request() req, @Body() dto: TopUpDto) {
        return this.buyerService.topUp(req.user.sub, dto.amount);
    }

    @ApiOperation({ summary: 'Get wallet transaction history', description: 'Retrieves the history of e-wallet transactions (deposits, refunds, checkouts) for the buyer. Requires active role as BUYER.' })
    @ApiResponse({ status: 200, description: 'Wallet history successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @Get('wallet/history')
    getWalletHistory(@Request() req) {
        return this.buyerService.getWalletHistory(req.user.sub);
    }
}
