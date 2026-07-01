import { IsNumber, Min } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class TopUpDto {
    @ApiProperty({
        description: 'The amount of money to top up the buyer wallet (minimum 0.01)',
        minimum: 0.01,
        example: 500000,
    })
    @IsNumber({ maxDecimalPlaces: 2 })
    @Min(0.01)
    amount!: number;
}