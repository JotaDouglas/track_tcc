import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';

abstract class GroupRepository {
  Future<Group> createGroup({required String nome, String? descricao, required String criadoPor, bool aberto});
  Future<Group?> getGroupByCode(String codigo);
  Future<void> addMember({required String grupoId, required String userId, required String adicionadoPor, String papel});
  Future<void> removeMember({required String grupoId, required String userId});
  Future<List<Group>> listGroupsForUser(String userId);
  Future<List<GroupMember>> listMembers(String grupoId);
  Future<void> promoteToAdmin({required String grupoId, required String userId});
  Stream<dynamic> watchGroup(String grupoId); // opcional: realtime
}
