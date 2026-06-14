import { Controller, Get, Body, Post } from '@nestjs/common';
import { CreateReviewDto } from './create-review.dto';
import { ReviewsService } from './reviews.service';

@Controller('reviews')
export class ReviewsController {
    constructor(private readonly reviewsService: ReviewsService) {}

    @Post()
    create(@Body() dto: CreateReviewDto) {
        return this.reviewsService.create(dto);
    }

    @Get()
    findAll() {
        return this.reviewsService.findAll();
    }
}
