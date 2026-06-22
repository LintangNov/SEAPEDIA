import { Body, Controller, Post, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { BuyerService } from './buyer.service';
import { TopUpDto } from './dto/top-up.dto';

@UseGuards(AuthGuard, RolesGuard)
@Roles('Buyer')
@Controller('buyer')
export class BuyerController {
    constructor(private readonly buyerService: BuyerService) { }

    @Post('topup')
    topUp(@Request() req, @Body() dto: TopUpDto) {
        return this.buyerService.topUp(req.user.sub, dto.amount);
    }
}
