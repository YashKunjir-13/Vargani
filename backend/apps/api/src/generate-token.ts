import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { AuthService } from './auth/auth.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const authService = app.get(AuthService);
  const session = await (authService as any).issueSession({
    userId: '6d80f5e1-5c44-45ad-8def-724883705a5d',
    organizationId: '09dcf9e1-aa61-4143-996e-a57d3514cbd6',
    roleId: '38436902-df80-4f04-ad28-21f0d7c3513d',
    membershipId: '592091bd-84ed-4b41-9280-829afbd17862',
  });
  console.log("TOKEN=" + session.accessToken);
  await app.close();
}
bootstrap();
