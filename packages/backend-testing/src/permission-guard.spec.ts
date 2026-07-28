import { AuthenticatedUser, PermissionGuard, PlatformRole } from '@pauti-pustak/backend-security';

function buildContext(user: AuthenticatedUser | undefined, requiredPermission: string | undefined): any {
  return {
    getHandler: () => ({}),
    getClass: () => ({}),
    switchToHttp: () => ({
      getRequest: () => ({ user }),
    }),
    __requiredPermission: requiredPermission,
  };
}

function buildReflector(requiredPermission: string | undefined): any {
  return { getAllAndOverride: () => requiredPermission };
}

describe('PermissionGuard', () => {
  it('throws ForbiddenException when the user is missing the required permission', () => {
    const guard = new PermissionGuard(buildReflector('contribution.delete'));
    const context = buildContext(
      {
        userId: 'user-1',
        platformRole: PlatformRole.USER,
        sessionId: 'session-1',
        permissions: ['receipt.viewOwn'],
      } as AuthenticatedUser,
      'contribution.delete',
    );

    expect(() => guard.canActivate(context)).toThrow('Missing required permission: contribution.delete');
  });

  it('allows the request when the user holds the required permission', () => {
    const guard = new PermissionGuard(buildReflector('contribution.delete'));
    const context = buildContext(
      {
        userId: 'user-1',
        platformRole: PlatformRole.USER,
        sessionId: 'session-1',
        permissions: ['contribution.delete'],
      } as AuthenticatedUser,
      'contribution.delete',
    );

    expect(guard.canActivate(context)).toBe(true);
  });

  it('allows the request through when the route declares no @RequirePermission metadata', () => {
    const guard = new PermissionGuard(buildReflector(undefined));
    const context = buildContext(
      {
        userId: 'user-1',
        platformRole: PlatformRole.USER,
        sessionId: 'session-1',
        permissions: [],
      } as AuthenticatedUser,
      undefined,
    );

    expect(guard.canActivate(context)).toBe(true);
  });

  it('throws UnauthorizedException when there is no authenticated user at all', () => {
    const guard = new PermissionGuard(buildReflector('contribution.delete'));
    const context = buildContext(undefined, 'contribution.delete');

    expect(() => guard.canActivate(context)).toThrow('Unauthenticated request');
  });

  it('does not grant an implicit bypass for SUPER_ADMIN -- permission checks apply to every role', () => {
    const guard = new PermissionGuard(buildReflector('contribution.delete'));
    const context = buildContext(
      {
        userId: 'admin-1',
        platformRole: PlatformRole.SUPER_ADMIN,
        sessionId: 'session-admin-1',
        permissions: [],
      } as AuthenticatedUser,
      'contribution.delete',
    );

    expect(() => guard.canActivate(context)).toThrow('Missing required permission: contribution.delete');
  });
});
