import { IsString, IsInt, Min, Max, MinLength, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateReviewDto {
    @ApiProperty({
        description: 'The name of the person writing the review',
        minLength: 3,
        maxLength: 100,
        example: 'Jane Doe',
    })
    @IsString()
    @MinLength(3)
    @MaxLength(100)
    reviewerName!: string;

    @ApiProperty({
        description: 'The rating given to the application (between 1 and 5)',
        minimum: 1,
        maximum: 5,
        example: 5,
    })
    @IsInt()
    @Min(1)
    @Max(5)
    rating!: number;

    @ApiProperty({
        description: 'The review comments/feedback (between 5 and 1000 characters)',
        minLength: 5,
        maxLength: 1000,
        example: 'The offline features are incredibly helpful and reliable during emergencies!',
    })
    @IsString()
    @MinLength(5)
    @MaxLength(1000)
    comment!: string;
}