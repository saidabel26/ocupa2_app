/// Modelo de usuario basado en el schema User del API de Ocupa2.
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String nombre;
  final String? cedula;
  final String? gender;
  final DateTime? birthDate;
  final bool profileCompleted;
  final String? referralMatricula;
  final String role;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.nombre,
    this.cedula,
    this.gender,
    this.birthDate,
    required this.profileCompleted,
    this.referralMatricula,
    required this.role,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      cedula: json['cedula'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      referralMatricula: json['referralMatricula'] as String?,
      role: json['role'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'nombre': nombre,
      'cedula': cedula,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'profileCompleted': profileCompleted,
      'referralMatricula': referralMatricula,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? nombre,
    String? cedula,
    String? gender,
    DateTime? birthDate,
    bool? profileCompleted,
    String? referralMatricula,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nombre: nombre ?? this.nombre,
      cedula: cedula ?? this.cedula,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      referralMatricula: referralMatricula ?? this.referralMatricula,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
