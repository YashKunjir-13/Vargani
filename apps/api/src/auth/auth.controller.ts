import { Body, Controller, HttpCode, HttpStatus, Post } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Authentication")
@Controller("auth")
export class AuthController {
  @Post("login")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Tenant-scoped user login" })
  async login(@Body() _body: Record<string, any>) {
    return {
      message: "Auth foundation ready. Production authentication handler requires active keys.",
      status: "skeleton",
    };
  }
}
