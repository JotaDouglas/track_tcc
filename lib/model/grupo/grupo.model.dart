import 'package:meta/meta.dart';

class Group {
  final String id; // uuid
  final String nome;
  final String? descricao;
  final String codigo;
  final String criadoPor; // user_id uuid
  final bool aberto;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Group({
    required this.id,
    required this.nome,
    this.descricao,
    required this.codigo,
    required this.criadoPor,
    required this.aberto,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Group.fromMap(Map<String, dynamic> m) => Group(
    id: m['id_grupo'] as String,
    nome: m['nome'] as String,
    descricao: m['descricao'] as String?,
    codigo: m['codigo'] as String,
    criadoPor: m['criado_por'] as String,
    aberto: m['aberto'] as bool? ?? false,
    criadoEm: DateTime.parse(m['criado_em'] as String),
    atualizadoEm: DateTime.parse(m['atualizado_em'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id_grupo': id,
    'nome': nome,
    'descricao': descricao,
    'codigo': codigo,
    'criado_por': criadoPor,
    'aberto': aberto,
  };
}
