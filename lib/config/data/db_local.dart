import 'package:aprende_mas/config/data/querys.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class DbLocal {
    /// Método temporal para depuración: imprime el contenido de tbUsuarioActivo
    static Future<void> printUsuariosActivos() async {
      try {
        final db = await database;
        final usuarios = await db.rawQuery('SELECT * FROM tbUsuarioActivo');
        debugPrint('Contenido de tbUsuarioActivo:');
        for (var usuario in usuarios) {
          debugPrint(usuario.toString());
        }
        if (usuarios.isEmpty) {
          debugPrint('La tabla tbUsuarioActivo está vacía.');
        }
      } catch (e) {
        debugPrint('Error al leer tbUsuarioActivo: $e');
      }
    }
  static Database? _database;
  static const String _databaseName = 'Movil.db';
  static const int _databaseVersion = 2;  // ✅ Incrementado para migración

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
        debugPrint("✅ Versión BD: $_databaseVersion");
        print('📦 Creando base de datos local');
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
    debugPrint("🔄 Migrando BD de v$oldVersion a v$newVersion");

    if (oldVersion < 2) {
      // Migración v1 -> v2: Cambiar EstatusEntrega de BOOLEAN a INTEGER
      try {
        // SQLite no permite ALTER COLUMN directamente para cambiar tipos
        // Necesitamos recrear la tabla con el nuevo esquema

        // 1. Crear tabla temporal con nuevo esquema
        await db.execute('''
          CREATE TABLE tbAlumnosActividades_temp(
            AlumnoActividadId INTEGER PRIMARY KEY,
            ActividadId INTEGER,
            AlumnoId INTEGER,
            FechaEntrega TEXT,
            EstatusEntrega INTEGER,
            FOREIGN KEY (ActividadId) REFERENCES tbActividades(ActividadId)
          );
        ''');

        // 2. Copiar datos convirtiendo booleanos a enteros
        await db.execute('''
          INSERT INTO tbAlumnosActividades_temp(AlumnoActividadId, ActividadId, AlumnoId, FechaEntrega, EstatusEntrega)
          SELECT AlumnoActividadId, ActividadId, AlumnoId, FechaEntrega,
                 CASE WHEN EstatusEntrega = 1 THEN 1 ELSE 0 END
          FROM tbAlumnosActividades;
        ''');

        // 3. Eliminar tabla antigua
        await db.execute('DROP TABLE tbAlumnosActividades;');

        // 4. Renombrar tabla temporal
        await db.execute('ALTER TABLE tbAlumnosActividades_temp RENAME TO tbAlumnosActividades;');

        debugPrint("✅ Migración v1->v2 completada: BOOLEAN -> INTEGER");
      } catch (e) {
        debugPrint('❌ Error en migración v1->v2: $e');
        // En caso de error, intentar recrear la tabla desde cero
        await _recreateTableAlumnosActividades(db);
      }
    }
  }

  static Future<void> _recreateTableAlumnosActividades(Database db) async {
    try {
      // Eliminar tabla si existe
      await db.execute('DROP TABLE IF EXISTS tbAlumnosActividades;');

      // Recrear con esquema correcto
      await db.execute('''
        CREATE TABLE tbAlumnosActividades(
          AlumnoActividadId INTEGER PRIMARY KEY,
          ActividadId INTEGER,
          AlumnoId INTEGER,
          FechaEntrega TEXT,
          EstatusEntrega INTEGER,
          FOREIGN KEY (ActividadId) REFERENCES tbActividades(ActividadId)
        );
      ''');

      debugPrint("✅ Tabla tbAlumnosActividades recreada con esquema correcto");
    } catch (e) {
      debugPrint('❌ Error recreando tabla tbAlumnosActividades: $e');
      rethrow;
    }
  }

  // Método legacy para compatibilidad (deprecated)
  @deprecated
  static Future<Database> initDatabase() async {
    return await database;
  }

  //Método para eliminar la base de datos (usar con cuidado)
    /*static Future<void> deleteDatabaseLocal() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      // Cerrar BD si está abierta
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }

      // Eliminar archivo físico
      await deleteDatabase(path);

      debugPrint('🗑️ Base de datos eliminada correctamente');
    } catch (e) {
      debugPrint('❌ Error eliminando la base de datos: $e');
    }
  }*/
}
