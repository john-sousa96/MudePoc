class User {
  int? id;
  String name;
  String email;
  String phone;
  String birthDate;
  String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.password,
  });

  // Método toMap para conversão para o banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'password': password,
    };
  }

  // Factory method para criar User a partir de Map
  factory User.fromMap(Map<String, dynamic> map, [int? id]) {
    return User(
      id: id ?? map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      birthDate: map['birthDate'],
      password: map['password'],
    );
  }

  // Método copy para criar cópias com valores atualizados
  User copy({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      password: password ?? this.password,
    );
  }
}