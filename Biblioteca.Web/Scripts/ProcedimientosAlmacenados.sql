/*
 * ================================================================
 *   BibliotecaDB  –  Script COMPLETO para uso LOCAL
 *   SQL Server 2019 / 2022 o LocalDB (MSSQLLocalDB)
 *
 *   Ejecutar en orden desde SSMS o sqlcmd:
 *     1. Crea la base de datos si no existe.
 *     2. Crea las 5 tablas con sus restricciones.
 *     3. Inserta datos de prueba (autores, libros, socios, préstamos).
 *     4. Crea / reemplaza los 9 procedimientos almacenados.
 *
 *   Conexión usada por la app (appsettings.json):
 *   Server=(localdb)\MSSQLLocalDB;Database=BibliotecaDB;
 *   Trusted_Connection=True;TrustServerCertificate=True
 * ================================================================
 */

-- ----------------------------------------------------------------
-- 0. Crear la base de datos si no existe
-- ----------------------------------------------------------------
IF DB_ID('BibliotecaDB') IS NULL
    CREATE DATABASE BibliotecaDB;
GO

USE BibliotecaDB;
GO

-- ----------------------------------------------------------------
-- 1. TABLAS
-- ----------------------------------------------------------------

-- Autores
IF OBJECT_ID('Autores','U') IS NULL
BEGIN
    CREATE TABLE Autores (
        AutorId   INT            IDENTITY(1,1) PRIMARY KEY,
        Nombre    NVARCHAR(120)  NOT NULL,
        Activo    BIT            NOT NULL DEFAULT 1
    );
END
GO

-- Libros
IF OBJECT_ID('Libros','U') IS NULL
BEGIN
    CREATE TABLE Libros (
        LibroId    INT            IDENTITY(1,1) PRIMARY KEY,
        Titulo     NVARCHAR(200)  NOT NULL,
        ISBN       NVARCHAR(20)   NOT NULL,
        AutorId    INT            NOT NULL REFERENCES Autores(AutorId),
        Ejemplares INT            NOT NULL DEFAULT 1,
        Activo     BIT            NOT NULL DEFAULT 1,
        CONSTRAINT UQ_Libros_ISBN UNIQUE (ISBN)
    );
END
GO

-- Socios
IF OBJECT_ID('Socios','U') IS NULL
BEGIN
    CREATE TABLE Socios (
        SocioId INT            IDENTITY(1,1) PRIMARY KEY,
        DNI     NVARCHAR(15)   NOT NULL,
        Nombre  NVARCHAR(120)  NOT NULL,
        Email   NVARCHAR(120)  NOT NULL,
        Activo  BIT            NOT NULL DEFAULT 1,
        CONSTRAINT UQ_Socios_DNI UNIQUE (DNI)
    );
END
GO

-- Prestamos
IF OBJECT_ID('Prestamos','U') IS NULL
BEGIN
    CREATE TABLE Prestamos (
        PrestamoId    INT           IDENTITY(1,1) PRIMARY KEY,
        SocioId       INT           NOT NULL REFERENCES Socios(SocioId),
        FechaPrestamo DATETIME      NOT NULL DEFAULT GETDATE(),
        FechaLimite   DATETIME      NOT NULL,
        Estado        NVARCHAR(20)  NOT NULL DEFAULT 'Activo'
            CHECK (Estado IN ('Activo','Devuelto','Vencido'))
    );
END
GO

-- DetallePrestamo
IF OBJECT_ID('DetallePrestamo','U') IS NULL
BEGIN
    CREATE TABLE DetallePrestamo (
        DetalleId  INT IDENTITY(1,1) PRIMARY KEY,
        PrestamoId INT NOT NULL REFERENCES Prestamos(PrestamoId),
        LibroId    INT NOT NULL REFERENCES Libros(LibroId)
    );
END
GO

-- ----------------------------------------------------------------
-- 2. DATOS DE PRUEBA
--    Usamos INSERT IF NOT EXISTS para poder reejecutar el script
-- ----------------------------------------------------------------

-- Autores
IF NOT EXISTS (SELECT 1 FROM Autores)
BEGIN
    SET IDENTITY_INSERT Autores ON;
    INSERT INTO Autores (AutorId, Nombre, Activo) VALUES
        (1, N'Gabriel García Márquez',  1),
        (2, N'Isabel Allende',          1),
        (3, N'Julio Cortázar',          1),
        (4, N'Mario Vargas Llosa',      1),
        (5, N'Jorge Luis Borges',       1),
        (6, N'Pablo Neruda',            1);
    SET IDENTITY_INSERT Autores OFF;
END
GO

-- Libros
IF NOT EXISTS (SELECT 1 FROM Libros)
BEGIN
    SET IDENTITY_INSERT Libros ON;
    INSERT INTO Libros (LibroId, Titulo, ISBN, AutorId, Ejemplares, Activo) VALUES
        (1, N'Cien años de soledad',            '9780307474728', 1, 5, 1),
        (2, N'El amor en los tiempos del cólera','9780307389732', 1, 3, 1),
        (3, N'La casa de los espíritus',         '9780553383805', 2, 4, 1),
        (4, N'Eva Luna',                         '9780553380873', 2, 2, 1),
        (5, N'Rayuela',                          '9780307476753', 3, 6, 1),
        (6, N'La ciudad y los perros',           '9780374529222', 4, 3, 1),
        (7, N'Ficciones',                        '9780802130303', 5, 4, 1),
        (8, N'El Aleph',                         '9780142437889', 5, 2, 1),
        (9, N'Veinte poemas de amor',            '9780140586183', 6, 5, 1),
        (10,N'La tía Julia y el escribidor',     '9780312420123', 4, 2, 1);
    SET IDENTITY_INSERT Libros OFF;
END
GO

-- Socios
IF NOT EXISTS (SELECT 1 FROM Socios)
BEGIN
    SET IDENTITY_INSERT Socios ON;
    INSERT INTO Socios (SocioId, DNI, Nombre, Email, Activo) VALUES
        (1, '12345678', N'Ana García López',       'ana.garcia@email.com',   1),
        (2, '23456789', N'Carlos Mendoza Ríos',    'carlos.m@email.com',     1),
        (3, '34567890', N'María Torres Silva',     'maria.torres@email.com', 1),
        (4, '45678901', N'Luis Herrera Castro',    'luis.h@email.com',       1),
        (5, '56789012', N'Sofía Ramírez Vega',     'sofia.r@email.com',      1);
    SET IDENTITY_INSERT Socios OFF;
END
GO

-- Préstamos y detalles
IF NOT EXISTS (SELECT 1 FROM Prestamos)
BEGIN
    SET IDENTITY_INSERT Prestamos ON;
    INSERT INTO Prestamos (PrestamoId, SocioId, FechaPrestamo, FechaLimite, Estado) VALUES
        (1, 1, '2026-09-01', '2026-09-15', N'Devuelto'),
        (2, 2, '2026-09-10', '2026-09-24', N'Devuelto'),
        (3, 3, '2026-09-20', '2026-10-04', N'Vencido'),
        (4, 4, '2026-10-01', '2026-10-15', N'Activo'),
        (5, 5, '2026-10-05', '2026-10-19', N'Activo');
    SET IDENTITY_INSERT Prestamos OFF;

    INSERT INTO DetallePrestamo (PrestamoId, LibroId) VALUES
        (1, 1), (1, 5),
        (2, 3),
        (3, 7), (3, 8),
        (4, 2), (4, 9),
        (5, 6);
END
GO

-- ----------------------------------------------------------------
-- 3. PROCEDIMIENTOS ALMACENADOS
-- ----------------------------------------------------------------

-- sp_Libro_ListarActivos
CREATE OR ALTER PROCEDURE sp_Libro_ListarActivos
AS
BEGIN
    SELECT
        l.LibroId,
        l.Titulo,
        l.ISBN,
        l.AutorId,
        l.Ejemplares,
        l.Activo,
        a.Nombre AS NombreAutor
    FROM Libros l
    INNER JOIN Autores a ON a.AutorId = l.AutorId
    WHERE l.Activo = 1
    ORDER BY l.Titulo;
END
GO

-- sp_Libro_BuscarPorTitulo
CREATE OR ALTER PROCEDURE sp_Libro_BuscarPorTitulo
    @Titulo NVARCHAR(200)
AS
BEGIN
    SELECT
        l.LibroId,
        l.Titulo,
        l.ISBN,
        l.AutorId,
        l.Ejemplares,
        l.Activo,
        a.Nombre AS NombreAutor
    FROM Libros l
    INNER JOIN Autores a ON a.AutorId = l.AutorId
    WHERE l.Activo = 1
      AND l.Titulo LIKE N'%' + @Titulo + N'%'
    ORDER BY l.Titulo;
END
GO

-- sp_Libro_ObtenerPorId
CREATE OR ALTER PROCEDURE sp_Libro_ObtenerPorId
    @LibroId INT
AS
BEGIN
    SELECT
        l.LibroId,
        l.Titulo,
        l.ISBN,
        l.AutorId,
        l.Ejemplares,
        l.Activo,
        a.Nombre AS NombreAutor
    FROM Libros l
    INNER JOIN Autores a ON a.AutorId = l.AutorId
    WHERE l.LibroId = @LibroId;
END
GO

-- sp_Libro_Insertar
CREATE OR ALTER PROCEDURE sp_Libro_Insertar
    @Titulo    NVARCHAR(200),
    @ISBN      NVARCHAR(20),
    @AutorId   INT,
    @Ejemplares INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Libros WHERE ISBN = @ISBN)
        RETURN;

    INSERT INTO Libros (Titulo, ISBN, AutorId, Ejemplares)
    VALUES (@Titulo, @ISBN, @AutorId, @Ejemplares);
END
GO

-- sp_Libro_Actualizar
CREATE OR ALTER PROCEDURE sp_Libro_Actualizar
    @LibroId    INT,
    @Titulo     NVARCHAR(200),
    @ISBN       NVARCHAR(20),
    @AutorId    INT,
    @Ejemplares INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Libros WHERE ISBN = @ISBN AND LibroId <> @LibroId)
        RETURN;

    UPDATE Libros
    SET Titulo     = @Titulo,
        ISBN       = @ISBN,
        AutorId    = @AutorId,
        Ejemplares = @Ejemplares
    WHERE LibroId = @LibroId
      AND Activo  = 1;
END
GO

-- sp_Libro_Eliminar (baja lógica)
CREATE OR ALTER PROCEDURE sp_Libro_Eliminar
    @LibroId INT
AS
BEGIN
    UPDATE Libros
    SET Activo = 0
    WHERE LibroId = @LibroId
      AND Activo  = 1;
END
GO

-- sp_Autor_ListarActivos
CREATE OR ALTER PROCEDURE sp_Autor_ListarActivos
AS
BEGIN
    SELECT AutorId, Nombre
    FROM Autores
    WHERE Activo = 1
    ORDER BY Nombre;
END
GO

-- sp_Socio_ListarActivos
CREATE OR ALTER PROCEDURE sp_Socio_ListarActivos
AS
BEGIN
    SELECT SocioId, DNI, Nombre, Email, Activo
    FROM Socios
    WHERE Activo = 1
    ORDER BY Nombre;
END
GO

-- sp_Socio_Insertar
CREATE OR ALTER PROCEDURE sp_Socio_Insertar
    @DNI    NVARCHAR(15),
    @Nombre NVARCHAR(120),
    @Email  NVARCHAR(120)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Socios WHERE DNI = @DNI)
        RETURN;

    INSERT INTO Socios (DNI, Nombre, Email)
    VALUES (@DNI, @Nombre, @Email);
END
GO

-- sp_Prestamo_Reporte
CREATE OR ALTER PROCEDURE sp_Prestamo_Reporte
    @Desde DATETIME = NULL,
    @Hasta DATETIME = NULL
AS
BEGIN
    SELECT
        s.Nombre  AS Socio,
        STRING_AGG(l.Titulo, N', ') WITHIN GROUP (ORDER BY l.Titulo) AS Libros,
        p.FechaLimite,
        p.Estado
    FROM Prestamos p
    INNER JOIN Socios          s ON s.SocioId   = p.SocioId
    INNER JOIN DetallePrestamo d ON d.PrestamoId = p.PrestamoId
    INNER JOIN Libros          l ON l.LibroId    = d.LibroId
    WHERE (@Desde IS NULL OR p.FechaPrestamo >= @Desde)
      AND (@Hasta IS NULL OR p.FechaPrestamo <  DATEADD(DAY, 1, CONVERT(date, @Hasta)))
    GROUP BY p.PrestamoId, s.Nombre, p.FechaLimite, p.Estado, p.FechaPrestamo
    ORDER BY p.FechaPrestamo;
END
GO

PRINT '✓ BibliotecaDB creada/actualizada correctamente con datos de prueba y procedimientos almacenados.';
GO
