class GroupsCreated {
  final int groupId;
  final String groupName;

  GroupsCreated({required this.groupId, required this.groupName});

  static List<GroupsCreated> groupsCreatedToEntityList(
      List<Map<String, dynamic>> groupsCreated) {
    List<GroupsCreated> lsGroups = groupsCreated.map((e) {
      return GroupsCreated(groupId: e['GrupoId'], groupName: e['NombreGrupo']);
    }).toList();
    return lsGroups;
  }
}
