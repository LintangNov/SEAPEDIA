import { Body, Controller, Get, Post, UseGuards } from "@nestjs/common";
import { PrismaService } from "../prisma.service";
import { AuthGuard } from "../auth/auth.guard";
import { RolesGuard } from "../auth/roles.guard";
import { Roles } from "../auth/roles.decorator";
import { CreateDiscountDto } from "./dto/create-discount.dto";
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Discounts')
@Controller('discounts')
export class DiscountController {
    constructor(private prisma: PrismaService) {}

    @ApiBearerAuth()
    @ApiOperation({ summary: 'Create a new discount code', description: 'Allows administrators to create a promotional coupon or discount voucher. Requires ADMIN role.' })
    @ApiResponse({ status: 201, description: 'Discount code successfully created.' })
    @ApiResponse({ status: 400, description: 'Discount code already exists or invalid input data.' })
    @ApiResponse({ status: 401, description: 'Unauthorized.' })
    @ApiResponse({ status: 403, description: 'Forbidden (Requires ADMIN role).' })
    @UseGuards(AuthGuard, RolesGuard)
    @Roles('ADMIN')
    @Post()
    async createDiscount(@Body() dto: CreateDiscountDto) {
        const discount = await this.prisma.discount.create({data: dto});
        return {message: "Discount created", data: discount};
    }

    @ApiOperation({ summary: 'List all discounts', description: 'Retrieves a list of all available discount vouchers and promo codes.' })
    @ApiResponse({ status: 200, description: 'Discounts successfully retrieved.' })
    @Get()
    async listDiscounts() {
        const discounts = await this.prisma.discount.findMany({
            orderBy: {createdAt: 'desc'}
        });
        return {message: "Discounts retrieved", data: discounts};
    }
}