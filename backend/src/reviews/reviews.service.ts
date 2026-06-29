import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateReviewDto } from './create-review.dto';
import * as xss from 'xss';

@Injectable()
export class ReviewsService {
    constructor(private readonly prisma: PrismaService){}

    async create(dto: CreateReviewDto) {
        const cleanReviewerName = xss.filterXSS(dto.reviewerName);
        const cleanComment = xss.filterXSS(dto.comment);

        const review = await this.prisma.applicationReview.create({
            data: {
                reviewerName: cleanReviewerName,
                rating: dto.rating,
                comment: cleanComment,
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
