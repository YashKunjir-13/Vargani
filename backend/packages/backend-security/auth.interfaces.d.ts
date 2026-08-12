export declare enum PlatformRole {
    USER = "USER",
    SUPER_ADMIN = "SUPER_ADMIN"
}
export interface JwtAccessTokenPayload {
    sub: string;
    platformRole: PlatformRole;
    membershipId?: string;
    organizationId?: string;
    roleId?: string;
    tokenVersion: number;
    sessionId: string;
    iat?: number;
    exp?: number;
    iss?: string;
}
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
    generateOtp(target: string): Promise<{
        otp: string;
        expiresAt: Date;
    }>;
    verifyOtp(target: string, otp: string): Promise<boolean>;
}
