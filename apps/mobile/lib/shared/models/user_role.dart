enum UserRole {
  trustPresident,
  vicePresident,
  treasurer,
  volunteer,
  donor,
}

extension UserRoleDisplay on UserRole {
  String get label {
    return switch (this) {
      UserRole.trustPresident => 'Trust President',
      UserRole.vicePresident => 'Vice President',
      UserRole.treasurer => 'Treasurer',
      UserRole.volunteer => 'Volunteer',
      UserRole.donor => 'Donor',
    };
  }
}
