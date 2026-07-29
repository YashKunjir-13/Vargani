import { Module } from "@nestjs/common";
import { SequenceCounterService } from "./sequence-counter.service";

@Module({
  providers: [SequenceCounterService],
  exports: [SequenceCounterService],
})
export class SequenceModule {}
