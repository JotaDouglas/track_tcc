import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

final db = FirebaseDatabase.instance.ref();

Future<void> salvarPerfilUsuario(String nome, String fotoUrl) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  await db.child('users/$uid').set({
    'name': nome,
    'email': FirebaseAuth.instance.currentUser!.email,
    'photoUrl': fotoUrl,
  });
}

Future<Map?> carregarPerfilUsuario() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final snapshot = await db.child('users/$uid').get();

  if (snapshot.exists) {
    return Map<String, dynamic>.from(snapshot.value as Map);
  } else {
    return null;
  }
}

Future<void> deletarPerfilUsuario() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  await db.child('users/$uid').remove();
}
