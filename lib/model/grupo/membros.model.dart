class GroupMember {
  final int id;
  final String grupoId;
  final String userId;
  final String papel; // 'member' | 'admin'
  final String adicionadoPor;
  final DateTime adicionadoEm;

  GroupMember({
    required this.id,
    required this.grupoId,
    required this.userId,
    required this.papel,
    required this.adicionadoPor,
    required this.adicionadoEm,
  });

  factory GroupMember.fromMap(Map<String, dynamic> m) => GroupMember(
    id: m['id'] as int,
    grupoId: m['grupo_id'] as String,
    userId: m['user_id'] as String,
    papel: m['papel'] as String,
    adicionadoPor: m['adicionado_por'] as String,
    adicionadoEm: DateTime.parse(m['adicionado_em'] as String),
  );
}
