import { Module } from '@nestjs/common';
import { BuyerController } from './buyer.controller';
import { BuyerService } from './buyer.service';
import { PrismaService } from '../prisma.service';

@Module({
  controllers: [BuyerController],
  providers: [BuyerService, PrismaService]
})
export class BuyerModule {}
