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

        // ✅ Verificamos datos iniciales cada vez que se abre la BD, por si la tabla está vacía
        //await _seedData(db);
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
      await _seedData(db);
      await _seedDatacTipoEntregas(db);
      await _seedDatacEstadoEntregas(db);
    } catch (e) {
      debugPrint('❌ Error creando tablas: $e');
      throw Exception('Error creando tablas: $e');
    }
  }

  /*static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
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
  }*/
        static Future<void> _onUpgrade(
        Database db,
        int oldVersion,
        int newVersion,
      ) async {
        debugPrint("🔄 Migrando BD de v$oldVersion a v$newVersion");

        // 👉 Por ahora no hay migraciones
        /*if (oldVersion < 2) {
          await db.execute("""
            CREATE TABLE IF NOT EXISTS cTipoNotificacion (
              TipoNotificacionId INTEGER PRIMARY KEY,
              Nombre TEXT NOT NULL
            );
          """);
        }*/
        await _seedData(db);
        await _seedDatacTipoEntregas(db);
        await _seedDatacEstadoEntregas(db);
      }

  /*static Future<void> _recreateTableAlumnosActividades(Database db) async {
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
  }*/

  static Future<void> _seedData(Database db) async {
    try {
      final result = await db.rawQuery('SELECT COUNT(*) FROM cTipoNotificacion');
      final count = result.isNotEmpty ? (result.first.values.first as int) : 0;

      if (count == 0) {
        debugPrint("📥 Insertando datos iniciales en cTipoNotificacion...");
        await db.transaction((txn) async {
          await txn.rawInsert('INSERT INTO cTipoNotificacion (TipoNotificacionId, Nombre) VALUES (1, "ActividadCalificada")');
          await txn.rawInsert('INSERT INTO cTipoNotificacion (TipoNotificacionId, Nombre) VALUES (2, "ActividadCreada")');
          await txn.rawInsert('INSERT INTO cTipoNotificacion (TipoNotificacionId, Nombre) VALUES (3, "ActividadEntregada")');
          await txn.rawInsert('INSERT INTO cTipoNotificacion (TipoNotificacionId, Nombre) VALUES (4, "Aviso")');
          await txn.rawInsert('INSERT INTO cTipoNotificacion (TipoNotificacionId, Nombre) VALUES (5, "Evento")');
          await txn.rawInsert('INSERT INTO cTipoNotificacion (TipoNotificacionId, Nombre) VALUES (6, "GrupoAsignado")');
          await txn.rawInsert('INSERT INTO cTipoNotificacion (TipoNotificacionId, Nombre) VALUES (7, "MateriaAsignada")');
        });
        debugPrint("✅ Datos insertados en cTipoNotificacion");
      }
    } catch (e) {
      debugPrint('❌ Error insertando datos iniciales: $e');
    }
  }

    static Future<void> _seedDatacTipoEntregas(Database db) async {
    try {
      final result = await db.rawQuery('SELECT COUNT(*) FROM cTipoEntregas');
      final count = result.isNotEmpty ? (result.first.values.first as int) : 0;

      if (count == 0) {
        debugPrint("📥 Insertando datos iniciales en cTipoEntregas...");
        await db.transaction((txn) async {
          await txn.rawInsert('INSERT INTO cTipoEntregas (TipoActividadId, Nombre) VALUES (1, "Texto")');
          await txn.rawInsert('INSERT INTO cTipoEntregas (TipoActividadId, Nombre) VALUES (2, "Enlace")');
          await txn.rawInsert('INSERT INTO cTipoEntregas (TipoActividadId, Nombre) VALUES (3, "Archivo")');
          await txn.rawInsert('INSERT INTO cTipoEntregas (TipoActividadId, Nombre) VALUES (4, "Mixto")');
        });
        debugPrint("✅ Datos insertados en cTipoEntregas");
      }
    } catch (e) {
      debugPrint('❌ Error insertando datos iniciales: $e');
    }
  }
    static Future<void> _seedDatacEstadoEntregas(Database db) async {
    try {
      final result = await db.rawQuery('SELECT COUNT(*) FROM cEstadoEntregas');
      final count = result.isNotEmpty ? (result.first.values.first as int) : 0;

      if (count == 0) {
        debugPrint("📥 Insertando datos iniciales en cEstadoEntregas...");
        await db.transaction((txn) async {
          await txn.rawInsert('INSERT INTO cEstadoEntregas (EstadoEntregaId, Nombre) VALUES (1, "Enviado")');
          await txn.rawInsert('INSERT INTO cEstadoEntregas (EstadoEntregaId, Nombre) VALUES (2, "Borrador")');
          await txn.rawInsert('INSERT INTO cEstadoEntregas (EstadoEntregaId, Nombre) VALUES (3, "Calificado")');
        });
        debugPrint("✅ Datos insertados en cEstadoEntregas");
      }
    } catch (e) {
      debugPrint('❌ Error insertando datos iniciales: $e');
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
