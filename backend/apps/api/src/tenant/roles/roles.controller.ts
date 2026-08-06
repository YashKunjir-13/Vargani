import { Body, Controller, Delete, Get, HttpCode, HttpStatus, Param, Patch, Post, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../../auth/current-user.decorator";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { CreateRoleDto } from "./dto/create-role.dto";
import { UpdateRoleDto } from "./dto/update-role.dto";
import { RolesService } from "./roles.service";

@ApiTags("Custom Roles & Permissions")
@Controller("roles")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class RolesController {
  constructor(private readonly rolesService: RolesService) {}

  @Get("permissions")
  @ApiOperation({ summary: "List permission catalog" })
  async getPermissionsCatalog() {
    const result = await this.rolesService.getPermissionsCatalog();
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get()
  @ApiOperation({ summary: "List organization roles" })
  async listRoles(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.rolesService.listRoles(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get(":id")
  @ApiOperation({ summary: "Retrieve role and permissions by ID" })
  async getRole(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.rolesService.getRole(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Create custom role" })
  async createRole(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateRoleDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.rolesService.createRole(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Custom role created");
  }

  @Patch(":id")
  @ApiOperation({ summary: "Update role and permission set" })
  async updateRole(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateRoleDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.rolesService.updateRole(user.organizationId, id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Role updated");
  }

  @Delete(":id")
  @ApiOperation({ summary: "Delete unused custom role" })
  async deleteRole(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.rolesService.deleteRole(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK, "Role deleted");
  }
}
