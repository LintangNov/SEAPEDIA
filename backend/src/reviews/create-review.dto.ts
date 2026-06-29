import { IsString, IsInt, Min, Max, MinLength, MaxLength, maxLength } from 'class-validator';

export class CreateReviewDto {
    @IsString()
    @MinLength(3)
    @MaxLength(100)
    reviewerName!: string;

    @IsInt()
    @Min(1)
    @Max(5)
    rating!: number;

    @IsString()
    @MinLength(5)
    @MaxLength(1000)
    comment!: string;
}