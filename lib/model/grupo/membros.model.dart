class GroupMember {
  final int id;
  final String grupoId;
  final String userId;
  final String papel; // 'member' | 'admin'
  final String adicionadoPor;
  final DateTime adicionadoEm;
  final String? nome;
  final String? sobrenome;
  final String? messageId;

  GroupMember({
    required this.id,
    required this.grupoId,
    required this.userId,
    required this.papel,
    required this.adicionadoPor,
    required this.adicionadoEm,
    this.nome,
    this.sobrenome,
    this.messageId,
  });

  factory GroupMember.fromMap(Map<String, dynamic> m) {
    final usuarios = m['usuarios'];
    return GroupMember(
      id: m['id'] as int,
      grupoId: m['grupo_id'] as String,
      userId: m['user_id'] as String,
      papel: m['papel'] as String,
      adicionadoPor: m['adicionado_por'] as String,
      adicionadoEm: DateTime.parse(m['adicionado_em'] as String),
      nome: usuarios != null ? usuarios['nome'] as String? : null,
      sobrenome: usuarios != null ? usuarios['sobrenome'] as String? : null,
      messageId: usuarios != null ? usuarios['message_id'] as String? : null,
    );
  }
}
