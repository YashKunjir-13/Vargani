import { Module } from "@nestjs/common";
import { FestivalYearService } from "./festival-year.service";

@Module({
  providers: [FestivalYearService],
  exports: [FestivalYearService],
})
export class FestivalYearModule {}
