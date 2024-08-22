
CREATE SCHEMA ph;

/*TABLAS PARA DIRECCIONES*/
CREATE TABLE ph.Departamentos (
  IdDepartamento INT PRIMARY KEY IDENTITY,
  Descripcion NVARCHAR(25) NOT NULL
);

CREATE TABLE ph.Municipios (
  IdMunicipio INT PRIMARY KEY IDENTITY,
  IdDepartamento INT NOT NULL,
  Descripcion NVARCHAR(25) NOT NULL,
  CONSTRAINT FK_Municipios_Departamentos_IdDepartamento FOREIGN KEY (IdDepartamento) REFERENCES ph.Departamentos(IdDepartamento)
);

DROP TABLE ph.Direcciones (
  IdDireccion INT PRIMARY KEY IDENTITY,
  IdMunicipio INT NOT NULL,
  CONSTRAINT FK_Direcciones_Municipios_IdMunicipio FOREIGN KEY (IdMunicipio) REFERENCES ph.Municipios(IdMunicipio)
);

/*TABLA PARA USUARIO*/
CREATE TABLE ph.Usuarios (
  IdUsuario VARCHAR(28) PRIMARY KEY,
  IdMunicipio INT NOT NULL,
  Correo NVARCHAR(50) NOT NULL,
  Telefono CHAR(8),
  PrimerNombre NVARCHAR(20) NOT NULL,
  PrimerApellido NVARCHAR(20) NOT NULL,
  FechaNacimiento DATE NOT NULL,
  Suscripcion NVARCHAR(10) NOT NULL,
  CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
  UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
);

/*TABLAS PARA MASCOTAS*/
CREATE TABLE ph.Animales (
  IdAnimal INT PRIMARY KEY IDENTITY,
  Descripcion NVARCHAR(30) NOT NULL
);

CREATE TABLE ph.Razas (
  IdRaza INT PRIMARY KEY IDENTITY,
  IdAnimal INT NOT NULL,
  Descripcion NVARCHAR(30) NOT NULL,
  CONSTRAINT Razas_Animales_IdAnimal FOREIGN KEY (IdAnimal) REFERENCES ph.Animales(IdAnimal)
);

CREATE TABLE ph.Colores (
  IdColor INT PRIMARY KEY IDENTITY,
  Descripcion NVARCHAR(20) NOT NULL
);

CREATE TABLE ph.Mascotas (
  IdMascota INT PRIMARY KEY IDENTITY,
  IdDuenio VARCHAR(28) NOT NULL,
  IdRaza INT,
  Nombre NVARCHAR(20) NOT NULL,
  Edad INT NOT NULL,
  Adoptado BIT NOT NULL DEFAULT (0),
  FechaPublicacion DATETIME NOT NULL DEFAULT (GETDATE()),
  Detalles NVARCHAR(MAX) NOT NULL,
  CONSTRAINT FK_Mascotas_Usuarios_IdDuenio FOREIGN KEY (IdDuenio) REFERENCES ph.Usuarios(IdUsuario),
  CONSTRAINT FK_Mascotas_Razas_IdRaza FOREIGN KEY (IdRaza) REFERENCES ph.Razas(IdRaza)
);

CREATE TABLE ph.MascotasColores (
  IdMascota INT NOT NULL,
  IdColor INT NOT NULL,
  CONSTRAINT FK_MascotasColores_Colores_IdColor FOREIGN KEY (IdColor) REFERENCES ph.Colores(IdColor),
  CONSTRAINT FK_MascotasColores_Mascotas_IdMascota FOREIGN KEY (IdMascota) REFERENCES ph.Mascotas(IdMascota),
  CONSTRAINT PK_MascotasColores PRIMARY KEY (IdMascota, IdColor)
);

CREATE TABLE ph.Adopciones(
	IdAdoptante varchar(28) NOT NULL,
	IdMascota INT NOT NULL,
	CONSTRAINT PK_ PRIMARY KEY(IdAdoptante, IdMascota),
	CONSTRAINT FK_Adopciones_Usuarios_IdAdoptante FOREIGN KEY (IdAdoptante) REFERENCES ph.Usuarios(IdUsuario),
	CONSTRAINT FK_Adopciones_Usuarios_IdMascota FOREIGN KEY (IdMascota) REFERENCES ph.Mascotas(IdMascota),
);

/*TABLAS PARA FUNCIONALIDADES DE LA APP*/
CREATE TABLE ph.Historias (
  IdHistoria INT PRIMARY KEY IDENTITY,
  IdUsuario varchar(28) NOT NULL,
  Descripcion NVARCHAR(MAX) NOT NULL,
  FechaPublicacion DATETIME DEFAULT (GETDATE()),
  CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
  UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
  CONSTRAINT FK_Historias_Usuarios_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES ph.Usuarios(IdUsuario)
);

CREATE TABLE ph.HistoriasLikes (
  IdUsuario varchar(28) NOT NULL,
  IdHistoria INT NOT NULL,
  CONSTRAINT PK_HistoriasLikes PRIMARY KEY (IdUsuario, IdHistoria),
  CONSTRAINT FK_HistoriasLikes_Usuarios_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES ph.Usuarios(IdUsuario),
  CONSTRAINT FK_HistoriasLikes_Historias_IdHistoria FOREIGN KEY (IdHistoria) REFERENCES ph.Historias(IdHistoria)
);

CREATE TABLE ph.Conversaciones (
  IdConversacion INT PRIMARY KEY IDENTITY,
  IdUsuarioUno varchar(28) NOT NULL,
  IdUsuarioDos varchar(28) NOT NULL,
  CONSTRAINT FK_Conversaciones_Usuarios_IdUsuarioEmisor FOREIGN KEY (IdUsuarioUno) REFERENCES ph.Usuarios(IdUsuario),
  CONSTRAINT FK_Conversaciones_Usuarios_IdUsuarioReceptor FOREIGN KEY (IdUsuarioDos) REFERENCES ph.Usuarios(IdUsuario)
);

CREATE TABLE ph.Mensajes (
  IdMensaje INT PRIMARY KEY IDENTITY,
  IdConversacion INT NOT NULL,
  IdUsuarioEmisor varchar(28) NOT NULL,
  Mensaje NVARCHAR(MAX) NOT NULL,
  FechaEnvio DATETIME DEFAULT (GETDATE()),
  CONSTRAINT FK_Mensajes_Conversaciones_IdConversacion FOREIGN KEY (IdConversacion) REFERENCES ph.Conversaciones(IdConversacion),
  CONSTRAINT FK_Mensajes_Usuarios_IdUsuarioEmisor FOREIGN KEY (IdUsuarioEmisor) REFERENCES ph.Usuarios(IdUsuario)
);

/*VENTAS*/
CREATE TABLE ph.PlanesDeSuscripcion (
    IdPlan INT PRIMARY KEY IDENTITY,
    NombrePlan NVARCHAR(50) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    Detalles NVARCHAR(255),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ph.UsuariosSuscripciones (
    IdUsuario varchar(28) NOT NULL,
    IdSuscripcion INT NOT NULL,
    FechaInicial DATETIME DEFAULT GETDATE(),
    FechaFinal DATETIME DEFAULT DATEADD(MONTH, 1, GETDATE()),
    CONSTRAINT PK_UsuariosSuscripciones PRIMARY KEY (IdUsuario, IdSuscripcion),
    CONSTRAINT FK_UsuariosSuscripciones_Usuarios FOREIGN KEY (IdUsuario) REFERENCES ph.Usuarios(IdUsuario),
    CONSTRAINT FK_UsuariosSuscripciones_Suscripciones FOREIGN KEY (IdSuscripcion) REFERENCES ph.PlanesDeSuscripcion(IdPlan)
);

CREATE TABLE ph.Mascotas_Imagenes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdMascota INT NOT NULL,
    NombreImagen VARCHAR(20),
    Created_At DATETIME DEFAULT GETDATE(),
    Updated_At DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IdMascota) REFERENCES ph.Mascotas(IdMascota)
);

/*SOTORE PROCEDURES*/
CREATE PROCEDURE [ph].[SP_CreatePet]
    @correo VARCHAR(28),
    @idRaza INT,
    @nombre NVARCHAR(20),
    @edad INT,
    @detalles NVARCHAR(MAX)
AS
BEGIN
    DECLARE @idDuenio VARCHAR(28);

    SELECT @idDuenio = IdUsuario
    FROM ph.Usuarios
    WHERE Correo = @correo;

    IF @idDuenio IS NOT NULL
    BEGIN
        INSERT INTO ph.Mascotas (IdDuenio, IdRaza, Nombre, Edad, Detalles)
        VALUES (@idDuenio, @idRaza, @nombre, @edad, @detalles);

        SELECT 200 AS StatusCode, 'Mascota creada exitosamente' AS Message;
    END
    ELSE
    BEGIN
        SELECT 404 AS StatusCode, 'Datos inválidos' AS Message;
    END
END
GO

CREATE PROCEDURE [ph].[SP_CreateStory]
    @correo VARCHAR(28),
    @descripcion NVARCHAR(MAX)
AS
BEGIN
    DECLARE @idDuenio VARCHAR(28);
    DECLARE @idHistoria INT;

    SELECT @idDuenio = IdUsuario
    FROM ph.Usuarios
    WHERE Correo = @correo;

    IF @idDuenio IS NOT NULL
    BEGIN
        INSERT INTO ph.Historias (Descripcion, IdUsuario) 
        VALUES (@descripcion, @idDuenio);

        SET @idHistoria = SCOPE_IDENTITY();

        SELECT 200 AS StatusCode, 'Historia creada exitosamente' AS Message, @idHistoria AS HistoriaID;
    END
    ELSE
    BEGIN
        SELECT 404 AS StatusCode, 'Datos inválidos' AS Message, NULL AS HistoriaID;
    END
END
GO

CREATE PROCEDURE [ph].[SP_CreateUser]
    @IdUsuario NVARCHAR(50),
    @nombre NVARCHAR(20),
    @apellido NVARCHAR(20),
    @correo NVARCHAR(50),
    @idMunicipio INT,
    @telefono CHAR(8),
    @fechaNacimiento DATE,
    @idPlan INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        INSERT INTO [ph].[Usuarios] (IdUsuario, Correo, Telefono, PrimerNombre, PrimerApellido, FechaNacimiento, IdMunicipio) 
        VALUES (@IdUsuario, @correo, @telefono, @nombre, @apellido, @fechaNacimiento, @idMunicipio);

        INSERT INTO [ph].[UsuariosSuscripciones] (IdUsuario, IdSuscripcion) 
        VALUES (@IdUsuario, @idPlan);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE [ph].[SP_GetFilteredPetsInfo] 
    @idAnimal INT,
    @idRaza INT,
    @idColor INT
AS
BEGIN
        SELECT 
            M.IdMascota, 
            M.Nombre, 
            M.Detalles, 
            M.Edad, 
            R.Descripcion AS Raza, 
            MU.Descripcion AS MunicipioDescripcion
        FROM ph.Mascotas M
        INNER JOIN ph.Razas R ON M.IdRaza = R.IdRaza
        INNER JOIN ph.Usuarios U ON M.IdDuenio = U.IdUsuario
        INNER JOIN ph.Municipios MU ON U.IdMunicipio = MU.IdMunicipio
        INNER JOIN ph.MascotasColores MC ON MC.IdMascota = M.IdMascota
        WHERE R.IdRaza = @idRaza AND R.IdAnimal = @idAnimal AND MC.IdColor = @idColor     
    END
GO

CREATE PROCEDURE [ph].[SP_GetHistorias]
    @email VARCHAR(28)
AS
BEGIN
    DECLARE @n INT;
    SET @n = (SELECT COUNT(*) FROM ph.Usuarios WHERE Correo = @email);

    IF @n = 0
    BEGIN
        SELECT 404 AS StatusCode, 'Id de usuario no existe' AS Message;
    END
    ELSE
    BEGIN
        SELECT 
            h.Descripcion,
            h.IdHistoria,
            CONVERT(VARCHAR, h.FechaPublicacion, 120) AS FechaPublicacion,
            u.PrimerNombre + ' ' + u.PrimerApellido AS NombreCompleto,
            (SELECT COUNT(*) FROM ph.HistoriasLikes HL WHERE HL.IdHistoria = h.IdHistoria) AS Likes
        FROM ph.Historias h
        INNER JOIN ph.Usuarios u ON h.IdUsuario = u.IdUsuario
        WHERE u.Correo <> @email;
    END
END
GO

CREATE PROCEDURE [ph].[SP_GetPetDetail] 
    @idMascota INT
AS
BEGIN
    DECLARE @n INT;
    SET @n = (SELECT COUNT(*) FROM ph.Mascotas WHERE IdMascota = @idMascota);

    IF @n = 0
    BEGIN
        SELECT 404 AS StatusCode, 'La mascota no existe' AS Message;
    END
    ELSE 
    BEGIN
        SELECT 
            M.IdMascota, 
            M.Nombre, 
            M.Detalles, 
            M.Edad, 
            R.Descripcion AS Raza, 
            MU.Descripcion AS MunicipioDescripcion,
            CONVERT(VARCHAR, M.FechaPublicacion, 120) AS FechaPublicacion,
            U.PrimerNombre + ' ' + U.PrimerApellido AS NombreCompleto,
            STRING_AGG(c.Descripcion, ', ') AS Colores,
            MI.NombreImagen
        FROM ph.Mascotas M
        INNER JOIN ph.Razas R ON M.IdRaza = R.IdRaza
        INNER JOIN ph.Usuarios U ON M.IdDuenio = U.IdUsuario
        INNER JOIN ph.Municipios MU ON U.IdMunicipio = MU.IdMunicipio
        LEFT JOIN ph.MascotasColores MC ON M.IdMascota = MC.IdMascota
        LEFT JOIN ph.Colores c ON MC.IdColor = c.IdColor
        LEFT JOIN ph.Mascotas_Imagenes MI ON MI.IdMascota = M.IdMascota
        WHERE M.IdMascota = @idMascota
        GROUP BY 
            M.IdMascota, 
            M.Nombre, 
            M.Detalles, 
            M.Edad, 
            R.Descripcion, 
            MU.Descripcion,
            M.FechaPublicacion,
            U.PrimerNombre,
            MI.NombreImagen,
            U.PrimerApellido;
    END
END
GO

CREATE PROCEDURE [ph].[SP_GetPetsInfo]
    @correo VARCHAR(28)
AS
BEGIN
    DECLARE @n INT = (SELECT COUNT(*) FROM ph.Usuarios WHERE Correo = @correo)

    IF @n > 0
    BEGIN
        SELECT 
            M.IdMascota, 
            M.Nombre, 
            M.Detalles, 
            M.Edad, 
            R.Descripcion AS Raza, 
            MU.Descripcion AS MunicipioDescripcion,
            MI.NombreImagen
        FROM ph.Mascotas M
        INNER JOIN ph.Razas R ON M.IdRaza = R.IdRaza
        INNER JOIN ph.Usuarios U ON M.IdDuenio = U.IdUsuario
        INNER JOIN ph.Municipios MU ON U.IdMunicipio = MU.IdMunicipio
        LEFT JOIN ph.Mascotas_Imagenes MI ON MI.IdMascota = M.IdMascota
        WHERE U.Correo <> @correo
    END
    ELSE 
    BEGIN
        SELECT 404 StatusCode, 'Bad Requesst' Message
    END

END
GO

CREATE PROCEDURE [ph].[SP_GiveLike]
    @correo VARCHAR(28),
    @idHistoria INT
AS
BEGIN
    DECLARE @idDuenio VARCHAR(28);

    SELECT @idDuenio = IdUsuario
    FROM ph.Usuarios
    WHERE Correo = @correo;

    IF @idDuenio IS NOT NULL
    BEGIN
        INSERT INTO ph.HistoriasLikes (IdHistoria, IdUsuario) VALUES (@idHistoria, @idDuenio)

        SELECT 200 AS StatusCode, 'Like dado exitosamente' AS Message;
    END
    ELSE
    BEGIN
        SELECT 404 AS StatusCode, 'Datos inválidos' AS Message;
    END

END
GO

CREATE PROCEDURE [ph].[SP_insert_pet_images] 
    @correo VARCHAR(28),
    @idMascota INT,
    @nombreImagen VARCHAR(MAX)
AS
BEGIN
    DECLARE @n INT;
    SET @n = (SELECT COUNT(*) 
              FROM ph.Mascotas M 
              INNER JOIN ph.Usuarios U ON U.IdUsuario = M.IdDuenio 
              WHERE U.Correo = @correo)
    PRINT CONCAT('message' , @n)

    IF @n > 0
    BEGIN
        DECLARE @n_images INT = (SELECT COUNT(*) 
                                 FROM ph.Mascotas_Imagenes 
                                 WHERE IdMascota = @idMascota AND NombreImagen = @nombreImagen)

            PRINT CONCAT('message' , @n_images)
                        PRINT CONCAT('id' , @nombreImagen)


        IF @n_images > 0
        BEGIN
            UPDATE ph.Mascotas_Imagenes 
            SET Updated_At = GETDATE()
            WHERE IdMascota = @idMascota
            AND NombreImagen = @nombreImagen

            SELECT 200 AS StatusCode, 'OK' AS Message
        END 
        ELSE 
        BEGIN
            INSERT INTO ph.Mascotas_Imagenes(IdMascota, NombreImagen) 
            VALUES (@idMascota, @nombreImagen)

            SELECT 200 AS StatusCode, 'OK' AS Message
        END
    END
END
GO

CREATE PROCEDURE [ph].[SP_UpdatePet]
    @nombre VARCHAR(28),
    @idMascota INT,
    @detalles VARCHAR(MAX),
    @edad INT
AS
BEGIN
    -- Verificar si la mascota existe
    DECLARE @n INT;
    SET @n = (SELECT COUNT(*) FROM ph.Mascotas WHERE IdMascota = @idMascota);

    IF @n > 0
    BEGIN
        -- Actualizar los detalles de la mascota
        UPDATE ph.Mascotas 
        SET 
            Nombre = @nombre, 
            Detalles = @detalles, 
            Edad = @edad
        WHERE IdMascota = @idMascota;

        -- Devolver un mensaje de éxito
        SELECT 200 AS StatusCode, 'OK' AS Message;
    END 
    ELSE 
    BEGIN
        -- Devolver un mensaje de error si la mascota no existe
        SELECT 404 AS StatusCode, 'Mascota no encontrada' AS Message;
    END
END;
GO






  







