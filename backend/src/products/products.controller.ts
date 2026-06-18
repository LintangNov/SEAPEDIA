import { Controller, Get, Param, Patch, Post, UseGuards, Request, Body, Delete } from '@nestjs/common';
import { ProductsService } from './products.service';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UpdateProductDto } from './dto/update-product.dto';
import { CreateProductDto } from './dto/create-product.dto';

@Controller('products')
export class ProductsController {
    constructor(private readonly productService: ProductsService) {}

    @Get()
    findAll(){
        return this.productService.findAll();
    }

    @Get(':id')
    findOne(@Param('id') id: string){
        return this.productService.findOne(id);
    }

    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Get('seller/mine')
    findSellerProducts(@Request() req) {
        return this.productService.findSellerProducts(req.user.sub);
    }

    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Post()
    create(@Request() req, @Body() dto: CreateProductDto) {
        return this.productService.create(req.user.sub, dto);
    }

    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Patch(':id')
    update(@Request() req, @Param('id') id: string, @Body() dto: UpdateProductDto) {
        return this.productService.update(req.user.sub, id, dto);
    }

    @UseGuards(AuthGuard, RolesGuard)
    @Roles('SELLER')
    @Delete(':id')
    remove(@Request() req, @Param('id') id: string) {
        return this.productService.remove(req.user.sub, id);
    }
}
