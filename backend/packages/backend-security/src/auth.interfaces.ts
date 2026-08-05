// Platform-wide role. Organization-level authorization is NOT modeled here --
// per-organization custom roles (Owner/President/Secretary/Treasurer/Donation
// Collector/Expense Approver/Auditor/Member, plus org-defined custom roles)
// live in the tenant-service Prisma models (OrganizationRole/Permission/
// RolePermission) and are resolved by roleId at request time, not carried
// as a fixed enum here.
export enum PlatformRole {
  USER = "USER",
  SUPER_ADMIN = "SUPER_ADMIN",
}

// Matches the Auth module spec exactly: "Issue 15-minute Access JWTs
// containing userId, platformRole, membershipId, organizationId, roleId,
// tokenVersion, and sessionId." Permission codes are deliberately NOT
// embedded in the token -- they are resolved server-side from roleId on
// each request (see PermissionGuard), so a role/permission change takes
// effect without waiting for token expiry.
export interface JwtAccessTokenPayload {
  sub: string; // userId
  platformRole: PlatformRole;
  membershipId?: string; // absent for a platform-only session (e.g. Super Admin with no organization membership)
  organizationId?: string;
  roleId?: string;
  tokenVersion: number;
  sessionId: string;
  iat?: number;
  exp?: number;
  iss?: string;
}

// The shape NestJS attaches to `request.user` after JWT verification.
// `permissions` is populated by the auth layer from `roleId` (a
// RolePermission/Permission lookup) before any guard runs -- it is never
// trusted from the token or the client directly.
export interface AuthenticatedUser {
  userId: string;
  platformRole: PlatformRole;
  membershipId?: string;
  organizationId?: string;
  roleId?: string;
  sessionId: string;
  permissions: string[];
}

export interface RefreshSession {
  sessionId: string;
  userId: string;
  organizationId?: string;
  refreshTokenHash: string;
  expiresAt: Date;
  isRevoked: boolean;
  replacedBySessionId?: string;
}

export interface OtpProvider {
  generateOtp(target: string): Promise<{ otp: string; expiresAt: Date }>;
  verifyOtp(target: string, otp: string): Promise<boolean>;
}
