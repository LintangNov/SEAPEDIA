import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { PrismaService } from '../prisma.service';
import { SchedulerModule } from '../scheduler/scheduler.module';

@Module({
  controllers: [AdminController],
  providers: [AdminService, PrismaService],
  imports: [SchedulerModule]
})
export class AdminModule {}
