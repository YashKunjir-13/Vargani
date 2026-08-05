import { Module } from "@nestjs/common";
import { APP_GUARD } from "@nestjs/core";
import { PermissionGuard, TenantGuard } from "@pauti-pustak/backend-security";
import { FestivalYearModule } from "./festival-year/festival-year.module";
import { RbacModule } from "./rbac/rbac.module";
import { SequenceModule } from "./sequence/sequence.module";
import { StorageModule } from "./storage/storage.module";
import { TenancyModule } from "./tenancy/tenancy.module";
import { WhatsAppModule } from "./whatsapp/whatsapp.module";

/**
 * Shared infrastructure every feature module depends on. Registers
 * TenantGuard and PermissionGuard as APP_GUARD, so every route in the
 * application is tenant-checked and permission-checked by default --
 * routes that must stay unauthenticated (health checks, login) opt out
 * explicitly with @Public() rather than the other way around.
 */
@Module({
  imports: [
    TenancyModule,
    RbacModule,
    FestivalYearModule,
    SequenceModule,
    WhatsAppModule,
    StorageModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: TenantGuard },
    { provide: APP_GUARD, useClass: PermissionGuard },
  ],
  exports: [TenancyModule, RbacModule, FestivalYearModule, SequenceModule, WhatsAppModule, StorageModule],
})
export class CommonModule {}
