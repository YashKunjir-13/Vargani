import { Module } from "@nestjs/common";
import { DocumentsController } from "./document.controller";

@Module({
  controllers: [DocumentsController],
})
export class DocumentModule {}
