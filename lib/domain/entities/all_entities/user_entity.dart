class UserEntity {
  final String email;
  final String name;
  final String phone;
  final String registration;
  final String password;
  final bool isAdmin;
  final String adminLocationByEmail;

  UserEntity({
    required this.email,
    required this.name,
    required this.phone,
    required this.registration,
    this.password = "", //En caso de algun uso
    this.isAdmin = false,
    this.adminLocationByEmail = ""
  });

  static final UserEntity defaultValues = UserEntity(
    email: "userTest@gmail.com",
    name: "User Test",
    phone: "8134562345",
    registration: "1974238",
  );

  // Convertir un objeto UserEntity a un mapa (para Firebase)
    Map<String, dynamic> toMap({bool includeCardPaymentMethods = true}) {
      return {
        'email': email,
        'name': name,
        'phone': phone,
        'registration': registration,
        'isAdmin': isAdmin,
        'adminLocationByEmail': adminLocationByEmail,
        if (includeCardPaymentMethods) 'cardPaymentMethods': {},
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
      isAdmin: map['isAdmin'] ?? false,
      adminLocationByEmail: map['adminLocationByEmail'] ?? ''
      // password: map['password'] ?? '',
    );
  }
}
