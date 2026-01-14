class Querys {
  static List<String> querysCreateTables() => [
        """
        CREATE TABLE tbUsuarioActivo(UsuarioId INTEGER PRIMARY KEY, 
                                     NombreUsuario TEXT, 
                                     Correo TEXT, 
                                     FechaLimiteActivo TEXT,
                                     Rol TEXT);
        """,
        """
        CREATE TABLE tbGrupos(GrupoId INTEGER PRIMARY KEY, 
                              NombreGrupo TEXT, 
                              Descripcion TEXT, 
                              CodigoAcceso TEXT,
                              CodigoColor TEXT);
        """,
        """
        CREATE TABLE tbMaterias(MateriaId INTEGER PRIMARY KEY, 
                                NombreMateria TEXT, 
                                Descripcion TEXT, 
                                CodigoColor TEXT,
                                CodigoAcceso TEXT);
        """,
        """
            
        CREATE TABLE tbActividades(ActividadId INTEGER PRIMARY KEY, 
                        NombreActividad TEXT, 
                        Descripcion TEXT, 
                        TipoActividadId INTEGER,
                        FechaCreacion TEXT, 
                        FechaLimite TEXT,
                        MateriaId INTEGER,
                        Puntaje INTEGER
                        );
                                   
        """,
        """
        CREATE TABLE tbGruposMaterias(GrupoMateriaId INTEGER PRIMARY KEY, 
                                     GrupoId INTEGER,
                                     MateriaId INTEGER,
                                     FOREIGN KEY (GrupoId) REFERENCES tbGrupos(GrupoId),
                                     FOREIGN KEY (MateriaId) REFERENCES tbMaterias(MateriaId)
                                     );
        """,
        """
        CREATE TABLE tbMateriasActividades(MateriaActividadId INTEGER PRIMARY KEY,
                                           MateriaId INTEGER,
                                           ActividadId INTEGER,
                      FOREIGN KEY (ActividadId) REFERENCES tbActividades(ActividadId),
                      FOREIGN KEY (MateriaId) REFERENCES tbMaterias(MateriaId)
                                          );
        """,
        """
        CREATE TABLE tbAlumnosActividades(AlumnoActividadId INTEGER PRIMARY KEY,
                                          ActividadId INTEGER,
                                          AlumnoId INTEGER,
                                          FechaEntrega TEXT,
                                          EstatusEntrega INTEGER,
                     FOREIGN KEY (ActividadId) REFERENCES tbActividades(ActividadId)
                                         );
        """,
        """
        CREATE TABLE tbEntregableActividades(EntregaId INTEGER PRIMARY KEY,
                                             AlumnoActividadId INTEGER,
                                             Respuesta TEXT,
                                             Enlace TEXT, 
                                             Archivo TEXT,
    				FOREIGN KEY (AlumnoActividadId) REFERENCES tbAlumnosActividades(AlumnoActividadId)
                                            );
        """,
        """
        CREATE TABLE tbNotificaciones(MensajeId TEXT PRIMARY KEY, 
                                      Titulo TEXT, 
                                      Descripcion TEXT, 
                                      FechaEnvio TEXT, 
                                      Data TEXT, 
                                      ImagenURL TEXT);
        """
      ];

  static List<String> querysDeleteTables() => [
        "DELETE FROM tbUsuarioActivo;",
        "DELETE FROM tbGrupos;",
        "DELETE FROM tbMaterias;",
        "DELETE FROM tbActividades;",
        "DELETE FROM tbGruposMaterias;",
        "DELETE FROM tbMateriasActividades;",
        "DELETE FROM tbAlumnosActividades;",
        "DELETE FROM tbEntregableActividades;",
        "DELETE FROM tbNotificaciones;"
      ];

//& tbUsuarioActivo
  static String querytbUsuarioActivoInsert() =>
      "INSERT INTO tbUsuarioActivo(UsuarioId, NombreUsuario, Correo, FechaLimiteActivo, Rol) VALUES(?,?,?,?,?)";

  static String querytbUsuarioActivoUpdate() =>
      "UPDATE tbUsuarioActivo SET FechaLimiteActivo = ?";

//& tbNotificaciones
  static String querytbNotificacionesInsert() =>
      "INSERT INTO tbNotificaciones(MensajeId, Titulo, Descripcion, FechaEnvio, Data, ImagenURL) VALUES(?,?,?,?,?,?);";

  static String querytbNotificacionesDeleteWhere() =>
      "DELETE FROM tbNotificaciones WHERE FechaEnvio = ?";

//& tbGrupos
  static String querytbGruposInsert() => "INSERT INTO tbGrupos (GrupoId, NombreGrupo, Descripcion, CodigoAcceso, CodigoColor) VALUES (?, ?, ?, ?, ?);";
}
