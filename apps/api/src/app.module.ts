import { MiddlewareConsumer, Module, NestModule } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { ThrottlerModule } from "@nestjs/throttler";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { CorrelationMiddleware } from "@pauti-pustak/backend-observability";
import { AuthModule } from "./auth/auth.module";
import { HealthModule } from "./health/health.module";
import { TenantModule } from "./tenant/tenant.module";
import { EventModule } from "./event/event.module";
import { VolunteerModule } from "./volunteer/volunteer.module";
import { ContributorModule } from "./contributor/contributor.module";
import { ContributionModule } from "./contribution/contribution.module";
import { PaymentModule } from "./payment/payment.module";
import { FinanceModule } from "./finance/finance.module";
import { DocumentModule } from "./document/document.module";
import { NotificationModule } from "./notification/notification.module";
import { ReportingModule } from "./reporting/reporting.module";
import { AuditModule } from "./audit/audit.module";

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
    HealthModule,
    AuthModule,
    TenantModule,
    EventModule,
    VolunteerModule,
    ContributorModule,
    ContributionModule,
    PaymentModule,
    FinanceModule,
    DocumentModule,
    NotificationModule,
    ReportingModule,
    AuditModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(CorrelationMiddleware).forRoutes("*");
  }
}
