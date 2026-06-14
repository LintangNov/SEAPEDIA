import { Controller, Get, Param } from '@nestjs/common';
import { ProductsService } from './products.service';

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
}
