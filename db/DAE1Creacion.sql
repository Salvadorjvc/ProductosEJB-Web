-- =============================================
-- Script de creación de base de datos y tablas
-- Proyecto: DAE1
-- =============================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DAE1')
BEGIN
    CREATE DATABASE [DAE1];
    PRINT('Base de datos DAE1 creada correctamente.');
END
ELSE
BEGIN
    PRINT('La base de datos DAE1 ya existe.');
END
GO

USE [DAE1];
GO

-- =============================================
-- Tabla: Productos
-- =============================================

IF OBJECT_ID('dbo.Productos', 'U') IS NOT NULL
    DROP TABLE dbo.Productos;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE [dbo].[Productos](
    [id_producto]     INT IDENTITY(1,1) NOT NULL,
    [nombre]          VARCHAR(100) NOT NULL,
    [descripcion]     TEXT NULL,
    [precio]          DECIMAL(10,2) NOT NULL,
    [stock]           INT NOT NULL,
    [categoria]       VARCHAR(50) NULL,
    [fecha_creacion]  DATETIME NULL 
        CONSTRAINT DF_Productos_Fecha_Creacion DEFAULT (GETDATE()),
    CONSTRAINT PK_Productos PRIMARY KEY CLUSTERED ([id_producto] ASC)
);
GO

-- =============================================
-- Tabla: Usuarios
-- =============================================

IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL
    DROP TABLE dbo.Usuarios;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE [dbo].[Usuarios](
    [id_usuario]      INT IDENTITY(1,1) NOT NULL,
    [nombre]          VARCHAR(50) NOT NULL,
    [apellido]        VARCHAR(50) NOT NULL,
    [email]           VARCHAR(100) NOT NULL,
    [password]        VARCHAR(255) NOT NULL,
    [fecha_creacion]  DATETIME NULL 
        CONSTRAINT DF_Usuarios_Fecha_Creacion DEFAULT (GETDATE()),
    CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED ([id_usuario] ASC),
    CONSTRAINT UQ_Usuarios_Email UNIQUE NONCLUSTERED ([email] ASC)
);
GO

-- =============================================
-- Datos de prueba
-- =============================================

INSERT INTO dbo.Usuarios (nombre, apellido, email, [password])
VALUES 
('Juan', 'Pérez', 'juan.perez@example.com', '123456'),
('Ana', 'Ramírez', 'ana.ramirez@example.com', 'abc123'),
('Luis', 'Torres', 'luis.torres@example.com', 'qwerty'),
('María', 'López', 'maria.lopez@example.com', 'pass123'),
('Carlos', 'Gómez', 'carlos.gomez@example.com', 'admin123');

INSERT INTO dbo.Productos (nombre, descripcion, precio, stock, categoria)
VALUES 
('Teclado Mecánico', 'Teclado retroiluminado RGB con switches azules', 120.50, 10, 'Periféricos'),
('Mouse Gamer', 'Mouse óptico con 7200 DPI y luces RGB', 85.90, 15, 'Periféricos'),
('Monitor 24"', 'Monitor LED Full HD de 24 pulgadas', 650.00, 8, 'Pantallas'),
('Audífonos Inalámbricos', 'Audífonos Bluetooth con micrófono integrado', 150.75, 12, 'Audio'),
('Laptop i5', 'Laptop con procesador Intel Core i5 y 8GB RAM', 2500.00, 5, 'Computadoras'),
('Impresora Multifuncional', 'Impresora con escáner y conexión Wi-Fi', 890.00, 7, 'Equipos de Oficina'),
('Memoria USB 32GB', 'Unidad flash USB 3.0 de 32GB', 35.90, 25, 'Almacenamiento'),
('Disco Duro Externo 1TB', 'Disco duro externo USB 3.0 de 1TB', 320.00, 10, 'Almacenamiento'),
('Cámara Web HD', 'Cámara web con resolución 1080p', 210.00, 9, 'Accesorios'),
('Router Wi-Fi', 'Router inalámbrico de doble banda', 275.00, 6, 'Redes');
GO

PRINT('Base de datos DAE1 configurada correctamente con datos de prueba.');
GO


-- =============================================
-- CREACIÓN DE STORED PROCEDURES
-- =============================================

-- Insertar usuario
CREATE PROCEDURE sp_insertar_usuario
    @nombre     VARCHAR(50),
    @apellido   VARCHAR(50),
    @email      VARCHAR(100),
    @password   VARCHAR(255)
AS
BEGIN
    INSERT INTO Usuarios (nombre, apellido, email, password)
    VALUES (@nombre, @apellido, @email, @password);
END;
GO

-- Actualizar usuario
CREATE PROCEDURE sp_actualizar_usuario
    @id_usuario INT,
    @nombre     VARCHAR(50),
    @apellido   VARCHAR(50),
    @email      VARCHAR(100),
    @password   VARCHAR(255)
AS
BEGIN
    UPDATE Usuarios
    SET nombre = @nombre,
        apellido = @apellido,
        email = @email,
        password = @password
    WHERE id_usuario = @id_usuario;
END;
GO

-- Eliminar usuario
CREATE PROCEDURE sp_eliminar_usuario
    @id_usuario INT
AS
BEGIN
    DELETE FROM Usuarios
    WHERE id_usuario = @id_usuario;
END;
GO

-- Listar usuarios
CREATE PROCEDURE sp_listar_usuarios
AS
BEGIN
    SELECT id_usuario, nombre, apellido, email, password, fecha_creacion
    FROM Usuarios;
END;
GO

-- Validar usuario (login)
CREATE PROCEDURE sp_validar_usuario
    @Email VARCHAR(100),
    @Password VARCHAR(255)
AS
BEGIN
    SELECT id_usuario, nombre, apellido, email, password
    FROM Usuarios
    WHERE email = @Email AND password = @Password;
END;
GO

-- Cambiar contraseña
CREATE PROCEDURE sp_cambiar_contraseña
    @id_usuario INT,
    @password_actual VARCHAR(255),
    @password_nueva VARCHAR(255)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Usuarios
        WHERE id_usuario = @id_usuario AND password = @password_actual
    )
    BEGIN
        UPDATE Usuarios
        SET password = @password_nueva
        WHERE id_usuario = @id_usuario;
    END
    ELSE
    BEGIN
        RAISERROR('La contraseña actual no es correcta.', 16, 1);
    END
END;
GO

-- Actualizar contraseña directamente
CREATE PROCEDURE sp_actualizar_usuario_contrasena
    @IdUsuario INT,
    @NuevaClave NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Usuarios
    SET [password] = @NuevaClave
    WHERE id_usuario = @IdUsuario;
END;
GO

-- Insertar producto
CREATE PROCEDURE sp_insertar_producto
    @nombre VARCHAR(100),
    @descripcion TEXT,
    @precio DECIMAL(10, 2),
    @stock INT,
    @categoria VARCHAR(50)
AS
BEGIN
    INSERT INTO Productos (nombre, descripcion, precio, stock, categoria)
    VALUES (@nombre, @descripcion, @precio, @stock, @categoria);
END;
GO

-- Actualizar producto
CREATE PROCEDURE sp_actualizar_producto
    @id_producto INT,
    @nombre VARCHAR(100),
    @descripcion TEXT,
    @precio DECIMAL(10, 2),
    @stock INT,
    @categoria VARCHAR(50)
AS
BEGIN
    UPDATE Productos
    SET nombre = @nombre,
        descripcion = @descripcion,
        precio = @precio,
        stock = @stock,
        categoria = @categoria
    WHERE id_producto = @id_producto;
END;
GO

-- Eliminar producto
CREATE PROCEDURE sp_eliminar_producto
    @id_producto INT
AS
BEGIN
    DELETE FROM Productos
    WHERE id_producto = @id_producto;
END;
GO

-- Listar productos
CREATE PROCEDURE sp_listar_productos
AS
BEGIN
    SELECT id_producto, nombre, descripcion, precio, stock, categoria, fecha_creacion
    FROM Productos;
END;
GO

