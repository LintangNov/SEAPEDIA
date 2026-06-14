import { IsString, IsInt, Min, Max, MinLength } from 'class-validator';

export class CreateReviewDto {
    @IsString()
    @MinLength(3)
    reviewerName!: string;

    @IsInt()
    @Min(1)
    @Max(5)
    rating!: number;

    @IsString()
    @MinLength(5)
    comment!: string;
}