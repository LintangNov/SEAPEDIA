import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ProductsModule } from './products/products.module';
import { ReviewsModule } from './reviews/reviews.module';
import { PrismaService } from './prisma.service';
import { BuyerModule } from './buyer/buyer.module';
import { CartModule } from './cart/cart.module';
import { OrderModule } from './order/order.module';
import { DiscountModule } from './discount/discount.module';

@Module({
  imports: [
    ConfigModule.forRoot({ 
      isGlobal: true,
      envFilePath: '.env'
    }),
    AuthModule,
    UsersModule,
    ProductsModule,
    ReviewsModule,
    BuyerModule,
    CartModule,
    OrderModule,
    DiscountModule,
  ],
  controllers: [AppController],
  providers: [AppService, PrismaService],
})
export class AppModule {}