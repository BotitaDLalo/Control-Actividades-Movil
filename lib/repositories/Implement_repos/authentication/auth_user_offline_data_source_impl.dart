import 'package:aprende_mas/config/data/querys.dart';
import 'package:aprende_mas/repositories/Interface_repos/authentication/auth_user_offline_data_source.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/data/db_local.dart';

class AuthUserOfflineDataSourceImpl implements AuthUserOfflineDataSource {
  static const table = 'tbUsuarioActivo';

  @override
  Future<void> deleteUser() async {
    try {
      final db = await DbLocal.database;
      final lsQuerys = Querys.querysDeleteTables();
      for (var q in lsQuerys) {
        await db.execute(q);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updateUser(String fechaLimiteActivo) async {
    try {
      final db = await DbLocal.database;
      final query = Querys.querytbUsuarioActivoUpdate();
      await db.rawUpdate(query, [fechaLimiteActivo]);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Map<String, Object?>>> getUser() async {
    try {
      final db = await DbLocal.database;
      List<Map<String, Object?>> user = await db.query(table, limit: 1);
      return user;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<void> insertUser(int usuarioId, String nombreUsuario, String correo,
      String fechaLimiteActivo, rol) async {
    try {
      debugPrint('[insertUser] Intentando insertar usuario: $usuarioId, $nombreUsuario, $correo, $fechaLimiteActivo, $rol');
      final db = await DbLocal.database;
      final query = Querys.querytbUsuarioActivoInsert();

      await db.transaction(
        (txn) async {
          int res = await txn.rawInsert(query,
              [usuarioId, nombreUsuario, correo, fechaLimiteActivo, rol]);
          debugPrint('[insertUser] Resultado de rawInsert: $res');
        },
      );
      debugPrint('[insertUser] Usuario insertado correctamente en tbUsuarioActivo.');
    } catch (e) {
      debugPrint('[insertUser] Error al insertar usuario: $e');
      rethrow;
    }
  }
}
