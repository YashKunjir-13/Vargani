import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { ScheduleModule } from "@nestjs/schedule";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { CronTasksService } from "./tasks/cron.tasks";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [".env.local", ".env"],
    }),
    ScheduleModule.forRoot(),
    PrismaModule,
  ],
  providers: [CronTasksService],
})
export class SchedulerModule {}
