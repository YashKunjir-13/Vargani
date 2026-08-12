class PublicOrganization {
  final String id;
  final String code;
  final String name;
  final String city;
  final String state;
  final String? logoDocumentId;
  final String? primaryMobile;
  final String? primaryEmail;

  const PublicOrganization({
    required this.id,
    required this.code,
    required this.name,
    required this.city,
    required this.state,
    this.logoDocumentId,
    this.primaryMobile,
    this.primaryEmail,
  });

  factory PublicOrganization.fromJson(Map<String, dynamic> json) {
    return PublicOrganization(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      logoDocumentId: json['logoDocumentId'] as String?,
      primaryMobile: json['primaryMobile'] as String?,
      primaryEmail: json['primaryEmail'] as String?,
    );
  }
}
