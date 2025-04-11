
class Login {
  String? id;
  String? email;
  String? password;
  String? username;
  String? uidUsuario;

  Login({this.email, this.password, this.uidUsuario, this.username, this.id});

  // Converte o objeto para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'username': username,
      'uidUsuario': uidUsuario,
    };
  }

  // Cria um objeto Login a partir de um JSON
  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      username: json['username'],
      uidUsuario: json['uidUsuario'],
    );
  }
}
