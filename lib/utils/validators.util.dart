class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }

    if (value.length < 6 || value.length > 12) {
      return 'A senha deve ter entre 6 e 12 caracteres';
    }

    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumbers = RegExp(r'\d').hasMatch(value);

    if (!(hasLetters && hasNumbers)) {
      return 'A senha deve conter letras e números';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'A confirmação de senha é obrigatória';
    }

    if (value != password) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }

    if (value.length < 6 || value.length > 12) {
      return 'A senha deve ter entre 6 e 12 caracteres';
    }

    return null;
  }
}
