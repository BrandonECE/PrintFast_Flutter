class UserEntity {
  final String email;
  final String name;
  final String phone;
  final String registration;
  final String password;
  final bool isAdmin;

  UserEntity({
    required this.email,
    required this.name,
    required this.phone,
    required this.registration,
    this.password = "", //En caso de algun uso
    this.isAdmin = false,
  });


  static final UserEntity defaultValues = UserEntity(
      email: "userTest@gmail.com",
      name: "User Test",
      phone: "8134562345",
      registration: "1974238",
    );

  // Convertir un objeto UserEntity a un mapa (para Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'registration': registration,
      'isAdmin': isAdmin
      // 'password': password,
    };
  }

  // Crear un objeto UserEntity desde un mapa (por ejemplo, desde Firebase)
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      registration: map['registration'] ?? '',
      isAdmin: map['isAdmin'] ?? false
      // password: map['password'] ?? '',
    );
  }
}
