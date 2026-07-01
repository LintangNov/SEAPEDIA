import { Controller, Get, Param, Patch, Post, UseGuards, Request, Body, Delete } from '@nestjs/common';
import { ProductsService } from './products.service';
import { AuthGuard } from '../auth/auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UpdateProductDto } from './dto/update-product.dto';
import { CreateProductDto } from './dto/create-product.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';

@ApiTags('Products')
@Controller('products')
export class ProductsController {
    constructor(private readonly productService: ProductsService) {}

    @ApiOperation({ summary: 'List all public products', description: 'Retrieves all active/public products available in the marketplace.' })
    @ApiResponse({ status: 200, description: 'Products successfully retrieved.' })
    @Get()
    findAll(){
        return this.productService.findAllPublic();
    }

    @ApiOperation({ summary: 'Get product detail by ID', description: 'Retrieves detailed information of a single product.' })
    @ApiResponse({ status: 200, description: 'Product successfully retrieved.' })
    @ApiResponse({ status: 404, description: 'Product not found.' })
    @ApiParam({ name: 'id', description: 'Product UUID' })
    @Get(':id')
    findOne(@Param('id') id: string){
        return this.productService.findOnePublic(id);
    }

    @ApiBearerAuth()
    @ApiOperation({ summary: 'List seller\'s own products', description: 'Retrieves all products belonging to the authenticated seller.' })
    @ApiResponse({ status: 200, description: 'Seller products successfully retrieved.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires SELLER role).' })
    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Get('seller/mine')
    findSellerProducts(@Request() req) {
        return this.productService.findSellerProducts(req.user.sub);
    }

    @ApiBearerAuth()
    @ApiOperation({ summary: 'Create a new product', description: 'Allows sellers to create and list a new product in the marketplace.' })
    @ApiResponse({ status: 201, description: 'Product successfully created.' })
    @ApiResponse({ status: 400, description: 'Invalid input data.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires SELLER role).' })
    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Post()
    create(@Request() req, @Body() dto: CreateProductDto) {
        return this.productService.create(req.user.sub, dto);
    }

    @ApiBearerAuth()
    @ApiOperation({ summary: 'Update a product', description: 'Allows a seller to update their own product details.' })
    @ApiResponse({ status: 200, description: 'Product successfully updated.' })
    @ApiResponse({ status: 400, description: 'Invalid input data.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden or user is not the owner of this product.' })
    @ApiResponse({ status: 404, description: 'Product not found.' })
    @ApiParam({ name: 'id', description: 'Product UUID' })
    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Patch(':id')
    update(@Request() req, @Param('id') id: string, @Body() dto: UpdateProductDto) {
        return this.productService.update(req.user.sub, id, dto);
    }

    @ApiBearerAuth()
    @ApiOperation({ summary: 'Delete/Remove a product', description: 'Allows a seller to delete their own product.' })
    @ApiResponse({ status: 200, description: 'Product successfully deleted.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden or user is not the owner of this product.' })
    @ApiResponse({ status: 404, description: 'Product not found.' })
    @ApiParam({ name: 'id', description: 'Product UUID' })
    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Delete(':id')
    remove(@Request() req, @Param('id') id: string) {
        return this.productService.remove(req.user.sub, id);
    }
}
