enum LoginRole { mandal, donor }

class AuthOrganization {
  const AuthOrganization({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
  });

  factory AuthOrganization.fromJson(Map<String, dynamic> json) => AuthOrganization(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        status: json['status'] as String,
      );

  final String id;
  final String name;
  final String code;
  final String status;
}

class AuthDonorProfile {
  const AuthDonorProfile({required this.id, required this.fullName, required this.status});

  factory AuthDonorProfile.fromJson(Map<String, dynamic> json) => AuthDonorProfile(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        status: json['status'] as String,
      );

  final String id;
  final String fullName;
  final String status;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.displayName,
    required this.primaryMobile,
    required this.primaryEmail,
    required this.preferredLanguage,
    required this.platformRole,
    required this.status,
    required this.organization,
    required this.donorProfile,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        primaryMobile: json['primaryMobile'] as String?,
        primaryEmail: json['primaryEmail'] as String?,
        preferredLanguage: json['preferredLanguage'] as String,
        platformRole: json['platformRole'] as String,
        status: json['status'] as String,
        organization: json['organization'] == null
            ? null
            : AuthOrganization.fromJson(json['organization'] as Map<String, dynamic>),
        donorProfile: json['donorProfile'] == null
            ? null
            : AuthDonorProfile.fromJson(json['donorProfile'] as Map<String, dynamic>),
      );

  final String id;
  final String displayName;
  final String? primaryMobile;
  final String? primaryEmail;
  final String preferredLanguage;
  final String platformRole;
  final String status;
  final AuthOrganization? organization;
  final AuthDonorProfile? donorProfile;

  bool get isTrustOwner => organization != null;
  bool get isDonor => donorProfile != null;
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        accessTokenExpiresAt: DateTime.parse(json['accessTokenExpiresAt'] as String),
      );

  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
}
