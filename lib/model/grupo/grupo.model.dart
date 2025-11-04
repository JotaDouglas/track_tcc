import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';

class Group {
  final String id;
  final String nome;
  final String? descricao;
  final String codigo;
  final String criadoPor;
  final bool aberto;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final dynamic geoData; // <-- Adicione isto
  List<GroupMember>? membros;

  Group({
    required this.id,
    required this.nome,
    this.descricao,
    required this.codigo,
    required this.criadoPor,
    required this.aberto,
    required this.criadoEm,
    required this.atualizadoEm,
    this.geoData, // <-- Adicione isto
    this.membros,
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

  factory Group.fromJson(Map<String, dynamic> m) => Group(
        id: m['grupo_id'] as String,
        nome: m['grupo_name'] as String,
        descricao: null,
        codigo: '',
        criadoPor: '',
        aberto: m['aberto'] as bool? ?? false,
        criadoEm: DateTime.now(),
        atualizadoEm:
            DateTime.tryParse(m['atualizado_em'] ?? '') ?? DateTime.now(),
        geoData: m['geo_data'] != null ? jsonDecode(m['geo_data']) : null,
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
