import { AuthenticatedUser, PlatformRole, TenantGuard } from '@pauti-pustak/backend-security';

describe('TenantIsolationGuard', () => {
  let guard: TenantGuard;

  beforeEach(() => {
    guard = new TenantGuard();
  });

  it('should allow SUPER_ADMIN without tenant header', () => {
    const context: any = {
      switchToHttp: () => ({
        getRequest: () => ({
          user: {
            userId: 'admin-1',
            platformRole: PlatformRole.SUPER_ADMIN,
            sessionId: 'session-admin-1',
            permissions: [],
          } as AuthenticatedUser,
          headers: {},
        }),
      }),
    };

    expect(guard.canActivate(context)).toBe(true);
  });

  it('should throw ForbiddenException when non-admin has no tenant context', () => {
    const context: any = {
      switchToHttp: () => ({
        getRequest: () => ({
          user: {
            userId: 'user-1',
            platformRole: PlatformRole.USER,
            sessionId: 'session-user-1',
            permissions: ['event.view'],
          } as AuthenticatedUser,
          headers: {},
        }),
      }),
    };

    expect(() => guard.canActivate(context)).toThrow('Tenant isolation violation: Tenant ID missing');
  });
});
