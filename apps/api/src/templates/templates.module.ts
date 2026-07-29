import { Module } from "@nestjs/common";
import { SequenceModule } from "../common/sequence/sequence.module";
import { StorageModule } from "../common/storage/storage.module";
import { TenancyModule } from "../common/tenancy/tenancy.module";
import { FIELD_DETECTION_ENGINE, StubFieldDetectionEngine } from "./field-detection.engine";
import { TemplatesController } from "./templates.controller";
import { TemplatesService } from "./templates.service";

@Module({
  imports: [TenancyModule, SequenceModule, StorageModule],
  controllers: [TemplatesController],
  providers: [
    TemplatesService,
    { provide: FIELD_DETECTION_ENGINE, useClass: StubFieldDetectionEngine },
  ],
  exports: [TemplatesService],
})
export class TemplatesModule {}
