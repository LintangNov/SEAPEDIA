import { Body, Controller, Get, Post, UseGuards } from "@nestjs/common";
import { PrismaService } from "../prisma.service";
import { AuthGuard } from "../auth/auth.guard";
import { RolesGuard } from "../auth/roles.guard";
import { Roles } from "../auth/roles.decorator";
import { CreateDiscountDto } from "./dto/create-discount.dto";

@Controller('discounts')
export class DiscountController {
    constructor(private prisma: PrismaService) {}

    @UseGuards(AuthGuard, RolesGuard)
    @Roles('ADMIN')
    @Post()
    async createDiscount(@Body() dto: CreateDiscountDto) {
        const discount = await this.prisma.discount.create({data: dto});
        return {message: "Discounts retrieved", data: discount};
    }

    @Get()
    async listDiscounts() {
        const discounts = await this.prisma.discount.findMany({
            orderBy: {createdAt: 'desc'}
        });
        return {message: "Discounts retrieved", data: discounts};
    }
}