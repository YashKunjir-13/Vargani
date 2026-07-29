import { Module } from "@nestjs/common";
import { WhatsAppDeliveryService } from "./whatsapp-delivery.service";
import { HttpWhatsAppProviderClient, WHATSAPP_PROVIDER_CLIENT } from "./whatsapp-provider.client";

@Module({
  providers: [
    WhatsAppDeliveryService,
    { provide: WHATSAPP_PROVIDER_CLIENT, useClass: HttpWhatsAppProviderClient },
  ],
  exports: [WhatsAppDeliveryService],
})
export class WhatsAppModule {}
