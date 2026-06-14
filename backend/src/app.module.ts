import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsersController } from './users/users.controller';
import { ProductsModule } from './products/products.module';
import { ReviewsModule } from './reviews/reviews.module';

@Module({
  imports: [AuthModule, ProductsModule, ReviewsModule],
  controllers: [AppController, UsersController],
  providers: [AppService],
})
export class AppModule {}
