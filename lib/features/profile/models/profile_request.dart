/// DTO para PUT /me/profile.
/// NOTA: el campo "nombre" es de solo lectura en el backend, nunca se envía.
class ProfileRequest {
  final String firstName;
  final String lastName;
  final String cedula;
  final String gender;
  final String birthDate; // Formato "YYYY-MM-DD"

  const ProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.cedula,
    required this.gender,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'cedula': cedula,
      'gender': gender,
      'birthDate': birthDate,
    };
  }
}
