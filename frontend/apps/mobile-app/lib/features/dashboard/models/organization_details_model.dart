class PublicOrganizationDetails {
  final String id;
  final String code;
  final String name;
  final String? addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String? postalCode;
  final String? registrationNumber;
  final String? presidentName;
  final String? primaryMobile;
  final String? primaryEmail;
  final String? bankAccountName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final String? vpa;
  final bool bankAccountConfigured;
  final bool upiConfigured;

  PublicOrganizationDetails({
    required this.id,
    required this.code,
    required this.name,
    this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    this.postalCode,
    this.registrationNumber,
    this.presidentName,
    this.primaryMobile,
    this.primaryEmail,
    this.bankAccountName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.vpa,
    required this.bankAccountConfigured,
    required this.upiConfigured,
  });

  factory PublicOrganizationDetails.fromJson(Map<String, dynamic> json) {
    return PublicOrganizationDetails(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postalCode'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      presidentName: json['presidentName'] as String?,
      primaryMobile: json['primaryMobile'] as String?,
      primaryEmail: json['primaryEmail'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      branchName: json['branchName'] as String?,
      vpa: json['vpa'] as String?,
      bankAccountConfigured: json['bankAccountConfigured'] as bool? ?? false,
      upiConfigured: json['upiConfigured'] as bool? ?? false,
    );
  }
}
