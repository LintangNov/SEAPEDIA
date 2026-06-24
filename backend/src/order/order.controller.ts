import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { CheckoutDto } from './dto/checkout.dto';
import { OrderService } from './order.service';

@UseGuards(AuthGuard, RolesGuard)
@Roles('BUYER')
@Controller('order')
export class OrderController {
    constructor(private readonly orderService: OrderService) {}

    @Post('Checkout')
    checkout(@Request() req, @Body() dto: CheckoutDto) {
        return this.orderService.checkout(req.user.sub, dto);
    }
}
