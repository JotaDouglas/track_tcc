import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showLoading(
    BuildContext context,
    GlobalKey? key, {
    String texto = '',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          // key: key,
          children: <Widget>[
            Center(
              child: Column(children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    (texto == '') ? "Aguarde..." : texto,
                    // style: TextStyle(color: Colors.blueAccent),
                  ),
                )
              ]),
            )
          ],
        );
      },
    );
  }

  static Future showAlert({
    required BuildContext context,
    required title,
    required message,
  }) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () async {
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
