import { Body, Controller, Get, Param, Patch, Post, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { CheckoutDto } from './dto/checkout.dto';
import { OrderService } from './order.service';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';

@ApiTags('Orders')
@ApiBearerAuth()
@UseGuards(AuthGuard, RolesGuard)
@Roles('BUYER')
@Controller('order')
export class OrderController {
    constructor(private readonly orderService: OrderService) {}

    @ApiOperation({ summary: 'Checkout cart items', description: 'Creates an order from active cart items. Requires active role as BUYER.' })
    @ApiResponse({ status: 201, description: 'Order successfully created.' })
    @ApiResponse({ status: 400, description: 'Insufficient balance, invalid promo code, or cart is empty.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @Post('Checkout')
    checkout(@Request() req, @Body() dto: CheckoutDto) {
        return this.orderService.checkout(req.user.sub, dto);
    }

    @ApiOperation({ summary: 'Get buyer\'s order history', description: 'Retrieves history of all orders placed by the current buyer.' })
    @ApiResponse({ status: 200, description: 'Order history successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @Roles('BUYER')
    @Get('buyer/history')
    getBuyerHistory(@Request() req) {
        return this.orderService.getBuyerOrders(req.user.sub);
    }

    @ApiOperation({ summary: 'Get incoming orders for seller', description: 'Retrieves incoming orders that need to be processed by the current seller. Requires active role as SELLER.' })
    @ApiResponse({ status: 200, description: 'Incoming orders successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires SELLER role).' })
    @Roles('SELLER')
    @Get('seller/incoming')
    getSellerOrders(@Request() req) {
        return this.orderService.getSellerOrders(req.user.sub);
    }

    @ApiOperation({ summary: 'Process incoming order', description: 'Allows a seller to process/accept an incoming order. Requires active role as SELLER.' })
    @ApiResponse({ status: 200, description: 'Order successfully updated/processed.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires SELLER role) or seller is not the owner of the ordered product.' })
    @ApiResponse({ status: 404, description: 'Order not found.' })
    @ApiParam({ name: 'id', description: 'Order UUID' })
    @Roles('SELLER')
    @Patch('seller/:id/process')
    processOrder(@Request() req, @Param('id') orderId: string) {
        return this.orderService.processSellerOrder(req.user.sub, orderId);
    }
}
