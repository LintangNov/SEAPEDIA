import { Injectable, NotFoundException } from '@nestjs/common';

@Injectable()
export class ProductsService {
    private readonly dummyProducts = [
        {
            id: 'prod-1',
            name: 'Mechanical Keyboard Switch Red',
            description: 'Keyboard mekanik dengan red switch yang sunyi, cocok untuk di kantor.',
            price: 450000,
            stock: 15,
            storeName: 'Lenovo',
        },
        {
            d: 'prod-3',
            name: 'Kabel Data Type-C 100W',
            description: 'Kabel fast charging dengan material braided nylon.',
            price: 45000,
            stock: 100,
            storeName: 'Lenovo',
        },
        {
            id: 'prod-2',
            name: 'Kopi Arabica Gayo 250g',
            description: 'Biji kopi roasting medium dari dataran tinggi Gayo.',
            price: 85000,
            stock: 40,
            storeName: 'Kopikap',
        }
    ];

    findAll(){
        return {
            message: "Product catalog successfully retrieved",
            data: this.dummyProducts,
        }
    }

    findOne(id: string){
        const product = this.dummyProducts.find(p=> p.id === id);
        if (!product){
            throw new NotFoundException(`Product with ID: ${id} not found`);
            
        }

        return {
            message: "Product detail successfully retrieved",
            data: product,
        };
    }
}
