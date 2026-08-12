import { Test, TestingModule } from '@nestjs/testing';
import { AppModule } from './app.module';
import { JwtService } from '@nestjs/jwt';
describe('Generate Token', () => {
  let jwtService: JwtService;
  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    jwtService = moduleFixture.get<JwtService>(JwtService);
  });
  it('should print token', async () => {
    const token = jwtService.sign({
      sub: '41fbc2b8-2e6e-4cad-be15-b6c8df4f425f',
      userId: '41fbc2b8-2e6e-4cad-be15-b6c8df4f425f',
      platformRole: 'SUPER_ADMIN',
      permissions: ['*']
    });
    console.log("TEST_TOKEN=" + token);
  });
});
