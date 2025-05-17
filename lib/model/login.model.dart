
class Login {
  int? id;
  String? email;
  String? password;
  String? username;
  String? uidUsuario;
  String? sobrenome;
  String? bio;

  Login({this.email, this.password, this.uidUsuario, this.username, this.id, this.sobrenome, this.bio});

  // Converte o objeto para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'username': username,
      'uidUsuario': uidUsuario,
      'sobrenome': sobrenome,
      'biografia': bio,
    };
  }

  // Cria um objeto Login a partir de um JSON
  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      uidUsuario: json['uidUsuario'],
      sobrenome: json['sobrenome'],
      bio: json['biografia'],
    );
  }
}
