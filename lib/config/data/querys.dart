class Querys {
  static List<String> querysCreateTables() => [
        """
          CREATE TABLE cEstadoEntregas (
          EstadoEntregaId INTEGER PRIMARY KEY,
          Nombre TEXT NOT NULL
        );
        """
 ,

        """
        CREATE TABLE cTipoEntregas (
          TipoActividadId INTEGER PRIMARY KEY,
          Nombre TEXT NOT NULL
        );
        """,
        """
        CREATE TABLE cTipoNotificacion (
          TipoNotificacionId INTEGER PRIMARY KEY,
          Nombre TEXT NOT NULL
        );
        """,
        """
        CREATE TABLE tbUsuarioActivo (
          UsuarioId INTEGER PRIMARY KEY CHECK (UsuarioId = 1),
          NombreUsuario TEXT NOT NULL,
          Correo TEXT NOT NULL,
          FechaLimiteActivo TEXT,
          Rol TEXT NOT NULL
        );
        """,
        """
        CREATE TABLE tbGrupos (
        GrupoId INTEGER PRIMARY KEY,
        NombreGrupo TEXT NOT NULL,
        Descripcion TEXT,
        CodigoAcceso TEXT,
        CodigoColor TEXT
        );
        """,
        """
        CREATE TABLE tbMaterias(
        MateriaId INTEGER PRIMARY KEY,
        NombreMateria TEXT NOT NULL,
        Descripcion TEXT,
        CodigoColor TEXT,
        CodigoAcceso TEXT
        );
        """,
        """
        CREATE TABLE tbActividades ( ActividadId INTEGER PRIMARY KEY,
          NombreActividad TEXT NOT NULL,
          Descripcion TEXT NOT NULL,
          FechaCreacion TEXT NOT NULL,
          FechaLimite TEXT NOT NULL,
          Puntaje INTEGER NOT NULL,
          MateriaId INTEGER,
          Enviado INTEGER,
          FechaProgramada TEXT,
          FOREIGN KEY (MateriaId) REFERENCES tbMaterias(MateriaId));
        """,
        """
        CREATE TABLE tbAvisos (
          AvisoId INTEGER PRIMARY KEY,
          UsuarioId INTEGER NOT NULL,
          Titulo TEXT NOT NULL,
          Descripcion TEXT NOT NULL,
          GrupoId INTEGER,
          MateriaId INTEGER,
          FechaCreacion TEXT NOT NULL,
          FOREIGN KEY (UsuarioId) REFERENCES tbUsuarioActivo(UsuarioId)
        );
        """,
        """
        CREATE TABLE tbEntregableActividadAlumno (
          EntregaActividadAlumnoId INTEGER PRIMARY KEY,
          ActividadId INTEGER NOT NULL,
          UsuarioId INTEGER NOT NULL,
          FechaEntrega TEXT NOT NULL,
          EstadoEntregaId INTEGER NOT NULL,
          FechaCalificado TEXT,
          FOREIGN KEY (ActividadId) REFERENCES tbActividades(ActividadId),
          FOREIGN KEY (UsuarioId) REFERENCES tbUsuarioActivo(UsuarioId)
        );
        """,
        """
        CREATE TABLE tbEntregables (
          EntregableId INTEGER PRIMARY KEY,
          EntregaActividadAlumnoId INTEGER NOT NULL,
          TipoEntregaId INTEGER NOT NULL,
          Contenido TEXT,
          Calificacion INTEGER,
          FechaCalificado TEXT,
          FOREIGN KEY (EntregaActividadAlumnoId)
            REFERENCES tbEntregableActividadAlumno(EntregaActividadAlumnoId),
          FOREIGN KEY (TipoEntregaId)
            REFERENCES cTipoEntregas(TipoActividadId)
        );
        """
        ,

        """
        CREATE TABLE tbGruposMaterias(GrupoMateriaId INTEGER PRIMARY KEY, 
                                     GrupoId INTEGER,
                                     MateriaId INTEGER,
                                     FOREIGN KEY (GrupoId) REFERENCES tbGrupos(GrupoId),
                                     FOREIGN KEY (MateriaId) REFERENCES tbMaterias(MateriaId)
                                     );
        """,

        """
        CREATE TABLE tbNotificaciones(
          NotificacionId INTEGER PRIMARY KEY,
          UsuarioId INTEGER NOT NULL,
          MessageId TEXT NOT NULL,
          Titulo TEXT NOT NULL,
          Cuerpo TEXT NOT NULL,
          FechaRecibido TEXT NOT NULL,
          TipoNotificacionId INTEGER NOT NULL,
          MateriaId INTEGER,
          GrupoId INTEGER,
          FOREIGN KEY (UsuarioId) REFERENCES tbUsuarioActivo(UsuarioId),
          FOREIGN KEY (TipoNotificacionId) REFERENCES cTipoNotificacion(TipoNotificacionId),
          FOREIGN KEY (MateriaId) REFERENCES tbMaterias(MateriaId),
          FOREIGN KEY (GrupoId) REFERENCES tbGrupos(GrupoId)
        );
        """
      ];

    static List<String> querysDeleteTables() => [
      "DELETE FROM tbNotificaciones;",
      "DELETE FROM tbEntregableActividadAlumno;",
      "DELETE FROM tbGruposMaterias;",
      "DELETE FROM tbActividades;",
      "DELETE FROM tbAvisos;",
      "DELETE FROM tbMaterias;",
      "DELETE FROM tbGrupos;",
      "DELETE FROM tbUsuarioActivo;",
    ];

//& tbUsuarioActivo
  static String querytbUsuarioActivoInsert() =>
      "INSERT OR REPLACE INTO tbUsuarioActivo (UsuarioId, NombreUsuario, Correo, FechaLimiteActivo, Rol) VALUES (1, ?, ?, ?, ?)";

  static String querytbUsuarioActivoUpdate() =>
      "UPDATE tbUsuarioActivo SET FechaLimiteActivo = ?";

//& tbNotificaciones
  static String querytbNotificacionesInsert() =>
      "INSERT INTO tbNotificaciones (UsuarioId, MessageId, Titulo, Cuerpo, FechaRecibido, TipoNotificacionId, MateriaId, GrupoId) VALUES (?,?,?,?,?,?,?,?);";

  static String querytbNotificacionesDeleteWhere() =>
      "DELETE FROM tbNotificaciones WHERE FechaRecibido = ?";

//& tbGrupos
  static String querytbGruposInsert() => "INSERT INTO tbGrupos (GrupoId, NombreGrupo, Descripcion, CodigoAcceso, CodigoColor) VALUES (?, ?, ?, ?, ?);";
}
