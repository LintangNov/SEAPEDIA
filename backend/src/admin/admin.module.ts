import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { ScheduleModule } from '@nestjs/schedule';
import { PrismaService } from '../prisma.service';

@Module({
  controllers: [AdminController],
  providers: [AdminService, PrismaService],
  imports: [ScheduleModule]
})
export class AdminModule {}
