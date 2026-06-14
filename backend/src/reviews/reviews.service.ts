import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateReviewDto } from './create-review.dto';

@Injectable()
export class ReviewsService {
    constructor(private readonly prisma: PrismaService){}

    async create(dto: CreateReviewDto) {
        const review = await this.prisma.applicationReview.create({
            data: {
                reviewerName: dto.reviewerName,
                rating: dto.rating,
                comment: dto.comment,
            },

        });

        return {
            message: "Review submitted successfully",
            data: review,
        };
    }

    async findAll(){
        const reviews = await this.prisma.applicationReview.findMany({
            orderBy: { createdAt: 'desc' },
        });

        return {
            message: 'Review list successfully retrieved',
            data: reviews,
        };
    }
}
