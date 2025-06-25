use Heladeria
go

-- =============================================
-- Procedimientos para la tabla Categorias Helados
-- =============================================

-- Listar Categorías
IF OBJECT_ID('spListarCategorias') IS NOT NULL
    DROP PROC spListarCategorias
GO

CREATE PROC spListarCategorias
AS
BEGIN
    SELECT categoria_id, nombre, descripcion
    FROM Categoria_Helado
END
GO


-- Agregar Categoría
IF OBJECT_ID('spAgregarCategoria','P') IS NOT NULL
    DROP PROC spAgregarCategoria
GO

CREATE PROC spAgregarCategoria
@categoria_id VARCHAR(6), @nombre VARCHAR(50), @descripcion VARCHAR(255)
AS
BEGIN
    IF NOT EXISTS(SELECT categoria_id FROM Categoria_Helado WHERE categoria_id = @categoria_id)
        BEGIN
            INSERT INTO Categoria_Helado VALUES(@categoria_id, @nombre, @descripcion)
            SELECT CodError = 0, Mensaje = 'Categoría agregada correctamente'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: ID de categoría duplicado'
END
GO


-- Eliminar Categoría
IF OBJECT_ID('spEliminarCategoria', 'P') IS NOT NULL
    DROP PROC spEliminarCategoria
GO

CREATE PROC spEliminarCategoria
@categoria_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT categoria_id FROM Categoria_Helado WHERE categoria_id = @categoria_id)    
        IF NOT EXISTS(SELECT categoria_id FROM Sabor WHERE categoria_id = @categoria_id)
            BEGIN
                DELETE FROM Categoria_Helado WHERE categoria_id = @categoria_id
                SELECT CodError = 0, Mensaje = 'Categoría eliminada correctamente'
            END
        ELSE SELECT CodError = 1, Mensaje = 'Error: La categoría está en uso en la tabla Sabor'
    ELSE SELECT CodError = 1, Mensaje = 'Error: La categoría no existe'
END
GO

-- Actualizar Categoría
IF OBJECT_ID('spActualizarCategoria', 'P') IS NOT NULL
    DROP PROC spActualizarCategoria
GO

CREATE PROC spActualizarCategoria
@categoria_id VARCHAR(6), @nombre VARCHAR(50), @descripcion VARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Categoria_Helado WHERE categoria_id = @categoria_id)
        BEGIN
            UPDATE Categoria_Helado
            SET nombre = @nombre,
                descripcion = @descripcion
            WHERE categoria_id = @categoria_id;

            SELECT CodError = 0, Mensaje = 'Categoría actualizada correctamente';
        END
    ELSE
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: ID de categoría no existe';
        END
END;
GO

-- Buscar Categorías
IF OBJECT_ID('spBuscarCategoria') IS NOT NULL
    DROP PROC spBuscarCategoria
GO

CREATE PROC spBuscarCategoria
@Texto VARCHAR(50), @Criterio VARCHAR(20)
AS
BEGIN
    IF(@Criterio = 'categoria_id')
        SELECT categoria_id, nombre, descripcion
        FROM Categoria_Helado
        WHERE categoria_id = @Texto
    ELSE IF(@Criterio = 'nombre')
        SELECT categoria_id, nombre, descripcion
        FROM Categoria_Helado
        WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'descripcion')
        SELECT categoria_id, nombre, descripcion
        FROM Categoria_Helado
        WHERE descripcion LIKE '%' + @Texto + '%'
END
GO


/* Validacion de Complementos*/
------------------------------------------------------------------------
EXEC spListarCategorias
GO
EXEC spAgregarCategoria 'CAT102', 'Prueba2', 'Descrip'
GO
EXEC spEliminarCategoria 'CAT102'
GO
EXEC spActualizarCategoria 'CAT101', 'Prueba2', 'Descrip'
GO
exec spListarCategorias
go
exec spBuscarCategoria 'CAT001', 'categoria_id'
go
exec spBuscarCategoria 'Frutales', 'nombre'
go
exec spBuscarCategoria 'Helados con sabor a frutas naturales', 'descripcion'
go
------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Sabores
-- =============================================

-- Listar Sabores
IF OBJECT_ID('spListarSabores') IS NOT NULL
    DROP PROC spListarSabores
GO

CREATE PROC spListarSabores
AS
BEGIN
    SELECT s.sabor_id, s.nombre, s.descripcion, c.nombre AS categoria, 
           s.es_popular, s.fecha_creacion
    FROM Sabor s
    JOIN Categoria_Helado c ON s.categoria_id = c.categoria_id
END
GO

-- Agregar Sabor
IF OBJECT_ID('spAgregarSabor','P') IS NOT NULL
    DROP PROC spAgregarSabor
GO

CREATE PROC spAgregarSabor
@sabor_id VARCHAR(6), @nombre VARCHAR(50), @descripcion VARCHAR(255), 
@categoria_id VARCHAR(6), @es_popular BIT
AS
BEGIN
    IF NOT EXISTS(SELECT sabor_id FROM Sabor WHERE sabor_id = @sabor_id)
        BEGIN
            IF EXISTS(SELECT categoria_id FROM Categoria_Helado WHERE categoria_id = @categoria_id)
                BEGIN
                    INSERT INTO Sabor(sabor_id, nombre, descripcion, categoria_id, es_popular)
                    VALUES(@sabor_id, @nombre, @descripcion, @categoria_id, @es_popular)
                    SELECT CodError = 0, Mensaje = 'Sabor agregado correctamente'
                END
            ELSE SELECT CodError = 1, Mensaje = 'Error: Categoría no existe'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: ID de sabor duplicado'
END
GO

-- Eliminar Sabor
IF OBJECT_ID('spEliminarSabor', 'P') IS NOT NULL
    DROP PROC spEliminarSabor
GO

CREATE PROC spEliminarSabor
@sabor_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT sabor_id FROM Sabor WHERE sabor_id = @sabor_id)    
        IF NOT EXISTS(SELECT sabor_id FROM Helado WHERE sabor_id = @sabor_id)
            BEGIN
                DELETE FROM Sabor WHERE sabor_id = @sabor_id
                SELECT CodError = 0, Mensaje = 'Sabor eliminado correctamente'
            END
        ELSE SELECT CodError = 1, Mensaje = 'Error: El sabor está en uso en la tabla Helado'
    ELSE SELECT CodError = 1, Mensaje = 'Error: El sabor no existe'
END
GO

-- Actualizar Sabor
IF OBJECT_ID('spActualizarSabor', 'P') IS NOT NULL
    DROP PROC spActualizarSabor
GO

CREATE PROC spActualizarSabor
@sabor_id VARCHAR(6), @nombre VARCHAR(50), @descripcion VARCHAR(255), 
@categoria_id VARCHAR(6), @es_popular BIT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Sabor WHERE sabor_id = @sabor_id)
        BEGIN
            IF EXISTS(SELECT categoria_id FROM Categoria_Helado WHERE categoria_id = @categoria_id)
                BEGIN
                    UPDATE Sabor
                    SET nombre = @nombre,
                        descripcion = @descripcion,
                        categoria_id = @categoria_id,
                        es_popular = @es_popular
                    WHERE sabor_id = @sabor_id;

                    SELECT CodError = 0, Mensaje = 'Sabor actualizado correctamente';
                END
            ELSE SELECT CodError = 1, Mensaje = 'Error: Categoría no existe';
        END
    ELSE
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: ID de sabor no existe';
        END
END;
GO

-- Buscar Sabores
IF OBJECT_ID('spBuscarSabor') IS NOT NULL
    DROP PROC spBuscarSabor
GO

CREATE PROC spBuscarSabor
@Texto VARCHAR(50), @Criterio VARCHAR(20)
AS
BEGIN
    IF(@Criterio = 'sabor_id')
        SELECT s.sabor_id, s.nombre, s.descripcion, c.nombre AS categoria, 
               s.es_popular, s.fecha_creacion
        FROM Sabor s
        JOIN Categoria_Helado c ON s.categoria_id = c.categoria_id
        WHERE s.sabor_id = @Texto
    ELSE IF(@Criterio = 'nombre')
        SELECT s.sabor_id, s.nombre, s.descripcion, c.nombre AS categoria, 
               s.es_popular, s.fecha_creacion
        FROM Sabor s
        JOIN Categoria_Helado c ON s.categoria_id = c.categoria_id
        WHERE s.nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'categoria')
        SELECT s.sabor_id, s.nombre, s.descripcion, c.nombre AS categoria, 
               s.es_popular, s.fecha_creacion
        FROM Sabor s
        JOIN Categoria_Helado c ON s.categoria_id = c.categoria_id
        WHERE c.nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'popular')
        SELECT s.sabor_id, s.nombre, s.descripcion, c.nombre AS categoria, 
               s.es_popular, s.fecha_creacion
        FROM Sabor s
        JOIN Categoria_Helado c ON s.categoria_id = c.categoria_id
        WHERE s.es_popular = CAST(@Texto AS BIT)
END
GO


/* Validacion de Complementos*/
------------------------------------------------------------------------
exec spListarSabores
go
exec spAgregarSabor 'SAB102', 'Fruta', 'dsasd', 'CAT002', '1' 
go
exec spEliminarSabor 'SAB102'
go
exec spActualizarSabor 'SAB099', 'Fruta', 'dsasd', 'CAT002', '1' 
go
exec spListarSabores
go
exec spBuscarSabor 'SAB001', 'sabor_id'
go
exec spBuscarSabor 'Chocolate', 'nombre'
go
exec spBuscarSabor 'Chocolates', 'categoria'
go
exec spBuscarSabor '1', 'es_popular'
go
------------------------------------------------------------------------
-- =============================================
-- Procedimientos para la tabla Tamaños
-- =============================================

-- Listar Tamaños
IF OBJECT_ID('spListarTamanos') IS NOT NULL
    DROP PROC spListarTamanos
GO

CREATE PROC spListarTamanos
AS
BEGIN
    SELECT tamano_id, nombre, precio_adicional, descripcion
    FROM Tamano_Helado
END
GO

-- Agregar Tamaño
IF OBJECT_ID('spAgregarTamano','P') IS NOT NULL
    DROP PROC spAgregarTamano
GO

CREATE PROC spAgregarTamano
@tamano_id VARCHAR(6), @nombre VARCHAR(20), @precio_adicional DECIMAL(10,2), @descripcion VARCHAR(100)
AS
BEGIN
    IF NOT EXISTS(SELECT tamano_id FROM Tamano_Helado WHERE tamano_id = @tamano_id)
        BEGIN
            INSERT INTO Tamano_Helado VALUES(@tamano_id, @nombre, @precio_adicional, @descripcion)
            SELECT CodError = 0, Mensaje = 'Tamaño agregado correctamente'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: ID de tamaño duplicado'
END
GO

-- Eliminar Tamaño
IF OBJECT_ID('spEliminarTamano', 'P') IS NOT NULL
    DROP PROC spEliminarTamano
GO

CREATE PROC spEliminarTamano
@tamano_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT tamano_id FROM Tamano_Helado WHERE tamano_id = @tamano_id)    
        IF NOT EXISTS(SELECT tamano_id FROM Helado WHERE tamano_id = @tamano_id)
            BEGIN
                DELETE FROM Tamano_Helado WHERE tamano_id = @tamano_id
                SELECT CodError = 0, Mensaje = 'Tamaño eliminado correctamente'
            END
        ELSE SELECT CodError = 1, Mensaje = 'Error: El tamaño está en uso en la tabla Helado'
    ELSE SELECT CodError = 1, Mensaje = 'Error: El tamaño no existe'
END
GO

-- Actualizar Tamaño
IF OBJECT_ID('spActualizarTamano', 'P') IS NOT NULL
    DROP PROC spActualizarTamano
GO

CREATE PROC spActualizarTamano
@tamano_id VARCHAR(6), @nombre VARCHAR(20), @precio_adicional DECIMAL(10,2), @descripcion VARCHAR(100)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Tamano_Helado WHERE tamano_id = @tamano_id)
        BEGIN
            UPDATE Tamano_Helado
            SET nombre = @nombre,
                precio_adicional = @precio_adicional,
                descripcion = @descripcion
            WHERE tamano_id = @tamano_id;

            SELECT CodError = 0, Mensaje = 'Tamaño actualizado correctamente';
        END
    ELSE
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: ID de tamaño no existe';
        END
END;
GO

-- Buscar Tamaños
IF OBJECT_ID('spBuscarTamano') IS NOT NULL
    DROP PROC spBuscarTamano
GO

CREATE PROC spBuscarTamano
@Texto VARCHAR(50), @Criterio VARCHAR(20)
AS
BEGIN
    IF(@Criterio = 'tamano_id')
        SELECT tamano_id, nombre, precio_adicional, descripcion
        FROM Tamano_Helado
        WHERE tamano_id = @Texto
    ELSE IF(@Criterio = 'nombre')
        SELECT tamano_id, nombre, precio_adicional, descripcion
        FROM Tamano_Helado
        WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'precio')
        SELECT tamano_id, nombre, precio_adicional, descripcion
        FROM Tamano_Helado
        WHERE precio_adicional = CAST(@Texto AS DECIMAL(10,2))
END
GO



/* Validacion de Complementos*/
------------------------------------------------------------------------
exec spListarTamanos
go
exec spAgregarTamano 'TAM101', 'dssdds', '2.00', 'dsasddsdsa'
go
exec spEliminarTamano 'TAM101'
go 
exec spActualizarTamano 'TAM100', 'dssdds', '2.00', 'dsasddsdsa'
go
exec spListarTamanos
go
exec spBuscarTamano 'TAM100', 'tamano_id'
go
exec spBuscarTamano 'Grande', 'nombre'
go
exec spBuscarTamano '2.00', 'precio'
go
------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Toppings
-- =============================================
-- Listar Toppings
IF OBJECT_ID('spListarToppings') IS NOT NULL
    DROP PROC spListarToppings
GO

CREATE PROC spListarToppings
AS
BEGIN
    SELECT topping_id, nombre, precio, stock, 
           CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS estado
    FROM Topping
END
GO


-- Agregar Topping
IF OBJECT_ID('spAgregarTopping','P') IS NOT NULL
    DROP PROC spAgregarTopping
GO

CREATE PROC spAgregarTopping
@topping_id VARCHAR(6), @nombre VARCHAR(50), @precio DECIMAL(10,2), @stock INT, @activo BIT
AS
BEGIN
    IF NOT EXISTS(SELECT topping_id FROM Topping WHERE topping_id = @topping_id)
        BEGIN
            INSERT INTO Topping VALUES(@topping_id, @nombre, @precio, @stock, @activo)
            SELECT CodError = 0, Mensaje = 'Topping agregado correctamente'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: ID de topping duplicado'
END
GO


-- Eliminar Topping
IF OBJECT_ID('spEliminarTopping', 'P') IS NOT NULL
    DROP PROC spEliminarTopping
GO

CREATE PROC spEliminarTopping
@topping_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT topping_id FROM Topping WHERE topping_id = @topping_id)    
        BEGIN
            DELETE FROM Topping WHERE topping_id = @topping_id
            SELECT CodError = 0, Mensaje = 'Topping eliminado correctamente'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: El topping no existe'
END
GO

-- Actualizar Topping
IF OBJECT_ID('spActualizarTopping', 'P') IS NOT NULL
    DROP PROC spActualizarTopping
GO

CREATE PROC spActualizarTopping
@topping_id VARCHAR(6), @nombre VARCHAR(50), @precio DECIMAL(10,2), @stock INT, @activo BIT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Topping WHERE topping_id = @topping_id)
        BEGIN
            UPDATE Topping
            SET nombre = @nombre,
                precio = @precio,
                stock = @stock,
                activo = @activo
            WHERE topping_id = @topping_id;

            SELECT CodError = 0, Mensaje = 'Topping actualizado correctamente';
        END
    ELSE
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: ID de topping no existe';
        END
END;
GO

-- Buscar Toppings
IF OBJECT_ID('spBuscarTopping') IS NOT NULL
    DROP PROC spBuscarTopping
GO

CREATE PROC spBuscarTopping
@Texto VARCHAR(50), @Criterio VARCHAR(20)
AS
BEGIN
    IF(@Criterio = 'topping_id')
        SELECT topping_id, nombre, precio, stock, 
               CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS estado
        FROM Topping
        WHERE topping_id = @Texto
    ELSE IF(@Criterio = 'nombre')
        SELECT topping_id, nombre, precio, stock, 
               CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS estado
        FROM Topping
        WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'activo')
        SELECT topping_id, nombre, precio, stock, 
               CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS estado
        FROM Topping
        WHERE activo = CAST(@Texto AS BIT)
END
GO
/* Validacion de Complementos*/
------------------------------------------------------------------------
exec spListarToppings
go
exec spAgregarTopping 'TOP101', 'sdsdads', '0.50', '30', '1'
go
exec spEliminarTopping 'TOP101'
go
exec spActualizarTopping 'TOP100', 'sdsdads', '0.50', '30', '1'
go
exec spListarToppings
go
exec spBuscarTopping 'TOP001', 'topping_id'
go
exec spBuscarTopping 'Fresa', 'nombre'
go
exec spBuscarTopping '1', 'activo'
go
------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Complementos
-- =============================================
-- Listar Complementos
IF OBJECT_ID('spListarComplementos') IS NOT NULL
    DROP PROC spListarComplementos
GO

CREATE PROC spListarComplementos
AS
BEGIN
    SELECT complemento_id, nombre, costo, stock
    FROM Complemento
END
GO

-- Agregar Complemento
IF OBJECT_ID('spAgregarComplemento','P') IS NOT NULL
    DROP PROC spAgregarComplemento
GO

CREATE PROC spAgregarComplemento
@complemento_id VARCHAR(6), @nombre VARCHAR(50), @costo DECIMAL(10,2), @stock INT
AS
BEGIN
    IF NOT EXISTS(SELECT complemento_id FROM Complemento WHERE complemento_id = @complemento_id)
        BEGIN
            INSERT INTO Complemento VALUES(@complemento_id, @nombre, @costo, @stock)
            SELECT CodError = 0, Mensaje = 'Complemento agregado correctamente'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: ID de complemento duplicado'
END
GO

-- Eliminar Complemento
IF OBJECT_ID('spEliminarComplemento', 'P') IS NOT NULL
    DROP PROC spEliminarComplemento
GO

CREATE PROC spEliminarComplemento
@complemento_id VARCHAR(6)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            -- Primero eliminar los detalles de pedido relacionados
            DELETE FROM Detalle_Pedido WHERE complemento_id = @complemento_id
            
            -- Luego eliminar el complemento
            DELETE FROM Complemento WHERE complemento_id = @complemento_id
            
            SELECT CodError = 0, Mensaje = 'Complemento eliminado correctamente'
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SELECT CodError = 1, Mensaje = 'Error al eliminar complemento: ' + ERROR_MESSAGE()
    END CATCH
END
GO

-- Actualizar Complemento
IF OBJECT_ID('spActualizarComplemento', 'P') IS NOT NULL
    DROP PROC spActualizarComplemento
GO

CREATE PROC spActualizarComplemento
@complemento_id VARCHAR(6), @nombre VARCHAR(50), @costo DECIMAL(10,2), @stock INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Complemento WHERE complemento_id = @complemento_id)
        BEGIN
            UPDATE Complemento
            SET nombre = @nombre,
                costo = @costo,
                stock = @stock
            WHERE complemento_id = @complemento_id;

            SELECT CodError = 0, Mensaje = 'Complemento actualizado correctamente';
        END
    ELSE
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: ID de complemento no existe';
        END
END;
GO

-- Buscar Complementos
IF OBJECT_ID('spBuscarComplemento') IS NOT NULL
    DROP PROC spBuscarComplemento
GO

CREATE PROC spBuscarComplemento
@Texto VARCHAR(50), @Criterio VARCHAR(20)
AS
BEGIN
    IF(@Criterio = 'complemento_id')
        SELECT complemento_id, nombre, costo, stock
        FROM Complemento
        WHERE complemento_id = @Texto
    ELSE IF(@Criterio = 'nombre')
        SELECT complemento_id, nombre, costo, stock
        FROM Complemento
        WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'stock')
        SELECT complemento_id, nombre, costo, stock
        FROM Complemento
        WHERE stock <= CAST(@Texto AS INT)
END
GO
/* Validacion de Procedimientos*/
----------------------------------------------------------------------------------------
--Listar Complementos
exec spListarComplementos
go
exec spAgregarComplemento 'COMP30', 'dsdd', '0.30', '20'
go
exec spEliminarComplemento 'COMP30'
go
-- Intentar actualizar complemento que no existe
EXEC spActualizarComplemento 
    @complemento_id = 'COMP999',
    @nombre = 'No Existe',
    @costo = 0.99,
    @stock = 0;
-- Buscar por ID de complemento
EXEC spBuscarComplemento 'COMP01', 'complemento_id';

-- Buscar por nombre (búsqueda parcial)
EXEC spBuscarComplemento 'Choco', 'nombre';

-- Buscar por stock (menor o igual que)
EXEC spBuscarComplemento '10', 'stock';
----------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Helado
-- =============================================
-- Listar Helados
IF OBJECT_ID('spListarHelados') IS NOT NULL
    DROP PROC spListarHelados
GO

CREATE PROC spListarHelados
AS
BEGIN
    SELECT h.helado_id, s.nombre AS sabor, t.nombre AS tamaño, 
           h.precio_base, t.precio_adicional, 
           (h.precio_base + t.precio_adicional) AS precio_total,
           CASE WHEN h.en_stock = 1 THEN 'Disponible' ELSE 'Agotado' END AS estado,
           h.imagen_url
    FROM Helado h
    JOIN Sabor s ON h.sabor_id = s.sabor_id
    JOIN Tamano_Helado t ON h.tamano_id = t.tamano_id
END
GO

-- Agregar Helado
IF OBJECT_ID('spAgregarHelado','P') IS NOT NULL
    DROP PROC spAgregarHelado
GO

CREATE PROC spAgregarHelado
@helado_id VARCHAR(6), @sabor_id VARCHAR(6), @tamano_id VARCHAR(6), 
@precio_base DECIMAL(10,2), @en_stock BIT, @imagen_url VARCHAR(255)
AS
BEGIN
    IF NOT EXISTS(SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
        BEGIN
            IF EXISTS(SELECT sabor_id FROM Sabor WHERE sabor_id = @sabor_id)
                BEGIN
                    IF EXISTS(SELECT tamano_id FROM Tamano_Helado WHERE tamano_id = @tamano_id)
                        BEGIN
                            INSERT INTO Helado VALUES(@helado_id, @sabor_id, @tamano_id, @precio_base, @en_stock, @imagen_url)
                            SELECT CodError = 0, Mensaje = 'Helado agregado correctamente'
                        END
                    ELSE SELECT CodError = 1, Mensaje = 'Error: Tamaño no existe'
                END
            ELSE SELECT CodError = 1, Mensaje = 'Error: Sabor no existe'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: ID de helado duplicado'
END
GO

-- Eliminar Helado (con validación de todas las relaciones)
IF OBJECT_ID('spEliminarHelado', 'P') IS NOT NULL
    DROP PROC spEliminarHelado
GO

CREATE PROC spEliminarHelado
@helado_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)    
        BEGIN
            -- Verificar todas las tablas que referencian a Helado
            IF NOT EXISTS(SELECT helado_id FROM Detalle_Pedido WHERE helado_id = @helado_id)
                IF NOT EXISTS(SELECT helado_id FROM Ingrediente WHERE helado_id = @helado_id)
                    IF NOT EXISTS(SELECT helado_id FROM Helado_Promocion WHERE helado_id = @helado_id)
                        IF NOT EXISTS(SELECT helado_id FROM Resena WHERE helado_id = @helado_id)
                            BEGIN
                                DELETE FROM Helado WHERE helado_id = @helado_id
                                SELECT CodError = 0, Mensaje = 'Helado eliminado correctamente'
                            END
                        ELSE SELECT CodError = 1, Mensaje = 'Error: Existen reseñas asociadas a este helado'
                    ELSE SELECT CodError = 1, Mensaje = 'Error: El helado está en promociones'
                ELSE SELECT CodError = 1, Mensaje = 'Error: El helado tiene ingredientes asociados'
            ELSE SELECT CodError = 1, Mensaje = 'Error: El helado está en pedidos'
        END
    ELSE SELECT CodError = 1, Mensaje = 'Error: El helado no existe'
END
GO

-- Actualizar Helado
IF OBJECT_ID('spActualizarHelado', 'P') IS NOT NULL
    DROP PROC spActualizarHelado
GO

CREATE PROC spActualizarHelado
@helado_id VARCHAR(6), @sabor_id VARCHAR(6), @tamano_id VARCHAR(6), 
@precio_base DECIMAL(10,2), @en_stock BIT, @imagen_url VARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Helado WHERE helado_id = @helado_id)
        BEGIN
            IF EXISTS(SELECT sabor_id FROM Sabor WHERE sabor_id = @sabor_id)
                BEGIN
                    IF EXISTS(SELECT tamano_id FROM Tamano_Helado WHERE tamano_id = @tamano_id)
                        BEGIN
                            UPDATE Helado
                            SET sabor_id = @sabor_id,
                                tamano_id = @tamano_id,
                                precio_base = @precio_base,
                                en_stock = @en_stock,
                                imagen_url = @imagen_url
                            WHERE helado_id = @helado_id;

                            SELECT CodError = 0, Mensaje = 'Helado actualizado correctamente';
                        END
                    ELSE SELECT CodError = 1, Mensaje = 'Error: Tamaño no existe';
                END
            ELSE SELECT CodError = 1, Mensaje = 'Error: Sabor no existe';
        END
    ELSE
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: ID de helado no existe';
        END
END;
GO

-- Buscar Helados
IF OBJECT_ID('spBuscarHelado') IS NOT NULL
    DROP PROC spBuscarHelado
GO

CREATE PROC spBuscarHelado
@Texto VARCHAR(50), @Criterio VARCHAR(20)
AS
BEGIN
    IF(@Criterio = 'helado_id')
        SELECT h.helado_id, s.nombre AS sabor, t.nombre AS tamaño, 
               h.precio_base, t.precio_adicional, 
               (h.precio_base + t.precio_adicional) AS precio_total,
               CASE WHEN h.en_stock = 1 THEN 'Disponible' ELSE 'Agotado' END AS estado,
               h.imagen_url
        FROM Helado h
        JOIN Sabor s ON h.sabor_id = s.sabor_id
        JOIN Tamano_Helado t ON h.tamano_id = t.tamano_id
        WHERE h.helado_id = @Texto
    ELSE IF(@Criterio = 'sabor')
        SELECT h.helado_id, s.nombre AS sabor, t.nombre AS tamaño, 
               h.precio_base, t.precio_adicional, 
               (h.precio_base + t.precio_adicional) AS precio_total,
               CASE WHEN h.en_stock = 1 THEN 'Disponible' ELSE 'Agotado' END AS estado,
               h.imagen_url
        FROM Helado h
        JOIN Sabor s ON h.sabor_id = s.sabor_id
        JOIN Tamano_Helado t ON h.tamano_id = t.tamano_id
        WHERE s.nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'tamaño')
        SELECT h.helado_id, s.nombre AS sabor, t.nombre AS tamaño, 
               h.precio_base, t.precio_adicional, 
               (h.precio_base + t.precio_adicional) AS precio_total,
               CASE WHEN h.en_stock = 1 THEN 'Disponible' ELSE 'Agotado' END AS estado,
               h.imagen_url
        FROM Helado h
        JOIN Sabor s ON h.sabor_id = s.sabor_id
        JOIN Tamano_Helado t ON h.tamano_id = t.tamano_id
        WHERE t.nombre LIKE '%' + @Texto + '%'
    ELSE IF(@Criterio = 'stock')
        SELECT h.helado_id, s.nombre AS sabor, t.nombre AS tamaño, 
               h.precio_base, t.precio_adicional, 
               (h.precio_base + t.precio_adicional) AS precio_total,
               CASE WHEN h.en_stock = 1 THEN 'Disponible' ELSE 'Agotado' END AS estado,
               h.imagen_url
        FROM Helado h
        JOIN Sabor s ON h.sabor_id = s.sabor_id
        JOIN Tamano_Helado t ON h.tamano_id = t.tamano_id
        WHERE h.en_stock = CAST(@Texto AS BIT)
END
GO
/* Validacion de Procedimientos*/
-----------------------------------------------------------------------------------------------
exec spListarHelados
go
exec spAgregarHelado 'HEL101', 'SAB090', 'TAM050', '6.00', '1', 'https://ejemplo.com/rum_raisin_large.jpg'
go
exec spEliminarHelado 'HEL101'
go
exec spActualizarHelado 'HEL099', 'SAB090', 'TAM050', '6.00', '1', 'https://ejemplo.com/rum_raisin_large.jpg'
go
exec spBuscarHelado 'HEL002', 'helado_id'
go
exec spBuscarHelado 'Vainilla', 'sabor'
go
exec spBuscarHelado 'TAM050', 'tamaño'
go
exec spBuscarHelado '1', 'stock'
go
-- =============================================
-- Procedimientos para la tabla Cliente
-- =============================================

-- Listar Clientes
IF OBJECT_ID('spListarClientes') IS NOT NULL DROP PROC spListarClientes
GO
CREATE PROC spListarClientes
AS
BEGIN
    SELECT DNI, nombre, telefono, email, direccion, fecha_registro, puntos_fidelidad
    FROM Cliente
END
GO

-- Agregar Cliente
IF OBJECT_ID('spAgregarCliente') IS NOT NULL DROP PROC spAgregarCliente
GO
CREATE PROC spAgregarCliente
    @DNI VARCHAR(8),
    @nombre VARCHAR(100),
    @telefono VARCHAR(20) = NULL,
    @email VARCHAR(100) = NULL,
    @direccion VARCHAR(255) = NULL,
    @puntos_fidelidad INT = 0
AS
BEGIN
    IF NOT EXISTS (SELECT DNI FROM Cliente WHERE DNI = @DNI)
    BEGIN
        INSERT INTO Cliente(DNI, nombre, telefono, email, direccion, puntos_fidelidad)
        VALUES (@DNI, @nombre, @telefono, @email, @direccion, @puntos_fidelidad)
        SELECT CodError = 0, Mensaje = 'Cliente agregado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: DNI de cliente ya existe'
END
GO

-- Eliminar Cliente
IF OBJECT_ID('spEliminarCliente') IS NOT NULL DROP PROC spEliminarCliente
GO
CREATE PROC spEliminarCliente
    @DNI VARCHAR(8)
AS
BEGIN
    IF EXISTS (SELECT DNI FROM Cliente WHERE DNI = @DNI)
    BEGIN
        -- Verificar si el cliente tiene pedidos asociados
        IF NOT EXISTS (SELECT cliente_id FROM Pedido WHERE cliente_id = @DNI)
        BEGIN
            DELETE FROM Cliente WHERE DNI = @DNI
            SELECT CodError = 0, Mensaje = 'Cliente eliminado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Cliente tiene pedidos asociados'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Cliente no existe'
END
GO

-- Actualizar Cliente
IF OBJECT_ID('spActualizarCliente') IS NOT NULL DROP PROC spActualizarCliente
GO
CREATE PROC spActualizarCliente
    @DNI VARCHAR(8),
    @nombre VARCHAR(100),
    @telefono VARCHAR(20) = NULL,
    @email VARCHAR(100) = NULL,
    @direccion VARCHAR(255) = NULL,
    @puntos_fidelidad INT = NULL
AS
BEGIN
    IF EXISTS (SELECT DNI FROM Cliente WHERE DNI = @DNI)
    BEGIN
        UPDATE Cliente SET
            nombre = @nombre,
            telefono = ISNULL(@telefono, telefono),
            email = ISNULL(@email, email),
            direccion = ISNULL(@direccion, direccion),
            puntos_fidelidad = ISNULL(@puntos_fidelidad, puntos_fidelidad)
        WHERE DNI = @DNI
        
        SELECT CodError = 0, Mensaje = 'Cliente actualizado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Cliente no existe'
END
GO

-- Buscar Cliente
IF OBJECT_ID('spBuscarCliente') IS NOT NULL DROP PROC spBuscarCliente
GO
CREATE PROC spBuscarCliente
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'dni'
        SELECT DNI, nombre, telefono, email, direccion, fecha_registro, puntos_fidelidad
        FROM Cliente
        WHERE DNI LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'nombre'
        SELECT DNI, nombre, telefono, email, direccion, fecha_registro, puntos_fidelidad
        FROM Cliente
        WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'email'
        SELECT DNI, nombre, telefono, email, direccion, fecha_registro, puntos_fidelidad
        FROM Cliente
        WHERE email LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'telefono'
        SELECT DNI, nombre, telefono, email, direccion, fecha_registro, puntos_fidelidad
        FROM Cliente
        WHERE telefono LIKE '%' + @Texto + '%'
END
GO

/* Validacion de Procedimientos*/
-----------------------------------------------------------------------------------------------
-- Listar todos los clientes
EXEC spListarClientes;

-- Agregar un nuevo cliente válido
EXEC spAgregarCliente 
    @DNI = '98765432',
    @nombre = 'Nuevo Cliente',
    @telefono = '555-9999',
    @email = 'nuevo@email.com',
    @direccion = 'Calle Nueva 123',
    @puntos_fidelidad = 50;
-- Intentar agregar cliente con DNI existente
EXEC spAgregarCliente 
    @DNI = '12345678', -- DNI existente
    @nombre = 'Cliente Existente',
    @telefono = '555-1111';
-- Eliminar cliente sin pedidos asociados
EXEC spEliminarCliente '00112233';
-- Intentar eliminar cliente que no existe
EXEC spEliminarCliente '99999999';
-- Actualizar todos los datos de un cliente
EXEC spActualizarCliente 
    @DNI = '12345678',
    @nombre = 'Juan Pérez Actualizado',
    @telefono = '555-1212',
    @email = 'juan.actualizado@email.com',
    @direccion = 'Nueva Dirección 456',
    @puntos_fidelidad = 200;
-- Actualización parcial (solo nombre y teléfono)
EXEC spActualizarCliente 
    @DNI = '23456789',
    @nombre = 'María González Modificado',
    @telefono = '555-2323';
-- Intentar actualizar cliente que no existe
EXEC spActualizarCliente 
    @DNI = '99999999',
    @nombre = 'No Existe';
-- Buscar por DNI
EXEC spBuscarCliente '12345678', 'dni';
-- Buscar por nombre
EXEC spBuscarCliente 'María', 'nombre';
-- Buscar por email
EXEC spBuscarCliente '@email.com', 'email';
-- Buscar por teléfono
EXEC spBuscarCliente '555-', 'telefono';
-----------------------------------------------------------------------------------------------
-- =============================================
-- Procedimientos para la tabla Empleado
-- =============================================

-- Listar Empleados
IF OBJECT_ID('spListarEmpleados') IS NOT NULL DROP PROC spListarEmpleados
GO
CREATE PROC spListarEmpleados
AS
BEGIN
    SELECT empleado_id, nombre, puesto, salario, fecha_contratacion, telefono, activo
    FROM Empleado
END
GO

-- Agregar Empleado
IF OBJECT_ID('spAgregarEmpleado') IS NOT NULL DROP PROC spAgregarEmpleado
GO
CREATE PROC spAgregarEmpleado
    @empleado_id VARCHAR(6),
    @nombre VARCHAR(100),
    @puesto VARCHAR(50),
    @salario DECIMAL(10,2),
    @fecha_contratacion DATE,
    @telefono VARCHAR(20) = NULL,
    @activo BIT = 1
AS
BEGIN
    IF NOT EXISTS (SELECT empleado_id FROM Empleado WHERE empleado_id = @empleado_id)
    BEGIN
        INSERT INTO Empleado(empleado_id, nombre, puesto, salario, fecha_contratacion, telefono, activo)
        VALUES (@empleado_id, @nombre, @puesto, @salario, @fecha_contratacion, @telefono, @activo)
        SELECT CodError = 0, Mensaje = 'Empleado agregado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de empleado ya existe'
END
GO

-- Eliminar Empleado
IF OBJECT_ID('spEliminarEmpleado') IS NOT NULL DROP PROC spEliminarEmpleado
GO
CREATE PROC spEliminarEmpleado
    @empleado_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT empleado_id FROM Empleado WHERE empleado_id = @empleado_id)
    BEGIN
        -- Verificar si el empleado tiene turnos asociados
        IF NOT EXISTS (SELECT empleado_id FROM Turno_Empleado WHERE empleado_id = @empleado_id)
        BEGIN
            DELETE FROM Empleado WHERE empleado_id = @empleado_id
            SELECT CodError = 0, Mensaje = 'Empleado eliminado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Empleado tiene turnos asociados'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Empleado no existe'
END
GO

-- Actualizar Empleado
IF OBJECT_ID('spActualizarEmpleado') IS NOT NULL DROP PROC spActualizarEmpleado
GO
CREATE PROC spActualizarEmpleado
    @empleado_id VARCHAR(6),
    @nombre VARCHAR(100) = NULL,
    @puesto VARCHAR(50) = NULL,
    @salario DECIMAL(10,2) = NULL,
    @fecha_contratacion DATE = NULL,
    @telefono VARCHAR(20) = NULL,
    @activo BIT = NULL
AS
BEGIN
    IF EXISTS (SELECT empleado_id FROM Empleado WHERE empleado_id = @empleado_id)
    BEGIN
        UPDATE Empleado SET
            nombre = ISNULL(@nombre, nombre),
            puesto = ISNULL(@puesto, puesto),
            salario = ISNULL(@salario, salario),
            fecha_contratacion = ISNULL(@fecha_contratacion, fecha_contratacion),
            telefono = ISNULL(@telefono, telefono),
            activo = ISNULL(@activo, activo)
        WHERE empleado_id = @empleado_id
        
        SELECT CodError = 0, Mensaje = 'Empleado actualizado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Empleado no existe'
END
GO

-- Buscar Empleado
IF OBJECT_ID('spBuscarEmpleado') IS NOT NULL DROP PROC spBuscarEmpleado
GO
CREATE PROC spBuscarEmpleado
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT empleado_id, nombre, puesto, salario, fecha_contratacion, telefono, activo
        FROM Empleado
        WHERE empleado_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'nombre'
        SELECT empleado_id, nombre, puesto, salario, fecha_contratacion, telefono, activo
        FROM Empleado
        WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'puesto'
        SELECT empleado_id, nombre, puesto, salario, fecha_contratacion, telefono, activo
        FROM Empleado
        WHERE puesto LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'activo'
        SELECT empleado_id, nombre, puesto, salario, fecha_contratacion, telefono, activo
        FROM Empleado
        WHERE activo = CAST(@Texto AS BIT)
END
GO
/* Validacion de Procedimientos*/
-----------------------------------------------------------------------------------------------
-- Listar todos los empleados
EXEC spListarEmpleados;
-- Agregar un nuevo empleado válido
EXEC spAgregarEmpleado 
    @empleado_id = 'EMP102',
    @nombre = 'Nuevo Empleado',
    @puesto = 'Asistente',
    @salario = 2100.00,
    @fecha_contratacion = '2023-10-10',
    @telefono = '555-0101',
    @activo = 1;
-- Intentar agregar empleado con ID existente
EXEC spAgregarEmpleado 
    @empleado_id = 'EMP001', -- ID existente
    @nombre = 'Empleado Existente',
    @puesto = 'Gerente',
    @salario = 3500.00,
    @fecha_contratacion = '2019-05-10';
-- Eliminar empleado sin turnos asociados (EMP101 no tiene turnos en los datos)
EXEC spEliminarEmpleado 'EMP101';
-- Intentar eliminar empleado con turnos asociados
EXEC spEliminarEmpleado 'EMP001';
-- Intentar eliminar empleado que no existe
EXEC spEliminarEmpleado 'EMP999';
-- Actualizar todos los datos de un empleado
EXEC spActualizarEmpleado 
    @empleado_id = 'EMP001',
    @nombre = 'Alejandro Soto Actualizado',
    @puesto = 'Gerente General',
    @salario = 4000.00,
    @fecha_contratacion = '2019-05-10',
    @telefono = '555-1122',
    @activo = 1;
-- Actualización parcial (solo puesto y salario)
EXEC spActualizarEmpleado 
    @empleado_id = 'EMP002',
    @puesto = 'Subgerente General',
    @salario = 3200.00;
-- Intentar actualizar empleado que no existe
EXEC spActualizarEmpleado 
    @empleado_id = 'EMP999',
    @nombre = 'No Existe';
-- Buscar por ID de empleado
EXEC spBuscarEmpleado 'EMP001', 'id';
-- Buscar por nombre
EXEC spBuscarEmpleado 'Mariana', 'nombre';
-- Buscar por puesto
EXEC spBuscarEmpleado 'Gerente', 'puesto';
-- Buscar por estado activo
EXEC spBuscarEmpleado '1', 'activo';
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Listar Turnos de Empleados
IF OBJECT_ID('spListarTurnosEmpleados') IS NOT NULL DROP PROC spListarTurnosEmpleados
GO
CREATE PROC spListarTurnosEmpleados
AS
BEGIN
    SELECT t.turno_id, t.empleado_id, e.nombre AS nombre_empleado, 
           t.fecha, t.hora_inicio, t.hora_fin
    FROM Turno_Empleado t
    INNER JOIN Empleado e ON t.empleado_id = e.empleado_id
END
GO

-- Agregar Turno a Empleado
IF OBJECT_ID('spAgregarTurnoEmpleado') IS NOT NULL DROP PROC spAgregarTurnoEmpleado
GO
CREATE PROC spAgregarTurnoEmpleado
    @turno_id VARCHAR(6),
    @empleado_id VARCHAR(6),
    @fecha DATE,
    @hora_inicio TIME,
    @hora_fin TIME
AS
BEGIN
    -- Verificar si el empleado existe
    IF NOT EXISTS (SELECT empleado_id FROM Empleado WHERE empleado_id = @empleado_id)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: Empleado no existe'
        RETURN
    END
    
    -- Verificar si el turno ya existe
    IF EXISTS (SELECT turno_id FROM Turno_Empleado WHERE turno_id = @turno_id)
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: ID de turno ya existe'
        RETURN
    END
    
    -- Verificar solapamiento de horarios
    IF EXISTS (
        SELECT 1 FROM Turno_Empleado 
        WHERE empleado_id = @empleado_id 
        AND fecha = @fecha
        AND (
            (@hora_inicio BETWEEN hora_inicio AND hora_fin) OR
            (@hora_fin BETWEEN hora_inicio AND hora_fin) OR
            (hora_inicio BETWEEN @hora_inicio AND @hora_fin)
        )
    ) -- Aquí faltaba este paréntesis de cierre
    BEGIN
        SELECT CodError = 1, Mensaje = 'Error: El empleado ya tiene un turno en ese horario'
        RETURN
    END
    
    -- Insertar el turno
    INSERT INTO Turno_Empleado(turno_id, empleado_id, fecha, hora_inicio, hora_fin)
    VALUES (@turno_id, @empleado_id, @fecha, @hora_inicio, @hora_fin)
    
    SELECT CodError = 0, Mensaje = 'Turno agregado correctamente'
END
GO

-- Eliminar Turno de Empleado
IF OBJECT_ID('spEliminarTurnoEmpleado') IS NOT NULL DROP PROC spEliminarTurnoEmpleado
GO
CREATE PROC spEliminarTurnoEmpleado
    @turno_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT turno_id FROM Turno_Empleado WHERE turno_id = @turno_id)
    BEGIN
        DELETE FROM Turno_Empleado WHERE turno_id = @turno_id
        SELECT CodError = 0, Mensaje = 'Turno eliminado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Turno no existe'
END
GO

IF OBJECT_ID('spActualizarTurnoEmpleado') IS NOT NULL DROP PROC spActualizarTurnoEmpleado
GO
CREATE PROC spActualizarTurnoEmpleado
    @turno_id VARCHAR(6),
    @empleado_id VARCHAR(6) = NULL,
    @fecha DATE = NULL,
    @hora_inicio TIME = NULL,
    @hora_fin TIME = NULL
AS
BEGIN
    IF EXISTS (SELECT turno_id FROM Turno_Empleado WHERE turno_id = @turno_id)
    BEGIN
        -- Verificar si el empleado existe (si se está actualizando)
        IF @empleado_id IS NOT NULL AND 
           NOT EXISTS (SELECT empleado_id FROM Empleado WHERE empleado_id = @empleado_id)
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: Empleado no existe'
            RETURN
        END
        
        -- Verificar solapamiento de horarios (excepto para el mismo turno)
        IF (@fecha IS NOT NULL AND @hora_inicio IS NOT NULL AND @hora_fin IS NOT NULL) AND
           EXISTS (
               SELECT 1 FROM Turno_Empleado 
               WHERE empleado_id = ISNULL(@empleado_id, (SELECT empleado_id FROM Turno_Empleado WHERE turno_id = @turno_id))
               AND fecha = ISNULL(@fecha, (SELECT fecha FROM Turno_Empleado WHERE turno_id = @turno_id))
               AND turno_id <> @turno_id
               AND (
                   (ISNULL(@hora_inicio, '00:00') BETWEEN hora_inicio AND hora_fin) OR
                   (ISNULL(@hora_fin, '23:59') BETWEEN hora_inicio AND hora_fin) OR
                   (hora_inicio BETWEEN ISNULL(@hora_inicio, '00:00') AND ISNULL(@hora_fin, '23:59'))
               )
        ) -- Aquí faltaba este paréntesis de cierre
        BEGIN
            SELECT CodError = 1, Mensaje = 'Error: El empleado ya tiene un turno en ese horario'
            RETURN
        END
        
        -- Actualizar el turno
        UPDATE Turno_Empleado SET
            empleado_id = ISNULL(@empleado_id, empleado_id),
            fecha = ISNULL(@fecha, fecha),
            hora_inicio = ISNULL(@hora_inicio, hora_inicio),
            hora_fin = ISNULL(@hora_fin, hora_fin)
        WHERE turno_id = @turno_id
        
        SELECT CodError = 0, Mensaje = 'Turno actualizado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Turno no existe'
END
GO
-- Buscar Turnos de Empleados
IF OBJECT_ID('spBuscarTurnosEmpleados') IS NOT NULL DROP PROC spBuscarTurnosEmpleados
GO
CREATE PROC spBuscarTurnosEmpleados
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id_turno'
        SELECT t.turno_id, t.empleado_id, e.nombre AS nombre_empleado, 
               t.fecha, t.hora_inicio, t.hora_fin
        FROM Turno_Empleado t
        INNER JOIN Empleado e ON t.empleado_id = e.empleado_id
        WHERE t.turno_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'id_empleado'
        SELECT t.turno_id, t.empleado_id, e.nombre AS nombre_empleado, 
               t.fecha, t.hora_inicio, t.hora_fin
        FROM Turno_Empleado t
        INNER JOIN Empleado e ON t.empleado_id = e.empleado_id
        WHERE t.empleado_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'nombre_empleado'
        SELECT t.turno_id, t.empleado_id, e.nombre AS nombre_empleado, 
               t.fecha, t.hora_inicio, t.hora_fin
        FROM Turno_Empleado t
        INNER JOIN Empleado e ON t.empleado_id = e.empleado_id
        WHERE e.nombre LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'fecha'
        SELECT t.turno_id, t.empleado_id, e.nombre AS nombre_empleado, 
               t.fecha, t.hora_inicio, t.hora_fin
        FROM Turno_Empleado t
        INNER JOIN Empleado e ON t.empleado_id = e.empleado_id
        WHERE CONVERT(VARCHAR, t.fecha, 103) LIKE '%' + @Texto + '%'
END
GO

-- Obtener Turnos por Empleado y Fecha
IF OBJECT_ID('spObtenerTurnosPorEmpleadoFecha') IS NOT NULL DROP PROC spObtenerTurnosPorEmpleadoFecha
GO
CREATE PROC spObtenerTurnosPorEmpleadoFecha
    @empleado_id VARCHAR(6) = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL
AS
BEGIN
    SELECT t.turno_id, t.empleado_id, e.nombre AS nombre_empleado, 
           t.fecha, t.hora_inicio, t.hora_fin
    FROM Turno_Empleado t
    INNER JOIN Empleado e ON t.empleado_id = e.empleado_id
    WHERE (@empleado_id IS NULL OR t.empleado_id = @empleado_id)
    AND (@fecha_inicio IS NULL OR t.fecha >= @fecha_inicio)
    AND (@fecha_fin IS NULL OR t.fecha <= @fecha_fin)
    ORDER BY t.fecha, t.hora_inicio
END
GO

/* Validación de Procedimientos para Turno_Empleado */
-----------------------------------------------------------------------------------------------
-- Listar todos los turnos
EXEC spListarTurnosEmpleados;

-- Agregar un nuevo turno válido
EXEC spAgregarTurnoEmpleado 
    @turno_id = 'TUR101',
    @empleado_id = 'EMP001',
    @fecha = '2023-01-21', -- Nueva fecha
    @hora_inicio = '08:00',
    @hora_fin = '16:00';

-- Intentar agregar turno con ID existente
EXEC spAgregarTurnoEmpleado 
    @turno_id = 'TUR001', -- ID existente
    @empleado_id = 'EMP001',
    @fecha = '2023-01-21',
    @hora_inicio = '08:00',
    @hora_fin = '16:00';

-- Intentar agregar turno con empleado inexistente
EXEC spAgregarTurnoEmpleado 
    @turno_id = 'TUR102',
    @empleado_id = 'EMP999', -- No existe
    @fecha = '2023-01-21',
    @hora_inicio = '08:00',
    @hora_fin = '16:00';

-- Intentar agregar turno con solapamiento de horario
EXEC spAgregarTurnoEmpleado 
    @turno_id = 'TUR103',
    @empleado_id = 'EMP001',
    @fecha = '2023-01-01', -- Fecha existente
    @hora_inicio = '10:00',
    @hora_fin = '14:00';

-- Eliminar turno existente
EXEC spEliminarTurnoEmpleado 'TUR100';

-- Intentar eliminar turno que no existe
EXEC spEliminarTurnoEmpleado 'TUR999';

-- Actualizar todos los datos de un turno
EXEC spActualizarTurnoEmpleado 
    @turno_id = 'TUR001',
    @empleado_id = 'EMP002',
    @fecha = '2023-01-01',
    @hora_inicio = '07:00',
    @hora_fin = '15:00';

-- Actualización parcial (solo hora)
EXEC spActualizarTurnoEmpleado 
    @turno_id = 'TUR002',
    @hora_inicio = '08:30';

-- Intentar actualizar turno que no existe
EXEC spActualizarTurnoEmpleado 
    @turno_id = 'TUR999',
    @hora_inicio = '08:00';

-- Buscar por ID de turno
EXEC spBuscarTurnosEmpleados 'TUR001', 'id_turno';

-- Buscar por ID de empleado
EXEC spBuscarTurnosEmpleados 'EMP001', 'id_empleado';

-- Buscar por nombre de empleado
EXEC spBuscarTurnosEmpleados 'Mariana', 'nombre_empleado';

-- Buscar por fecha
EXEC spBuscarTurnosEmpleados '2023-01-01', 'fecha';

-- Obtener turnos por empleado y rango de fechas
EXEC spObtenerTurnosPorEmpleadoFecha 
    @empleado_id = 'EMP001',
    @fecha_inicio = '2023-01-01',
    @fecha_fin = '2023-01-07';

-- Obtener todos los turnos de una fecha específica
EXEC spObtenerTurnosPorEmpleadoFecha 
    @fecha_inicio = '2023-01-01',
    @fecha_fin = '2023-01-01';

-- =============================================
-- Procedimientos para la tabla Metodo Pago
-- =============================================
-- Listar Metodos_Pago
IF OBJECT_ID('spListarMetodosPago') IS NOT NULL DROP PROC spListarMetodosPago
GO
CREATE PROC spListarMetodosPago
AS
BEGIN
    SELECT metodo_pago_id, nombre, descripcion
    FROM Metodo_Pago
END
GO

-- Agregar Metodo_Pago
IF OBJECT_ID('spAgregarMetodoPago') IS NOT NULL DROP PROC spAgregarMetodoPago
GO
CREATE PROC spAgregarMetodoPago
    @metodo_pago_id VARCHAR(6),
    @nombre VARCHAR(50),
    @descripcion VARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT metodo_pago_id FROM Metodo_Pago WHERE metodo_pago_id = @metodo_pago_id)
    BEGIN
        INSERT INTO Metodo_Pago(metodo_pago_id, nombre, descripcion)
        VALUES (@metodo_pago_id, @nombre, @descripcion)
        SELECT CodError = 0, Mensaje = 'Método de pago agregado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de método de pago duplicado'
END
GO

-- Eliminar Metodo_Pago
IF OBJECT_ID('spEliminarMetodoPago') IS NOT NULL DROP PROC spEliminarMetodoPago
GO
CREATE PROC spEliminarMetodoPago
    @metodo_pago_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT metodo_pago_id FROM Metodo_Pago WHERE metodo_pago_id = @metodo_pago_id)
    BEGIN
        IF NOT EXISTS (SELECT metodo_pago_id FROM Pedido WHERE metodo_pago_id = @metodo_pago_id)
        BEGIN
            DELETE FROM Metodo_Pago WHERE metodo_pago_id = @metodo_pago_id
            SELECT CodError = 0, Mensaje = 'Método de pago eliminado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Método de pago tiene pedidos asociados'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Método de pago no existe'
END
GO

-- Actualizar Metodo_Pago
IF OBJECT_ID('spActualizarMetodoPago') IS NOT NULL DROP PROC spActualizarMetodoPago
GO
CREATE PROC spActualizarMetodoPago
    @metodo_pago_id VARCHAR(6),
    @nombre VARCHAR(50),
    @descripcion VARCHAR(100)
AS
BEGIN
    IF EXISTS (SELECT metodo_pago_id FROM Metodo_Pago WHERE metodo_pago_id = @metodo_pago_id)
    BEGIN
        UPDATE Metodo_Pago SET
            nombre = @nombre,
            descripcion = @descripcion
        WHERE metodo_pago_id = @metodo_pago_id
        
        SELECT CodError = 0, Mensaje = 'Método de pago actualizado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Método de pago no existe'
END
GO

-- Buscar Metodo_Pago
IF OBJECT_ID('spBuscarMetodoPago') IS NOT NULL DROP PROC spBuscarMetodoPago
GO
CREATE PROC spBuscarMetodoPago
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT metodo_pago_id, nombre, descripcion
        FROM Metodo_Pago
        WHERE metodo_pago_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'nombre'
        SELECT metodo_pago_id, nombre, descripcion
        FROM Metodo_Pago
        WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'descripcion'
        SELECT metodo_pago_id, nombre, descripcion
        FROM Metodo_Pago
        WHERE descripcion LIKE '%' + @Texto + '%'
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
EXEC spListarMetodosPago;

-- Agregar un método válido
EXEC spAgregarMetodoPago 'MP0101', 'Pago con puntos de fidelidad', 'Pago con puntos acumulados en programa de fidelidad';
-- Intentar agregar un método con ID duplicado (debería fallar)
EXEC spAgregarMetodoPago 'MP0001', 'Efectivo Duplicado', 'Pago en moneda local duplicado';

-- Intentar eliminar un método sin pedidos asociados (primero agregamos uno nuevo)
EXEC spAgregarMetodoPago 'MP9999', 'Método Temporal', 'Método para prueba de eliminación';
EXEC spEliminarMetodoPago 'MP9999';

-- Intentar eliminar un método con pedidos asociados (debería fallar)
EXEC spEliminarMetodoPago 'MP0001';

-- Intentar eliminar un método que no existe (debería fallar)
EXEC spEliminarMetodoPago 'MP9999';

-- Actualizar un método existente
EXEC spActualizarMetodoPago 'MP0001', 'Efectivo Actualizado', 'Pago en moneda local con descripción actualizada';

-- Intentar actualizar un método que no existe (debería fallar)
EXEC spActualizarMetodoPago 'MP9999', 'No existe', 'Este método no existe';

-- Buscar por ID
EXEC spBuscarMetodoPago 'MP00', 'id';

-- Buscar por nombre
EXEC spBuscarMetodoPago 'Tarjeta', 'nombre';

-- Buscar por descripción
EXEC spBuscarMetodoPago 'internacional', 'descripcion';

-- Buscar con criterio inválido
EXEC spBuscarMetodoPago 'efectivo', 'otrocriterio';

-------------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Pedido
-- =============================================
-- Listar Pedidos
IF OBJECT_ID('spListarPedidos') IS NOT NULL DROP PROC spListarPedidos
GO
CREATE PROC spListarPedidos
AS
BEGIN
    SELECT pedido_id, cliente_id, empleado_id, fecha_pedido, 
           metodo_pago_id, total, estado, observaciones
    FROM Pedido
END
GO

-- Agregar Pedido
IF OBJECT_ID('spAgregarPedido') IS NOT NULL DROP PROC spAgregarPedido
GO
CREATE PROC spAgregarPedido
    @pedido_id VARCHAR(6),
    @cliente_id VARCHAR(8),
    @empleado_id VARCHAR(6),
    @fecha_pedido DATETIME,
    @metodo_pago_id VARCHAR(6),
    @total DECIMAL(10,2),
    @estado VARCHAR(20),
    @observaciones VARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT pedido_id FROM Pedido WHERE pedido_id = @pedido_id)
    BEGIN
        IF EXISTS (SELECT DNI FROM Cliente WHERE DNI = @cliente_id)
        BEGIN
            IF EXISTS (SELECT empleado_id FROM Empleado WHERE empleado_id = @empleado_id)
            BEGIN
                IF EXISTS (SELECT metodo_pago_id FROM Metodo_Pago WHERE metodo_pago_id = @metodo_pago_id)
                BEGIN
                    INSERT INTO Pedido(pedido_id, cliente_id, empleado_id, fecha_pedido, 
                                      metodo_pago_id, total, estado, observaciones)
                    VALUES (@pedido_id, @cliente_id, @empleado_id, @fecha_pedido, 
                            @metodo_pago_id, @total, @estado, @observaciones)
                    SELECT CodError = 0, Mensaje = 'Pedido agregado correctamente'
                END
                ELSE
                    SELECT CodError = 1, Mensaje = 'Error: Método de pago no existe'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Empleado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Cliente no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de pedido duplicado'
END
GO

-- Eliminar Pedido
IF OBJECT_ID('spEliminarPedido') IS NOT NULL DROP PROC spEliminarPedido
GO
CREATE PROC spEliminarPedido
    @pedido_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT pedido_id FROM Pedido WHERE pedido_id = @pedido_id)
    BEGIN
        IF NOT EXISTS (SELECT pedido_id FROM Detalle_Pedido WHERE pedido_id = @pedido_id)
        BEGIN
            DELETE FROM Pedido WHERE pedido_id = @pedido_id
            SELECT CodError = 0, Mensaje = 'Pedido eliminado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Pedido tiene detalles asociados'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Pedido no existe'
END
GO

-- Actualizar Pedido
IF OBJECT_ID('spActualizarPedido') IS NOT NULL DROP PROC spActualizarPedido
GO
CREATE PROC spActualizarPedido
    @pedido_id VARCHAR(6),
    @cliente_id VARCHAR(8),
    @empleado_id VARCHAR(6),
    @fecha_pedido DATETIME,
    @metodo_pago_id VARCHAR(6),
    @total DECIMAL(10,2),
    @estado VARCHAR(20),
    @observaciones VARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT pedido_id FROM Pedido WHERE pedido_id = @pedido_id)
    BEGIN
        IF EXISTS (SELECT DNI FROM Cliente WHERE DNI = @cliente_id)
        BEGIN
            IF EXISTS (SELECT empleado_id FROM Empleado WHERE empleado_id = @empleado_id)
            BEGIN
                IF EXISTS (SELECT metodo_pago_id FROM Metodo_Pago WHERE metodo_pago_id = @metodo_pago_id)
                BEGIN
                    UPDATE Pedido SET
                        cliente_id = @cliente_id,
                        empleado_id = @empleado_id,
                        fecha_pedido = @fecha_pedido,
                        metodo_pago_id = @metodo_pago_id,
                        total = @total,
                        estado = @estado,
                        observaciones = @observaciones
                    WHERE pedido_id = @pedido_id
                    
                    SELECT CodError = 0, Mensaje = 'Pedido actualizado correctamente'
                END
                ELSE
                    SELECT CodError = 1, Mensaje = 'Error: Método de pago no existe'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Empleado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Cliente no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Pedido no existe'
END
GO

-- Buscar Pedido
IF OBJECT_ID('spBuscarPedido') IS NOT NULL DROP PROC spBuscarPedido
GO
CREATE PROC spBuscarPedido
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT * FROM Pedido WHERE pedido_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'cliente'
        SELECT * FROM Pedido WHERE cliente_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'empleado'
        SELECT * FROM Pedido WHERE empleado_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'fecha'
        SELECT * FROM Pedido WHERE CONVERT(VARCHAR, fecha_pedido, 120) LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'estado'
        SELECT * FROM Pedido WHERE estado LIKE '%' + @Texto + '%'
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
EXEC spListarPedidos

EXEC spAgregarPedido 
    @pedido_id = 'PED101',
    @cliente_id = '12345678',  -- Cliente existente
    @empleado_id = 'EMP001',   -- Empleado existente
    @fecha_pedido = '2023-03-01 12:00:00',
    @metodo_pago_id = 'MP0001', -- Método existente
    @total = 25.50,
    @estado = 'Completado',
    @observaciones = 'Pedido de prueba'

EXEC spAgregarPedido 
    @pedido_id = 'PED001',  -- ID ya existe
    @cliente_id = '12345678',
    @empleado_id = 'EMP001',
    @fecha_pedido = '2023-03-01 12:00:00',
    @metodo_pago_id = 'MP0001',
    @total = 25.50,
    @estado = 'Completado',
    @observaciones = 'Pedido de prueba'

EXEC spEliminarPedido 'PED105'

EXEC spActualizarPedido
    @pedido_id = 'PED001',
    @cliente_id = '23456789',  -- Cambiando cliente
    @empleado_id = 'EMP002',   -- Cambiando empleado
    @fecha_pedido = '2023-01-01 10:15:00',
    @metodo_pago_id = 'MP0002', -- Cambiando método de pago
    @total = 13.50,            -- Cambiando total
    @estado = 'Cancelado',     -- Cambiando estado
    @observaciones = 'Actualizado' -- Cambiando observaciones

EXEC spBuscarPedido 'PED001', 'id'
EXEC spBuscarPedido '12345678', 'cliente'
EXEC spBuscarPedido 'EMP001', 'empleado'
EXEC spBuscarPedido 'Completado', 'estado'
---------------------------------------------------------------------------------------------
-- =============================================
-- Procedimientos para la tabla Detalle Pedido
-- =============================================
-- Listar Detalles_Pedido
IF OBJECT_ID('spListarDetallesPedido') IS NOT NULL DROP PROC spListarDetallesPedido
GO
CREATE PROC spListarDetallesPedido
AS
BEGIN
    SELECT detalle_id, pedido_id, helado_id, cantidad, precio_unitario,
           topping_id, complemento_id, subtotal
    FROM Detalle_Pedido
END
GO

-- Agregar Detalle_Pedido
IF OBJECT_ID('spAgregarDetallePedido') IS NOT NULL DROP PROC spAgregarDetallePedido
GO
CREATE PROC spAgregarDetallePedido
    @detalle_id VARCHAR(6),
    @pedido_id VARCHAR(6),
    @helado_id VARCHAR(6),
    @cantidad INT,
    @precio_unitario DECIMAL(10,2),
    @topping_id VARCHAR(6),
    @complemento_id VARCHAR(6),
    @subtotal DECIMAL(10,2)
AS
BEGIN
    IF NOT EXISTS (SELECT detalle_id FROM Detalle_Pedido WHERE detalle_id = @detalle_id)
    BEGIN
        IF EXISTS (SELECT pedido_id FROM Pedido WHERE pedido_id = @pedido_id)
        BEGIN
            IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
            BEGIN
                INSERT INTO Detalle_Pedido(detalle_id, pedido_id, helado_id, cantidad,
                                          precio_unitario, topping_id, complemento_id, subtotal)
                VALUES (@detalle_id, @pedido_id, @helado_id, @cantidad,
                        @precio_unitario, @topping_id, @complemento_id, @subtotal)
                SELECT CodError = 0, Mensaje = 'Detalle de pedido agregado correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Pedido no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de detalle duplicado'
END
GO

-- Eliminar Detalle_Pedido
IF OBJECT_ID('spEliminarDetallePedido') IS NOT NULL DROP PROC spEliminarDetallePedido
GO
CREATE PROC spEliminarDetallePedido
    @detalle_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT detalle_id FROM Detalle_Pedido WHERE detalle_id = @detalle_id)
    BEGIN
        DELETE FROM Detalle_Pedido WHERE detalle_id = @detalle_id
        SELECT CodError = 0, Mensaje = 'Detalle de pedido eliminado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Detalle no existe'
END
GO

-- Actualizar Detalle_Pedido
IF OBJECT_ID('spActualizarDetallePedido') IS NOT NULL DROP PROC spActualizarDetallePedido
GO
CREATE PROC spActualizarDetallePedido
    @detalle_id VARCHAR(6),
    @pedido_id VARCHAR(6),
    @helado_id VARCHAR(6),
    @cantidad INT,
    @precio_unitario DECIMAL(10,2),
    @topping_id VARCHAR(6),
    @complemento_id VARCHAR(6),
    @subtotal DECIMAL(10,2)
AS
BEGIN
    IF EXISTS (SELECT detalle_id FROM Detalle_Pedido WHERE detalle_id = @detalle_id)
    BEGIN
        IF EXISTS (SELECT pedido_id FROM Pedido WHERE pedido_id = @pedido_id)
        BEGIN
            IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
            BEGIN
                UPDATE Detalle_Pedido SET
                    pedido_id = @pedido_id,
                    helado_id = @helado_id,
                    cantidad = @cantidad,
                    precio_unitario = @precio_unitario,
                    topping_id = @topping_id,
                    complemento_id = @complemento_id,
                    subtotal = @subtotal
                WHERE detalle_id = @detalle_id
                
                SELECT CodError = 0, Mensaje = 'Detalle de pedido actualizado correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Pedido no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Detalle no existe'
END
GO

-- Buscar Detalle_Pedido
IF OBJECT_ID('spBuscarDetallePedido') IS NOT NULL DROP PROC spBuscarDetallePedido
GO
CREATE PROC spBuscarDetallePedido
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'detalle'
        SELECT * FROM Detalle_Pedido WHERE detalle_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'pedido'
        SELECT * FROM Detalle_Pedido WHERE pedido_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'helado'
        SELECT * FROM Detalle_Pedido WHERE helado_id LIKE '%' + @Texto + '%'
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
-- 1. Validar spListarDetallesPedido
EXEC spListarDetallesPedido;
-- Verificar que devuelve los 100 registros iniciales

-- 2. Validar spAgregarDetallePedido
-- Intento exitoso (nuevo ID)
EXEC spAgregarDetallePedido 
    @detalle_id = 'DET101',
    @pedido_id = 'PED001',
    @helado_id = 'HEL001',
    @cantidad = 3,
    @precio_unitario = 5.50,
    @topping_id = 'TOP001',
    @complemento_id = 'COMP01',
    @subtotal = 16.50;

-- Verificar inserción
SELECT * FROM Detalle_Pedido WHERE detalle_id = 'DET101';

-- Intento fallido (ID duplicado)
EXEC spAgregarDetallePedido 
    @detalle_id = 'DET001',
    @pedido_id = 'PED001',
    @helado_id = 'HEL001',
    @cantidad = 1,
    @precio_unitario = 5.50,
    @topping_id = 'TOP001',
    @complemento_id = 'COMP01',
    @subtotal = 5.50;

-- 3. Validar spEliminarDetallePedido
-- Eliminación exitosa
EXEC spEliminarDetallePedido @detalle_id = 'DET101';
-- Verificar eliminación
SELECT * FROM Detalle_Pedido WHERE detalle_id = 'DET101';

-- Eliminación fallida (ID no existe)
EXEC spEliminarDetallePedido @detalle_id = 'DET999';

-- 4. Validar spActualizarDetallePedido
-- Actualización exitosa
EXEC spActualizarDetallePedido 
    @detalle_id = 'DET001',
    @pedido_id = 'PED001',
    @helado_id = 'HEL002',  -- Cambiamos helado
    @cantidad = 5,          -- Cambiamos cantidad
    @precio_unitario = 6.75,
    @topping_id = 'TOP002',
    @complemento_id = 'COMP02',
    @subtotal = 33.75;      -- 5 * 6.75

-- Verificar cambios
SELECT * FROM Detalle_Pedido WHERE detalle_id = 'DET001';

-- Actualización fallida (pedido no existe)
EXEC spActualizarDetallePedido 
    @detalle_id = 'DET001',
    @pedido_id = 'PED999',
    @helado_id = 'HEL001',
    @cantidad = 2,
    @precio_unitario = 5.50,
    @topping_id = 'TOP001',
    @complemento_id = 'COMP01',
    @subtotal = 11.00;

-- 5. Validar spBuscarDetallePedido
-- Búsqueda por pedido
EXEC spBuscarDetallePedido @Texto = 'PED001', @Criterio = 'pedido';
-- Debe devolver varios registros

-- Búsqueda por helado
EXEC spBuscarDetallePedido @Texto = 'HEL050', @Criterio = 'helado';
-- Debe devolver registros con ese helado

-- Búsqueda por detalle
EXEC spBuscarDetallePedido @Texto = 'DET005', @Criterio = 'detalle';
-- Debe devolver 1 registro

-- Restaurar datos originales (opcional)
UPDATE Detalle_Pedido SET 
    helado_id = 'HEL001',
    cantidad = 2,
    subtotal = 11.00
WHERE detalle_id = 'DET001';
---------------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Proveedor
-- =============================================
-- Listar Proveedores
IF OBJECT_ID('spListarProveedores') IS NOT NULL DROP PROC spListarProveedores
GO
CREATE PROC spListarProveedores
AS
BEGIN
    SELECT proveedor_id, nombre, contacto, telefono, email, direccion
    FROM Proveedor
END
GO

-- Agregar Proveedor
IF OBJECT_ID('spAgregarProveedor') IS NOT NULL DROP PROC spAgregarProveedor
GO
CREATE PROC spAgregarProveedor
    @proveedor_id VARCHAR(6),
    @nombre VARCHAR(100),
    @contacto VARCHAR(100),
    @telefono VARCHAR(20),
    @email VARCHAR(100),
    @direccion VARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT proveedor_id FROM Proveedor WHERE proveedor_id = @proveedor_id)
    BEGIN
        INSERT INTO Proveedor(proveedor_id, nombre, contacto, telefono, email, direccion)
        VALUES (@proveedor_id, @nombre, @contacto, @telefono, @email, @direccion)
        SELECT CodError = 0, Mensaje = 'Proveedor agregado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de proveedor duplicado'
END
GO

-- Eliminar Proveedor
IF OBJECT_ID('spEliminarProveedor') IS NOT NULL DROP PROC spEliminarProveedor
GO
CREATE PROC spEliminarProveedor
    @proveedor_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT proveedor_id FROM Proveedor WHERE proveedor_id = @proveedor_id)
    BEGIN
        IF NOT EXISTS (SELECT proveedor_id FROM Ingrediente WHERE proveedor_id = @proveedor_id)
        BEGIN
            DELETE FROM Proveedor WHERE proveedor_id = @proveedor_id
            SELECT CodError = 0, Mensaje = 'Proveedor eliminado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Proveedor tiene ingredientes asociados'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Proveedor no existe'
END
GO

-- Actualizar Proveedor
IF OBJECT_ID('spActualizarProveedor') IS NOT NULL DROP PROC spActualizarProveedor
GO
CREATE PROC spActualizarProveedor
    @proveedor_id VARCHAR(6),
    @nombre VARCHAR(100),
    @contacto VARCHAR(100),
    @telefono VARCHAR(20),
    @email VARCHAR(100),
    @direccion VARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT proveedor_id FROM Proveedor WHERE proveedor_id = @proveedor_id)
    BEGIN
        UPDATE Proveedor SET
            nombre = @nombre,
            contacto = @contacto,
            telefono = @telefono,
            email = @email,
            direccion = @direccion
        WHERE proveedor_id = @proveedor_id
        
        SELECT CodError = 0, Mensaje = 'Proveedor actualizado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Proveedor no existe'
END
GO

-- Buscar Proveedor
IF OBJECT_ID('spBuscarProveedor') IS NOT NULL DROP PROC spBuscarProveedor
GO
CREATE PROC spBuscarProveedor
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT * FROM Proveedor WHERE proveedor_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'nombre'
        SELECT * FROM Proveedor WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'contacto'
        SELECT * FROM Proveedor WHERE contacto LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'email'
        SELECT * FROM Proveedor WHERE email LIKE '%' + @Texto + '%'
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
-- Ejecutar procedimiento para listar todos los proveedores
EXEC spListarProveedores;
-- Agregar un nuevo proveedor (éxito)
EXEC spAgregarProveedor 
    @proveedor_id = 'PROV101',
    @nombre = 'Nuevo Proveedor SL',
    @contacto = 'Ana López',
    @telefono = '911223344',
    @email = 'info@nuevoproveedor.com',
    @direccion = 'Calle Nueva 123, Madrid';

-- Intentar agregar un proveedor con ID existente (error)
EXEC spAgregarProveedor 
    @proveedor_id = 'PROV01',
    @nombre = 'Suministros Industriales S.A.',
    @contacto = 'Juan Pérez',
    @telefono = '912345678',
    @email = 'juan.perez@suministrosind.com',
    @direccion = 'Calle Industria 123, Madrid';
-- Eliminar un proveedor sin ingredientes asociados (éxito)
-- Primero verificamos que PROV100 existe y no tiene ingredientes asociados
SELECT * FROM Proveedor WHERE proveedor_id = 'PROV100';
SELECT * FROM Ingrediente WHERE proveedor_id = 'PROV100';

-- Ejecutamos la eliminación
EXEC spEliminarProveedor @proveedor_id = 'PROV100';

-- Intentar eliminar un proveedor con ingredientes asociados (error)
EXEC spEliminarProveedor @proveedor_id = 'PROV01';

-- Intentar eliminar un proveedor que no existe (error)
EXEC spEliminarProveedor @proveedor_id = 'PROV999';
-- Actualizar un proveedor existente (éxito)
EXEC spActualizarProveedor 
    @proveedor_id = 'PROV01',
    @nombre = 'Suministros Industriales Actualizado S.A.',
    @contacto = 'Juan Pérez Martínez',
    @telefono = '912345679',
    @email = 'juan.perez@suministrosind-updated.com',
    @direccion = 'Calle Industria 124, Madrid';

-- Verificar el cambio
SELECT * FROM Proveedor WHERE proveedor_id = 'PROV01';

-- Intentar actualizar un proveedor que no existe (error)
EXEC spActualizarProveedor 
    @proveedor_id = 'PROV999',
    @nombre = 'Proveedor Inexistente',
    @contacto = 'No Existe',
    @telefono = '000000000',
    @email = 'no@existe.com',
    @direccion = 'Dirección Inexistente';
-- Buscar por ID
EXEC spBuscarProveedor @Texto = 'PROV01', @Criterio = 'id';

-- Buscar por nombre
EXEC spBuscarProveedor @Texto = 'Suministros', @Criterio = 'nombre';

-- Buscar por contacto
EXEC spBuscarProveedor @Texto = 'Juan', @Criterio = 'contacto';

-- Buscar por email
EXEC spBuscarProveedor @Texto = 'suministrosind.com', @Criterio = 'email';

-- Buscar con criterio no válido (no devolverá resultados)
EXEC spBuscarProveedor @Texto = 'Madrid', @Criterio = 'direccion';
---------------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Ingredientes
-- =============================================
-- Listar Ingredientes
IF OBJECT_ID('spListarIngredientes') IS NOT NULL DROP PROC spListarIngredientes
GO
CREATE PROC spListarIngredientes
AS
BEGIN
    SELECT ingrediente_id, nombre, proveedor_id, helado_id, 
           unidad_medida, precio_por_unidad, descripcion
    FROM Ingrediente
END
GO

-- Agregar Ingrediente
IF OBJECT_ID('spAgregarIngrediente') IS NOT NULL DROP PROC spAgregarIngrediente
GO
CREATE PROC spAgregarIngrediente
    @ingrediente_id VARCHAR(6),
    @nombre VARCHAR(100),
    @proveedor_id VARCHAR(6),
    @helado_id VARCHAR(6),
    @unidad_medida VARCHAR(20),
    @precio_por_unidad DECIMAL(10,2),
    @descripcion VARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT ingrediente_id FROM Ingrediente WHERE ingrediente_id = @ingrediente_id)
    BEGIN
        IF EXISTS (SELECT proveedor_id FROM Proveedor WHERE proveedor_id = @proveedor_id)
        BEGIN
            IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
            BEGIN
                INSERT INTO Ingrediente(ingrediente_id, nombre, proveedor_id, helado_id,
                                      unidad_medida, precio_por_unidad, descripcion)
                VALUES (@ingrediente_id, @nombre, @proveedor_id, @helado_id,
                        @unidad_medida, @precio_por_unidad, @descripcion)
                SELECT CodError = 0, Mensaje = 'Ingrediente agregado correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Proveedor no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de ingrediente duplicado'
END
GO

-- Eliminar Ingrediente
IF OBJECT_ID('spEliminarIngrediente') IS NOT NULL DROP PROC spEliminarIngrediente
GO
CREATE PROC spEliminarIngrediente
    @ingrediente_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT ingrediente_id FROM Ingrediente WHERE ingrediente_id = @ingrediente_id)
    BEGIN
        IF NOT EXISTS (SELECT ingrediente_id FROM Inventario WHERE ingrediente_id = @ingrediente_id)
        BEGIN
            DELETE FROM Ingrediente WHERE ingrediente_id = @ingrediente_id
            SELECT CodError = 0, Mensaje = 'Ingrediente eliminado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Ingrediente tiene inventario asociado'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Ingrediente no existe'
END
GO

-- Actualizar Ingrediente
IF OBJECT_ID('spActualizarIngrediente') IS NOT NULL DROP PROC spActualizarIngrediente
GO
CREATE PROC spActualizarIngrediente
    @ingrediente_id VARCHAR(6),
    @nombre VARCHAR(100),
    @proveedor_id VARCHAR(6),
    @helado_id VARCHAR(6),
    @unidad_medida VARCHAR(20),
    @precio_por_unidad DECIMAL(10,2),
    @descripcion VARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT ingrediente_id FROM Ingrediente WHERE ingrediente_id = @ingrediente_id)
    BEGIN
        IF EXISTS (SELECT proveedor_id FROM Proveedor WHERE proveedor_id = @proveedor_id)
        BEGIN
            IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
            BEGIN
                UPDATE Ingrediente SET
                    nombre = @nombre,
                    proveedor_id = @proveedor_id,
                    helado_id = @helado_id,
                    unidad_medida = @unidad_medida,
                    precio_por_unidad = @precio_por_unidad,
                    descripcion = @descripcion
                WHERE ingrediente_id = @ingrediente_id
                
                SELECT CodError = 0, Mensaje = 'Ingrediente actualizado correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Proveedor no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Ingrediente no existe'
END
GO

-- Buscar Ingrediente
IF OBJECT_ID('spBuscarIngrediente') IS NOT NULL DROP PROC spBuscarIngrediente
GO
CREATE PROC spBuscarIngrediente
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT * FROM Ingrediente WHERE ingrediente_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'nombre'
        SELECT * FROM Ingrediente WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'proveedor'
        SELECT * FROM Ingrediente WHERE proveedor_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'helado'
        SELECT * FROM Ingrediente WHERE helado_id LIKE '%' + @Texto + '%'
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
-- Ejecutar procedimiento para listar todos los ingredientes
EXEC spListarIngredientes;
-- Prueba 1: Agregar un ingrediente nuevo válido
EXEC spAgregarIngrediente 
    @ingrediente_id = 'ING101',
    @nombre = 'Nuevo Ingrediente',
    @proveedor_id = 'PROV01',  -- Proveedor existente según los datos
    @helado_id = 'HEL001',     -- Helado existente según los datos
    @unidad_medida = 'kg',
    @precio_por_unidad = 5.99,
    @descripcion = 'Ingrediente de prueba agregado';

-- Prueba 2: Intentar agregar un ingrediente con ID duplicado
EXEC spAgregarIngrediente 
    @ingrediente_id = 'ING001',  -- ID existente
    @nombre = 'Leche entera duplicada',
    @proveedor_id = 'PROV01',
    @helado_id = 'HEL001',
    @unidad_medida = 'litro',
    @precio_por_unidad = 2.50,
    @descripcion = 'Intento de duplicado';

-- Prueba 3: Intentar agregar con proveedor inexistente
EXEC spAgregarIngrediente 
    @ingrediente_id = 'ING102',
    @nombre = 'Ingrediente con proveedor inválido',
    @proveedor_id = 'PROV999',  -- Proveedor no existe
    @helado_id = 'HEL001',
    @unidad_medida = 'kg',
    @precio_por_unidad = 3.99,
    @descripcion = 'Prueba de error';

-- Prueba 4: Intentar agregar con helado inexistente
EXEC spAgregarIngrediente 
    @ingrediente_id = 'ING103',
    @nombre = 'Ingrediente con helado inválido',
    @proveedor_id = 'PROV01',
    @helado_id = 'HEL999',      -- Helado no existe
    @unidad_medida = 'kg',
    @precio_por_unidad = 4.99,
    @descripcion = 'Prueba de error';
-- Primero verificamos que ING100 existe y no tiene inventario asociado
SELECT * FROM Ingrediente WHERE ingrediente_id = 'ING100';
SELECT * FROM Inventario WHERE ingrediente_id = 'ING100';

-- Prueba 1: Eliminar un ingrediente sin inventario asociado (debería funcionar)
EXEC spEliminarIngrediente @ingrediente_id = 'ING100';

-- Verificar que se eliminó
SELECT * FROM Ingrediente WHERE ingrediente_id = 'ING100';

-- Prueba 2: Intentar eliminar un ingrediente con inventario asociado
EXEC spEliminarIngrediente @ingrediente_id = 'ING001';  -- Tiene inventario según datos

-- Prueba 3: Intentar eliminar un ingrediente que no existe
EXEC spEliminarIngrediente @ingrediente_id = 'ING999';
-- Prueba 1: Actualizar un ingrediente existente con datos válidos
EXEC spActualizarIngrediente 
    @ingrediente_id = 'ING001',
    @nombre = 'Leche entera actualizada',
    @proveedor_id = 'PROV01',
    @helado_id = 'HEL001',
    @unidad_medida = 'litro',
    @precio_por_unidad = 2.75,  -- Precio actualizado
    @descripcion = 'Leche fresca pasteurizada - actualizado';

-- Verificar la actualización
SELECT * FROM Ingrediente WHERE ingrediente_id = 'ING001';

-- Prueba 2: Intentar actualizar con proveedor inexistente
EXEC spActualizarIngrediente 
    @ingrediente_id = 'ING001',
    @nombre = 'Leche entera',
    @proveedor_id = 'PROV999',  -- Proveedor no existe
    @helado_id = 'HEL001',
    @unidad_medida = 'litro',
    @precio_por_unidad = 2.50,
    @descripcion = 'Leche fresca pasteurizada';

-- Prueba 3: Intentar actualizar con helado inexistente
EXEC spActualizarIngrediente 
    @ingrediente_id = 'ING001',
    @nombre = 'Leche entera',
    @proveedor_id = 'PROV01',
    @helado_id = 'HEL999',      -- Helado no existe
    @unidad_medida = 'litro',
    @precio_por_unidad = 2.50,
    @descripcion = 'Leche fresca pasteurizada';

-- Prueba 4: Intentar actualizar ingrediente que no existe
EXEC spActualizarIngrediente 
    @ingrediente_id = 'ING999',
    @nombre = 'Ingrediente inexistente',
    @proveedor_id = 'PROV01',
    @helado_id = 'HEL001',
    @unidad_medida = 'kg',
    @precio_por_unidad = 1.99,
    @descripcion = 'Prueba de error';
-- Prueba 1: Buscar por ID
EXEC spBuscarIngrediente @Texto = 'ING001', @Criterio = 'id';

-- Prueba 2: Buscar por nombre (búsqueda parcial)
EXEC spBuscarIngrediente @Texto = 'chocolate', @Criterio = 'nombre';

-- Prueba 3: Buscar por proveedor
EXEC spBuscarIngrediente @Texto = 'PROV01', @Criterio = 'proveedor';

-- Prueba 4: Buscar por helado
EXEC spBuscarIngrediente @Texto = 'HEL001', @Criterio = 'helado';

-- Prueba 5: Buscar con criterio inválido (debería no devolver resultados)
EXEC spBuscarIngrediente @Texto = 'vainilla', @Criterio = 'criterio_invalido';
---------------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Inventario
-- =============================================
-- Listar Inventario
IF OBJECT_ID('spListarInventario') IS NOT NULL DROP PROC spListarInventario
GO
CREATE PROC spListarInventario
AS
BEGIN
    SELECT inventario_id, ingrediente_id, cantidad_disponible, fecha_actualizacion
    FROM Inventario
END
GO

-- Agregar Inventario
IF OBJECT_ID('spAgregarInventario') IS NOT NULL DROP PROC spAgregarInventario
GO
CREATE PROC spAgregarInventario
    @inventario_id VARCHAR(6),
    @ingrediente_id VARCHAR(6),
    @cantidad_disponible DECIMAL(10,2)
AS
BEGIN
    IF NOT EXISTS (SELECT inventario_id FROM Inventario WHERE inventario_id = @inventario_id)
    BEGIN
        IF EXISTS (SELECT ingrediente_id FROM Ingrediente WHERE ingrediente_id = @ingrediente_id)
        BEGIN
            INSERT INTO Inventario(inventario_id, ingrediente_id, cantidad_disponible)
            VALUES (@inventario_id, @ingrediente_id, @cantidad_disponible)
            SELECT CodError = 0, Mensaje = 'Registro de inventario agregado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Ingrediente no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de inventario duplicado'
END
GO

-- Eliminar Inventario
IF OBJECT_ID('spEliminarInventario') IS NOT NULL DROP PROC spEliminarInventario
GO
CREATE PROC spEliminarInventario
    @inventario_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT inventario_id FROM Inventario WHERE inventario_id = @inventario_id)
    BEGIN
        DELETE FROM Inventario WHERE inventario_id = @inventario_id
        SELECT CodError = 0, Mensaje = 'Registro de inventario eliminado correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Registro de inventario no existe'
END
GO

-- Actualizar Inventario
IF OBJECT_ID('spActualizarInventario') IS NOT NULL DROP PROC spActualizarInventario
GO
CREATE PROC spActualizarInventario
    @inventario_id VARCHAR(6),
    @ingrediente_id VARCHAR(6),
    @cantidad_disponible DECIMAL(10,2)
AS
BEGIN
    IF EXISTS (SELECT inventario_id FROM Inventario WHERE inventario_id = @inventario_id)
    BEGIN
        IF EXISTS (SELECT ingrediente_id FROM Ingrediente WHERE ingrediente_id = @ingrediente_id)
        BEGIN
            UPDATE Inventario SET
                ingrediente_id = @ingrediente_id,
                cantidad_disponible = @cantidad_disponible
            WHERE inventario_id = @inventario_id
            
            SELECT CodError = 0, Mensaje = 'Inventario actualizado correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Ingrediente no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Registro de inventario no existe'
END
GO

-- Buscar Inventario
IF OBJECT_ID('spBuscarInventario') IS NOT NULL DROP PROC spBuscarInventario
GO
CREATE PROC spBuscarInventario
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'inventario'
        SELECT * FROM Inventario WHERE inventario_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'ingrediente'
        SELECT * FROM Inventario WHERE ingrediente_id LIKE '%' + @Texto + '%'
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
-- Listar todo el inventario
EXEC spListarInventario;
-- Agregar un nuevo registro de inventario
EXEC spAgregarInventario 
    @inventario_id = 'INV101', 
    @ingrediente_id = 'ING001', 
    @cantidad_disponible = 100.00;

-- Verificar que se agregó
EXEC spListarInventario;
-- Eliminar un registro de inventario existente
EXEC spEliminarInventario @inventario_id = 'INV100';

-- Intentar eliminar un registro que no existe
EXEC spEliminarInventario @inventario_id = 'INV999';

-- Verificar que se eliminó
EXEC spListarInventario;
-- Actualizar un registro existente
EXEC spActualizarInventario 
    @inventario_id = 'INV001', 
    @ingrediente_id = 'ING001', 
    @cantidad_disponible = 200.00;

-- Intentar actualizar con ingrediente que no existe
EXEC spActualizarInventario 
    @inventario_id = 'INV001', 
    @ingrediente_id = 'ING999', 
    @cantidad_disponible = 200.00;

-- Verificar la actualización
EXEC spListarInventario;
-- Buscar por ID de inventario
EXEC spBuscarInventario @Texto = 'INV05', @Criterio = 'inventario';

-- Buscar por ID de ingrediente
EXEC spBuscarInventario @Texto = 'ING05', @Criterio = 'ingrediente';

-- Buscar con criterio inválido
EXEC spBuscarInventario @Texto = 'INV05', @Criterio = 'fecha';
---------------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Promocion
-- =============================================
-- Listar Promociones
IF OBJECT_ID('spListarPromociones') IS NOT NULL DROP PROC spListarPromociones
GO
CREATE PROC spListarPromociones
AS
BEGIN
    SELECT promocion_id, nombre, descripcion, descuento, 
           fecha_inicio, fecha_fin, activa
    FROM Promocion
END
GO

-- Agregar Promocion
IF OBJECT_ID('spAgregarPromocion') IS NOT NULL DROP PROC spAgregarPromocion
GO
CREATE PROC spAgregarPromocion
    @promocion_id VARCHAR(6),
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255),
    @descuento DECIMAL(5,2),
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @activa BIT
AS
BEGIN
    IF NOT EXISTS (SELECT promocion_id FROM Promocion WHERE promocion_id = @promocion_id)
    BEGIN
        INSERT INTO Promocion(promocion_id, nombre, descripcion, descuento,
                             fecha_inicio, fecha_fin, activa)
        VALUES (@promocion_id, @nombre, @descripcion, @descuento,
                @fecha_inicio, @fecha_fin, @activa)
        SELECT CodError = 0, Mensaje = 'Promoción agregada correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de promoción duplicado'
END
GO

-- Eliminar Promocion
IF OBJECT_ID('spEliminarPromocion') IS NOT NULL DROP PROC spEliminarPromocion
GO
CREATE PROC spEliminarPromocion
    @promocion_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT promocion_id FROM Promocion WHERE promocion_id = @promocion_id)
    BEGIN
        IF NOT EXISTS (SELECT promocion_id FROM Helado_Promocion WHERE promocion_id = @promocion_id)
        BEGIN
            DELETE FROM Promocion WHERE promocion_id = @promocion_id
            SELECT CodError = 0, Mensaje = 'Promoción eliminada correctamente'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Promoción tiene helados asociados'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Promoción no existe'
END
GO

-- Actualizar Promocion
IF OBJECT_ID('spActualizarPromocion') IS NOT NULL DROP PROC spActualizarPromocion
GO
CREATE PROC spActualizarPromocion
    @promocion_id VARCHAR(6),
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255),
    @descuento DECIMAL(5,2),
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @activa BIT
AS
BEGIN
    IF EXISTS (SELECT promocion_id FROM Promocion WHERE promocion_id = @promocion_id)
    BEGIN
        UPDATE Promocion SET
            nombre = @nombre,
            descripcion = @descripcion,
            descuento = @descuento,
            fecha_inicio = @fecha_inicio,
            fecha_fin = @fecha_fin,
            activa = @activa
        WHERE promocion_id = @promocion_id
        
        SELECT CodError = 0, Mensaje = 'Promoción actualizada correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Promoción no existe'
END
GO

-- Buscar Promocion
IF OBJECT_ID('spBuscarPromocion') IS NOT NULL DROP PROC spBuscarPromocion
GO
CREATE PROC spBuscarPromocion
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT * FROM Promocion WHERE promocion_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'nombre'
        SELECT * FROM Promocion WHERE nombre LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'activa'
        SELECT * FROM Promocion WHERE activa = CASE WHEN @Texto = '1' THEN 1 ELSE 0 END
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
-- Listar todas las promociones
EXEC spListarPromociones;
-- Agregar una nueva promoción
EXEC spAgregarPromocion 
    @promocion_id = 'PM0101', 
    @nombre = 'Nueva Promo Verano', 
    @descripcion = 'Promoción especial de verano 2024', 
    @descuento = 20.00,
    @fecha_inicio = '2024-06-01',
    @fecha_fin = '2024-08-31',
    @activa = 1;

-- Intentar agregar con ID duplicado
EXEC spAgregarPromocion 
    @promocion_id = 'PM0001', 
    @nombre = 'Duplicado', 
    @descripcion = 'Esto debería fallar', 
    @descuento = 10.00,
    @fecha_inicio = '2024-01-01',
    @fecha_fin = '2024-01-31',
    @activa = 1;

-- Verificar que se agregó
EXEC spListarPromociones;
-- Eliminar una promoción sin helados asociados (usando PM0101 que acabamos de agregar)
EXEC spEliminarPromocion @promocion_id = 'PM0101';

-- Intentar eliminar promoción con helados asociados (PM0001 tiene asociación en Helado_Promocion)
EXEC spEliminarPromocion @promocion_id = 'PM0001';

-- Intentar eliminar promoción que no existe
EXEC spEliminarPromocion @promocion_id = 'PM9999';

-- Verificar que se eliminó
EXEC spListarPromociones;
-- Actualizar una promoción existente
EXEC spActualizarPromocion 
    @promocion_id = 'PM0001', 
    @nombre = 'Verano Feliz Actualizado', 
    @descripcion = 'Descuento especial de verano 2024', 
    @descuento = 20.00,
    @fecha_inicio = '2024-06-01',
    @fecha_fin = '2024-08-31',
    @activa = 1;

-- Intentar actualizar promoción que no existe
EXEC spActualizarPromocion 
    @promocion_id = 'PM9999', 
    @nombre = 'No existe', 
    @descripcion = 'Esta promoción no existe', 
    @descuento = 10.00,
    @fecha_inicio = '2024-01-01',
    @fecha_fin = '2024-01-31',
    @activa = 1;

-- Verificar la actualización
EXEC spListarPromociones;
-- Buscar por ID de promoción
EXEC spBuscarPromocion @Texto = 'PM00', @Criterio = 'id';

-- Buscar por nombre de promoción
EXEC spBuscarPromocion @Texto = 'Verano', @Criterio = 'nombre';

-- Buscar promociones activas
EXEC spBuscarPromocion @Texto = '1', @Criterio = 'activa';

-- Buscar promociones inactivas
EXEC spBuscarPromocion @Texto = '0', @Criterio = 'activa';

-- Buscar con criterio inválido
EXEC spBuscarPromocion @Texto = 'PM00', @Criterio = 'fecha';
---------------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Helado Promocion
-- =============================================
-- Listar Helado_Promocion
IF OBJECT_ID('spListarHeladoPromocion') IS NOT NULL DROP PROC spListarHeladoPromocion
GO
CREATE PROC spListarHeladoPromocion
AS
BEGIN
    SELECT helado_promocion_id, helado_id, promocion_id
    FROM Helado_Promocion
END
GO

-- Agregar Helado_Promocion
IF OBJECT_ID('spAgregarHeladoPromocion') IS NOT NULL DROP PROC spAgregarHeladoPromocion
GO
CREATE PROC spAgregarHeladoPromocion
    @helado_promocion_id VARCHAR(5),
    @helado_id VARCHAR(6),
    @promocion_id VARCHAR(6)
AS
BEGIN
    IF NOT EXISTS (SELECT helado_promocion_id FROM Helado_Promocion WHERE helado_promocion_id = @helado_promocion_id)
    BEGIN
        IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
        BEGIN
            IF EXISTS (SELECT promocion_id FROM Promocion WHERE promocion_id = @promocion_id)
            BEGIN
                INSERT INTO Helado_Promocion(helado_promocion_id, helado_id, promocion_id)
                VALUES (@helado_promocion_id, @helado_id, @promocion_id)
                SELECT CodError = 0, Mensaje = 'Relación helado-promoción agregada correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Promoción no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de relación duplicado'
END
GO

-- Eliminar Helado_Promocion
IF OBJECT_ID('spEliminarHeladoPromocion') IS NOT NULL DROP PROC spEliminarHeladoPromocion
GO
CREATE PROC spEliminarHeladoPromocion
    @helado_promocion_id VARCHAR(5)
AS
BEGIN
    IF EXISTS (SELECT helado_promocion_id FROM Helado_Promocion WHERE helado_promocion_id = @helado_promocion_id)
    BEGIN
        DELETE FROM Helado_Promocion WHERE helado_promocion_id = @helado_promocion_id
        SELECT CodError = 0, Mensaje = 'Relación helado-promoción eliminada correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Relación no existe'
END
GO

-- Actualizar Helado_Promocion
IF OBJECT_ID('spActualizarHeladoPromocion') IS NOT NULL DROP PROC spActualizarHeladoPromocion
GO
CREATE PROC spActualizarHeladoPromocion
    @helado_promocion_id VARCHAR(5),
    @helado_id VARCHAR(6),
    @promocion_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT helado_promocion_id FROM Helado_Promocion WHERE helado_promocion_id = @helado_promocion_id)
    BEGIN
        IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
        BEGIN
            IF EXISTS (SELECT promocion_id FROM Promocion WHERE promocion_id = @promocion_id)
            BEGIN
                UPDATE Helado_Promocion SET
                    helado_id = @helado_id,
                    promocion_id = @promocion_id
                WHERE helado_promocion_id = @helado_promocion_id
                
                SELECT CodError = 0, Mensaje = 'Relación helado-promoción actualizada correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Promoción no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Relación no existe'
END
GO

-- Buscar Helado_Promocion
IF OBJECT_ID('spBuscarHeladoPromocion') IS NOT NULL DROP PROC spBuscarHeladoPromocion
GO
CREATE PROC spBuscarHeladoPromocion
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT * FROM Helado_Promocion WHERE helado_promocion_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'helado'
        SELECT * FROM Helado_Promocion WHERE helado_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'promocion'
        SELECT * FROM Helado_Promocion WHERE promocion_id LIKE '%' + @Texto + '%'
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
-- Listar todas las relaciones helado-promoción
EXEC spListarHeladoPromocion
-- Agregar una nueva relación válida
EXEC spAgregarHeladoPromocion 'HP101', 'HEL001', 'PM0001'
-- Agregar una relación con helado que no existe
EXEC spAgregarHeladoPromocion 'HP101', 'HEL999', 'PM0001'
-- Agregar una relación con promoción que no existe
EXEC spAgregarHeladoPromocion 'HP101', 'HEL001', 'PM9999'
-- Agregar una relación válida con nuevos IDs
EXEC spAgregarHeladoPromocion 'HP101', 'HEL001', 'PM0101'
-- Eliminar una relación existente
EXEC spEliminarHeladoPromocion 'HPM01'
-- Intentar eliminar una relación que no existe
EXEC spEliminarHeladoPromocion 'HP999'
-- Actualizar una relación existente con datos válidos
EXEC spActualizarHeladoPromocion 'HPM02', 'HEL002', 'PM0101'
-- Intentar actualizar con helado que no existe
EXEC spActualizarHeladoPromocion 'HPM02', 'HEL999', 'PM0002'
-- Intentar actualizar con promoción que no existe
EXEC spActualizarHeladoPromocion 'HPM02', 'HEL002', 'PM9999'
-- Buscar por ID de relación
EXEC spBuscarHeladoPromocion 'HPM01', 'id'
-- Buscar por ID de helado
EXEC spBuscarHeladoPromocion 'HEL001', 'helado'
-- Buscar por ID de promoción
EXEC spBuscarHeladoPromocion 'PM0001', 'promocion'
-- Buscar con criterio inválido
EXEC spBuscarHeladoPromocion 'HEL001', 'sabor'
---------------------------------------------------------------------------------------------

-- =============================================
-- Procedimientos para la tabla Reseña
-- =============================================
-- Listar Reseñas
IF OBJECT_ID('spListarResenas') IS NOT NULL DROP PROC spListarResenas
GO
CREATE PROC spListarResenas
AS
BEGIN
    SELECT resena_id, cliente_id, helado_id, calificacion, 
           comentario, fecha
    FROM Resena
END
GO

-- Agregar Resena
IF OBJECT_ID('spAgregarResena') IS NOT NULL DROP PROC spAgregarResena
GO
CREATE PROC spAgregarResena
    @resena_id VARCHAR(6),
    @cliente_id VARCHAR(8),
    @helado_id VARCHAR(6),
    @calificacion INT,
    @comentario VARCHAR(500)
AS
BEGIN
    IF NOT EXISTS (SELECT resena_id FROM Resena WHERE resena_id = @resena_id)
    BEGIN
        IF EXISTS (SELECT DNI FROM Cliente WHERE DNI = @cliente_id)
        BEGIN
            IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
            BEGIN
                INSERT INTO Resena(resena_id, cliente_id, helado_id, calificacion, comentario)
                VALUES (@resena_id, @cliente_id, @helado_id, @calificacion, @comentario)
                SELECT CodError = 0, Mensaje = 'Reseña agregada correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Cliente no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: ID de reseña duplicado'
END
GO

-- Eliminar Resena
IF OBJECT_ID('spEliminarResena') IS NOT NULL DROP PROC spEliminarResena
GO
CREATE PROC spEliminarResena
    @resena_id VARCHAR(6)
AS
BEGIN
    IF EXISTS (SELECT resena_id FROM Resena WHERE resena_id = @resena_id)
    BEGIN
        DELETE FROM Resena WHERE resena_id = @resena_id
        SELECT CodError = 0, Mensaje = 'Reseña eliminada correctamente'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Reseña no existe'
END
GO

-- Actualizar Resena
IF OBJECT_ID('spActualizarResena') IS NOT NULL DROP PROC spActualizarResena
GO
CREATE PROC spActualizarResena
    @resena_id VARCHAR(6),
    @cliente_id VARCHAR(8),
    @helado_id VARCHAR(6),
    @calificacion INT,
    @comentario VARCHAR(500)
AS
BEGIN
    IF EXISTS (SELECT resena_id FROM Resena WHERE resena_id = @resena_id)
    BEGIN
        IF EXISTS (SELECT DNI FROM Cliente WHERE DNI = @cliente_id)
        BEGIN
            IF EXISTS (SELECT helado_id FROM Helado WHERE helado_id = @helado_id)
            BEGIN
                UPDATE Resena SET
                    cliente_id = @cliente_id,
                    helado_id = @helado_id,
                    calificacion = @calificacion,
                    comentario = @comentario
                WHERE resena_id = @resena_id
                
                SELECT CodError = 0, Mensaje = 'Reseña actualizada correctamente'
            END
            ELSE
                SELECT CodError = 1, Mensaje = 'Error: Helado no existe'
        END
        ELSE
            SELECT CodError = 1, Mensaje = 'Error: Cliente no existe'
    END
    ELSE
        SELECT CodError = 1, Mensaje = 'Error: Reseña no existe'
END
GO

-- Buscar Resena
IF OBJECT_ID('spBuscarResena') IS NOT NULL DROP PROC spBuscarResena
GO
CREATE PROC spBuscarResena
    @Texto VARCHAR(100),
    @Criterio VARCHAR(20)
AS
BEGIN
    IF @Criterio = 'id'
        SELECT * FROM Resena WHERE resena_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'cliente'
        SELECT * FROM Resena WHERE cliente_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'helado'
        SELECT * FROM Resena WHERE helado_id LIKE '%' + @Texto + '%'
    ELSE IF @Criterio = 'calificacion'
        SELECT * FROM Resena WHERE calificacion = CAST(@Texto AS INT)
END
GO

/*Validacion de los Procedimientos*/
---------------------------------------------------------------------------------------------
-- Listar todas las reseñas
EXEC spListarResenas
-- Agregar una nueva reseña válida
EXEC spAgregarResena 
    @resena_id = 'RES101',
    @cliente_id = '11111111', -- Cliente existente en los datos
    @helado_id = 'HEL001',    -- Helado existente
    @calificacion = 4,
    @comentario = 'Nueva reseña de prueba'
-- Intentar agregar con ID duplicado
EXEC spAgregarResena 
    @resena_id = 'RES001', -- ID existente
    @cliente_id = '11111111',
    @helado_id = 'HEL001',
    @calificacion = 5,
    @comentario = 'Intento de duplicado'
-- Intentar agregar con cliente que no existe
EXEC spAgregarResena 
    @resena_id = 'RES102',
    @cliente_id = '99999999', -- Cliente no existente
    @helado_id = 'HEL001',
    @calificacion = 3,
    @comentario = 'Cliente no existe'
-- Intentar agregar con helado que no existe
EXEC spAgregarResena 
    @resena_id = 'RES103',
    @cliente_id = '11111111',
    @helado_id = 'HEL999', -- Helado no existente
    @calificacion = 2,
    @comentario = 'Helado no existe'
-- Eliminar una reseña existente
EXEC spEliminarResena 'RES001'
-- Intentar eliminar una reseña que no existe
EXEC spEliminarResena 'RES999'
-- Actualizar una reseña existente con datos válidos
EXEC spActualizarResena 
    @resena_id = 'RES002',
    @cliente_id = '22222222', 
    @helado_id = 'HEL002',
    @calificacion = 3, -- Cambiando de 4 a 3
    @comentario = 'Comentario actualizado'
-- Intentar actualizar con cliente que no existe
EXEC spActualizarResena 
    @resena_id = 'RES002',
    @cliente_id = '99999999', -- Cliente no existe
    @helado_id = 'HEL002',
    @calificacion = 4,
    @comentario = 'Intento con cliente inválido'
-- Intentar actualizar con helado que no existe
EXEC spActualizarResena 
    @resena_id = 'RES002',
    @cliente_id = '22222222',
    @helado_id = 'HEL999', -- Helado no existe
    @calificacion = 4,
    @comentario = 'Intento con helado inválido'
-- Intentar actualizar reseña que no existe
EXEC spActualizarResena 
    @resena_id = 'RES999',
    @cliente_id = '22222222',
    @helado_id = 'HEL002',
    @calificacion = 5,
    @comentario = 'Reseña no existe'
-- Buscar por ID de reseña
EXEC spBuscarResena 'RES001', 'id'
-- Buscar por ID de cliente
EXEC spBuscarResena '11111111', 'cliente'
-- Buscar por ID de helado
EXEC spBuscarResena 'HEL001', 'helado'
-- Buscar por calificación
EXEC spBuscarResena '5', 'calificacion'
-- Buscar con criterio inválido
EXEC spBuscarResena 'test', 'fecha'
---------------------------------------------------------------------------------------------