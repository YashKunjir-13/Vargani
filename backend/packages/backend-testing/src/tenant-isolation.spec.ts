import { AuthenticatedUser, PlatformRole, TenantGuard } from '@pauti-pustak/backend-security';

describe('TenantIsolationGuard', () => {
  let guard: TenantGuard;

  beforeEach(() => {
    guard = new TenantGuard();
  });

  it('should allow SUPER_ADMIN without tenant header', () => {
    const context: any = {
      getHandler: () => ({}),
      getClass: () => ({}),
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
      getHandler: () => ({}),
      getClass: () => ({}),
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

  it('should reject a request whose header organizationId does not match the authenticated user', () => {
    const context: any = {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({
        getRequest: () => ({
          user: {
            userId: 'user-1',
            platformRole: PlatformRole.USER,
            organizationId: 'org-real',
            sessionId: 'session-user-1',
            permissions: ['event.view'],
          } as AuthenticatedUser,
          headers: { 'x-tenant-id': 'org-forged' },
          body: {},
          query: {},
        }),
      }),
    };

    expect(() => guard.canActivate(context)).toThrow('Tenant isolation violation: organizationId mismatch');
  });

  it('should reject a request whose body organizationId does not match the authenticated user', () => {
    const context: any = {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({
        getRequest: () => ({
          user: {
            userId: 'user-1',
            platformRole: PlatformRole.USER,
            organizationId: 'org-real',
            sessionId: 'session-user-1',
            permissions: ['contribution.create'],
          } as AuthenticatedUser,
          headers: {},
          body: { organizationId: 'org-forged' },
          query: {},
        }),
      }),
    };

    expect(() => guard.canActivate(context)).toThrow('Tenant isolation violation: organizationId mismatch');
  });

  it('should reject a request whose query organizationId does not match the authenticated user', () => {
    const context: any = {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({
        getRequest: () => ({
          user: {
            userId: 'user-1',
            platformRole: PlatformRole.USER,
            organizationId: 'org-real',
            sessionId: 'session-user-1',
            permissions: ['receipt.viewAll'],
          } as AuthenticatedUser,
          headers: {},
          body: {},
          query: { organizationId: 'org-forged' },
        }),
      }),
    };

    expect(() => guard.canActivate(context)).toThrow('Tenant isolation violation: organizationId mismatch');
  });

  it('should allow and pin request.tenantId when the claimed organizationId matches the authenticated user', () => {
    const request: any = {
      user: {
        userId: 'user-1',
        platformRole: PlatformRole.USER,
        organizationId: 'org-real',
        sessionId: 'session-user-1',
        permissions: ['receipt.viewAll'],
      } as AuthenticatedUser,
      headers: { 'x-tenant-id': 'org-real' },
      body: {},
      query: {},
    };
    const context: any = {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({ getRequest: () => request }),
    };

    expect(guard.canActivate(context)).toBe(true);
    expect(request.tenantId).toBe('org-real');
  });
});
