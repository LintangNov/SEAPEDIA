import { Controller, Get, Body, Post } from '@nestjs/common';
import { CreateReviewDto } from './create-review.dto';
import { ReviewsService } from './reviews.service';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';

@ApiTags('Application Reviews')
@Controller('reviews')
export class ReviewsController {
    constructor(private readonly reviewsService: ReviewsService) {}

    @ApiOperation({ summary: 'Submit an application review', description: 'Allows visitors or users to submit feedback and a rating (1-5) for the application.' })
    @ApiResponse({ status: 201, description: 'Review successfully submitted.' })
    @ApiResponse({ status: 400, description: 'Invalid review input data.' })
    @ApiResponse({ status: 429, description: 'Too many requests. Review submissions are throttled.' })
    @Throttle({ default: { limit: 3, ttl: 60000 } })
    @Post()
    create(@Body() dto: CreateReviewDto) {
        return this.reviewsService.create(dto);
    }

    @ApiOperation({ summary: 'List all application reviews', description: 'Retrieves all submitted reviews and ratings for the application.' })
    @ApiResponse({ status: 200, description: 'Reviews successfully retrieved.' })
    @Get()
    findAll() {
        return this.reviewsService.findAll();
    }
}
