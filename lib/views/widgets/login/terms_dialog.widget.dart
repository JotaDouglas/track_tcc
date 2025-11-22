import 'package:flutter/material.dart';

class TermsDialog {
  static void show({
    required BuildContext context,
    required VoidCallback onAccept,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Termo de Consentimento e Compartilhamento de Dados",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ao utilizar este aplicativo, o usuário declara estar ciente e de acordo com a coleta e o tratamento de dados de localização, identificação e autenticação estritamente para fins de rastreamento pessoal e compartilhamento voluntário com contatos autorizados.",
                  style: TextStyle(fontSize: 14, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Nenhuma informação é tornada pública ou utilizada para fins comerciais.",
                  style: TextStyle(fontSize: 14, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                const Text(
                  "O usuário pode encerrar o compartilhamento a qualquer momento e solicitar a exclusão definitiva de seus dados conforme os direitos previstos na Lei nº 13.709/2018 (Lei Geral de Proteção de Dados - LGPD).",
                  style: TextStyle(fontSize: 14, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                Text(
                  "Ao clicar em \"Aceito os termos\", o usuário consente com o uso dos dados nos limites descritos acima.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Fechar",
                style: TextStyle(color: Colors.orange[900]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onAccept();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[900],
              ),
              child: const Text(
                "Aceitar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
