import { Module } from "@nestjs/common";
import { PermissionResolutionService } from "./permission-resolution.service";
import { RoleManagementService } from "./role-management.service";
import { RoleSeedService } from "./role-seed.service";

@Module({
  providers: [PermissionResolutionService, RoleSeedService, RoleManagementService],
  exports: [PermissionResolutionService, RoleSeedService, RoleManagementService],
})
export class RbacModule {}
