import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { JwtService } from '@nestjs/jwt';
async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const jwt = app.get(JwtService);
  const token = jwt.sign({
    sub: '41fbc2b8-2e6e-4cad-be15-b6c8df4f425f',
    userId: '41fbc2b8-2e6e-4cad-be15-b6c8df4f425f',
    platformRole: 'USER',
    permissions: []
  });
  console.log("TEST_TOKEN=" + token);
  await app.close();
}
bootstrap();
