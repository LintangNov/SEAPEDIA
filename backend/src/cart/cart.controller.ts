import { Body, Controller, Post, UseGuards, Request, Delete, Param, Get, Patch } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { CartService } from './cart.service';
import { AddToCartDto } from './dto/add-to-cart.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';

@ApiTags('Cart')
@ApiBearerAuth()
@UseGuards(AuthGuard, RolesGuard)
@Roles('BUYER')
@Controller('cart')
export class CartController {
    constructor(private readonly cartService: CartService){}

    @ApiOperation({ summary: 'Add product to cart', description: 'Adds an item to the buyer\'s shopping cart or increases its quantity.' })
    @ApiResponse({ status: 201, description: 'Product successfully added to cart.' })
    @ApiResponse({ status: 400, description: 'Invalid input data or insufficient product stock.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @Post('items')
    addToCart(@Request() req, @Body() dto: AddToCartDto) {
        return this.cartService.addToCart(req.user.sub, dto.productId, dto.quantity);
    }

    @ApiOperation({ summary: 'Remove item from cart', description: 'Removes a specific cart item from the buyer\'s cart.' })
    @ApiResponse({ status: 200, description: 'Cart item successfully removed.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @ApiResponse({ status: 404, description: 'Cart item not found.' })
    @ApiParam({ name: 'id', description: 'Cart item UUID' })
    @Delete('items/:id')
    removeCartItem(@Request() req, @Param('id') cartItemId: string) {
        return this.cartService.removeCartItem(req.user.sub, cartItemId);
    }

    @ApiOperation({ summary: 'Retrieve cart', description: 'Gets the current buyer\'s shopping cart content, including total price.' })
    @ApiResponse({ status: 200, description: 'Cart content successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @Get()
    getCart(@Request() req) {
        return this.cartService.getCart(req.user.sub);
    }

    @ApiOperation({ summary: 'Clear cart', description: 'Removes all items from the buyer\'s shopping cart.' })
    @ApiResponse({ status: 200, description: 'Cart successfully cleared.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @Delete()
    clearCart(@Request() req) {
        return this.cartService.clearCart(req.user.sub);
    }

    @ApiOperation({ summary: 'Update cart item quantity', description: 'Updates the quantity of a specific item in the buyer\'s cart.' })
    @ApiResponse({ status: 200, description: 'Cart item quantity successfully updated.' })
    @ApiResponse({ status: 400, description: 'Invalid quantity or insufficient product stock.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires BUYER role).' })
    @ApiResponse({ status: 404, description: 'Cart item not found.' })
    @ApiParam({ name: 'id', description: 'Cart item UUID' })
    @Patch('items/:id')
    updateQuantity(@Request() req, @Param('id') cartItemId: string, @Body() dto: UpdateCartItemDto) {
        return this.cartService.updateCartItemQuantity(req.user.sub, cartItemId, dto.quantity);
    }
}