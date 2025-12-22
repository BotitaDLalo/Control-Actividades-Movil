import 'package:aprende_mas/config/data/querys.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class DbLocal {
  static Database? _database;
  static const String _databaseName = 'Movil.db';
  static const int _databaseVersion = 1;

  // Singleton getter para la base de datos
  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Método para cerrar la base de datos (usar con cuidado)
  static Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  // Método para verificar si la BD está abierta
  static bool get isDatabaseOpen {
    return _database != null && _database!.isOpen;
  }

  static Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      String path = join(databasesPath, _databaseName);

      bool exist = await File(path).exists();

      if (!exist) {
        Database db = await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
        );

        debugPrint("✅ BD CREADA: $_databaseName");
        return db;
      } else {
        Database db = await openDatabase(
          path,
          version: _databaseVersion,
          onUpgrade: _onUpgrade,
        );

        debugPrint("✅ BD ABIERTA: $_databaseName");
        return db;
      }
    } catch (e) {
      debugPrint('❌ Error inicializando BD: $e');
      throw Exception('Error inicializando base de datos: $e');
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    try {
      List<String> lsQuerys = Querys.querysCreateTables();
      for (var query in lsQuerys) {
        await db.execute(query);
      }
      debugPrint("✅ Tablas creadas exitosamente");
    } catch (e) {
      debugPrint('❌ Error creando tablas: $e');
      throw Exception('Error creando tablas: $e');
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aquí se pueden agregar migraciones futuras si es necesario
    debugPrint("🔄 Migrando BD de v$oldVersion a v$newVersion");
  }

  // Método legacy para compatibilidad (deprecated)
  @deprecated
  static Future<Database> initDatabase() async {
    return await database;
  }
}
