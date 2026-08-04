import { MiddlewareConsumer, Module, NestModule } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { ThrottlerModule } from "@nestjs/throttler";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { CorrelationMiddleware } from "@pauti-pustak/backend-observability";
import { CommonModule } from "./common/common.module";
import { AuthModule } from "./auth/auth.module";
import { UsersModule } from "./users/users.module";
import { DevAuthBypassMiddleware } from "./auth/dev-auth-bypass.middleware";
import { HealthModule } from "./health/health.module";
import { TenantModule } from "./tenant/tenant.module";
import { EventModule } from "./event/event.module";
import { VolunteerModule } from "./volunteer/volunteer.module";
import { DonorModule } from "./donor/donor.module";
import { ContributorModule } from "./contributor/contributor.module";
import { ContributionModule } from "./contribution/contribution.module";
import { PaymentsModule } from "./payments/payments.module";
import { ReceiptsModule } from "./receipts/receipts.module";
import { BillsModule } from "./bills/bills.module";
import { FinanceModule } from "./finance/finance.module";
import { PublicQueryModule } from "./public-query/public-query.module";
import { DocumentModule } from "./document/document.module";
import { NotificationModule } from "./notification/notification.module";
import { ReportingModule } from "./reporting/reporting.module";
import { AuditModule } from "./audit/audit.module";
import { TemplatesModule } from "./templates/templates.module";
import { ContributionReceiptsModule } from "./contribution-receipts/contribution-receipts.module";
import { PlatformAdminModule } from "./platform/platform-admin.module";
import { DashboardModule } from "./dashboard/dashboard.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [".env.local", ".env"],
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 100,
      },
    ]),
    PrismaModule,
    CommonModule,
    HealthModule,
    AuthModule,
    UsersModule,
    TenantModule,
    EventModule,
    DonorModule,
    VolunteerModule,
    ContributorModule,
    ContributionModule,
    ContributionReceiptsModule,
    PaymentsModule,
    ReceiptsModule,
    BillsModule,
    FinanceModule,
    PublicQueryModule,
    DocumentModule,
    NotificationModule,
    ReportingModule,
    AuditModule,
    TemplatesModule,
    PlatformAdminModule,
    DashboardModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(CorrelationMiddleware).forRoutes("*");

    if (DevAuthBypassMiddleware.isEnabled()) {
      consumer.apply(DevAuthBypassMiddleware).forRoutes("*");
    }
  }
}
