import { Module } from "@nestjs/common";
import { OrganizationsController } from "./tenant.controller";

@Module({
  controllers: [OrganizationsController],
})
export class TenantModule {}
