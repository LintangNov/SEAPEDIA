import { Body, Controller, Post, UseGuards, Request, Delete, Param, Get, Patch } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { CartService } from './cart.service';
import { AddToCartDto } from './dto/add-to-cart.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';

@UseGuards(AuthGuard, RolesGuard)
@Roles('BUYER')
@Controller('cart')
export class CartController {
    constructor(private readonly cartService: CartService){}

    @Post('items')
    addToCart(@Request() req, @Body() dto: AddToCartDto) {
        return this.cartService.addToCart(req.user.sub, dto.productId, dto.quantity);
    }

    @Delete('items/:id')
    removeCartItem(@Request() req, @Param('id') cartItemId: string) {
        return this.cartService.removeCartItem(req.user.sub, cartItemId);
    }

    @Get()
    getCart(@Request() req) {
        return this.cartService.getCart(req.user.sub);
    }

    @Delete()
    clearCart(@Request() req) {
        return this.cartService.clearCart(req.user.sub);
    }

    @Patch('items/:id')
    updateQuantity(@Request() req, @Param('id') cartItemId: string, @Body() dto: UpdateCartItemDto) {
        return this.cartService.updateCartItemQuantity(req.user.sub, cartItemId, dto.quantity);
    }
}