import { Controller, Get, HttpStatus, Param, Query } from "@nestjs/common";
import { ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { PublicQueryService } from "./public-query.service";

@ApiTags("Public Event Transparency Engine")
@Controller("public/events")
export class PublicQueryController {
  constructor(private readonly publicQueryService: PublicQueryService) {}

  @Get(":slug")
  @ApiOperation({ summary: "Get public event overview and live totals by slug" })
  async getPublicEventPage(@Param("slug") slug: string) {
    const result = await this.publicQueryService.getPublicEventPage(slug);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get(":slug/donors")
  @ApiOperation({ summary: "Get public donor list with privacy redactions" })
  @ApiQuery({ name: "limit", required: false })
  @ApiQuery({ name: "offset", required: false })
  async getPublicEventDonors(
    @Param("slug") slug: string,
    @Query("limit") limit?: string,
    @Query("offset") offset?: string,
  ) {
    const result = await this.publicQueryService.getPublicEventDonors(
      slug,
      limit ? parseInt(limit, 10) : 50,
      offset ? parseInt(offset, 10) : 0,
    );
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get(":slug/expenses")
  @ApiOperation({ summary: "Get public category-wise expense breakdown" })
  async getPublicEventExpenses(@Param("slug") slug: string) {
    const result = await this.publicQueryService.getPublicEventExpenses(slug);
    return createApiResponse(result, HttpStatus.OK);
  }
}
