/// Modelo de usuario EnBici
class UserModel {
  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.phone,
    required this.name,
    required this.role,
    required this.verificationStatus,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.epsName,
    this.rating = 5.0,
    this.totalRides = 0,
  });

  final String id;
  final String firebaseUid;
  final String phone;
  final String name;
  final UserRole role;
  final VerificationStatus verificationStatus;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? epsName;
  final double rating;
  final int totalRides;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        firebaseUid: json['firebase_uid'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String,
        role: UserRole.fromString(json['role'] as String),
        verificationStatus: VerificationStatus.fromString(
          json['verification_status'] as String,
        ),
        emergencyContactName: json['emergency_contact_name'] as String?,
        emergencyContactPhone: json['emergency_contact_phone'] as String?,
        epsName: json['eps_name'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        totalRides: json['total_rides'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firebase_uid': firebaseUid,
        'phone': phone,
        'name': name,
        'role': role.value,
        'verification_status': verificationStatus.value,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'eps_name': epsName,
        'rating': rating,
        'total_rides': totalRides,
      };

  bool get isProfileComplete =>
      name.isNotEmpty &&
      emergencyContactPhone != null &&
      emergencyContactPhone!.isNotEmpty;
}

enum UserRole {
  cyclist('cyclist'),
  motorcyclist('motorcyclist'),
  driver('driver');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String s) =>
      UserRole.values.firstWhere((r) => r.value == s,
          orElse: () => UserRole.cyclist);

  String get displayName {
    switch (this) {
      case cyclist:
        return 'Ciclista';
      case motorcyclist:
        return 'Acompañante en Moto';
      case driver:
        return 'Conductor de Auto';
    }
  }
}

enum VerificationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  suspended('suspended');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus fromString(String s) =>
      VerificationStatus.values.firstWhere((v) => v.value == s,
          orElse: () => VerificationStatus.pending);
}
