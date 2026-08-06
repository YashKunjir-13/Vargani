import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { AuthModule } from "../auth/auth.module";
import { MembershipsController } from "./memberships/memberships.controller";
import { MembershipsService } from "./memberships/memberships.service";
import { OrganizationsController } from "./organizations/organizations.controller";
import { OrganizationsService } from "./organizations/organizations.service";
import { RolesController } from "./roles/roles.controller";
import { RolesService } from "./roles/roles.service";
import { SettingsController } from "./settings/settings.controller";
import { SettingsService } from "./settings/settings.service";

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [
    OrganizationsController,
    MembershipsController,
    RolesController,
    SettingsController,
  ],
  providers: [
    OrganizationsService,
    MembershipsService,
    RolesService,
    SettingsService,
  ],
  exports: [
    OrganizationsService,
    MembershipsService,
    RolesService,
    SettingsService,
  ],
})
export class TenantModule {}
