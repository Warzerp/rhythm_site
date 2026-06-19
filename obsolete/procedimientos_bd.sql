-- =========================================
-- SCRIPT 09: FUNCIONES Y PROCEDIMIENTOS ALMACENADOS (CRUD)
-- =========================================

-- =========================================
-- HELPER: fn_crear_ticket
-- =========================================
CREATE OR REPLACE FUNCTION fn_crear_ticket(
    p_precio       DECIMAL(10,2),
    p_tipo_ticket  INT,
    p_cantidad     INT,
    p_evento       INT
) RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO ticket (precio, cantidad, tipo_ticket_id, evento_id)
    VALUES (p_precio, p_cantidad, p_tipo_ticket, p_evento)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$;

-- =========================================
-- HELPER: fn_eliminar_ticket
-- =========================================
CREATE OR REPLACE FUNCTION fn_eliminar_ticket(
    p_ticket INT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ticket WHERE id = p_ticket;
END;
$$;

-- =========================================
-- HELPER: fn_insertar_orden
-- =========================================
CREATE OR REPLACE FUNCTION fn_insertar_orden(
    p_usuario   INT,
    p_ticket    INT,
    p_cantidad  INT,
    p_fecha     DATE,
    p_estado    VARCHAR(50)
) RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_orden_id INT;
BEGIN
    INSERT INTO ordenes (cantidad, fecha_compra, estado_pago, usuario_id, ticket_id)
    VALUES (p_cantidad, p_fecha, p_estado, p_usuario, p_ticket)
    RETURNING id INTO v_orden_id;
    RETURN v_orden_id;
END;
$$;

-- =========================================
-- CRUD: sp_crear_usuario (Transactional User Register)
-- =========================================
CREATE OR REPLACE PROCEDURE sp_crear_usuario(
    p_nombre            VARCHAR(100),
    p_apellido          VARCHAR(100),
    p_nick              VARCHAR(50),
    p_contrasena        VARCHAR(255),
    p_fecha_nacimiento  DATE,
    p_rol_cuenta        INT,
    p_correo            VARCHAR(150),
    p_telefono          VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_correo_id INT;
    v_telefono_id INT;
BEGIN
    -- 1. Validar que el nick no esté duplicado
    IF EXISTS (SELECT 1 FROM usuarios WHERE nick = p_nick) THEN
        RAISE EXCEPTION 'El nick "%" ya está en uso', p_nick;
    END IF;

    -- 2. Insertar correo (clasificación 1 = usuario)
    INSERT INTO correo_usuarios (correo, clasificacion_id)
    VALUES (p_correo, 1)
    RETURNING id INTO v_correo_id;

    -- 3. Insertar teléfono (clasificación 1 = usuario)
    INSERT INTO telefono_usuarios (telefono, clasificacion_id)
    VALUES (p_telefono, 1)
    RETURNING id INTO v_telefono_id;

    -- 4. Insertar usuario
    INSERT INTO usuarios (
        nombre, apellido, nick, contrasena, activo, 
        fecha_nacimiento, rol_cuenta, correo_usuarios_id, telefono_usuario_id
    )
    VALUES (
        p_nombre, p_apellido, p_nick, p_contrasena, TRUE, 
        p_fecha_nacimiento, p_rol_cuenta, v_correo_id, v_telefono_id
    );
END;
$$;

-- =========================================
-- CRUD: sp_actualizar_usuario
-- =========================================
CREATE OR REPLACE PROCEDURE sp_actualizar_usuario(
    p_id                INT,
    p_nombre            VARCHAR(100),
    p_apellido          VARCHAR(100),
    p_nick              VARCHAR(50),
    p_contrasena        VARCHAR(255),
    p_fecha_nacimiento  DATE,
    p_correo            VARCHAR(150),
    p_telefono          VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_correo_id INT;
    v_telefono_id INT;
BEGIN
    -- Verificar si existe el usuario y extraer IDs de contacto
    SELECT correo_usuarios_id, telefono_usuario_id 
    INTO v_correo_id, v_telefono_id 
    FROM usuarios 
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El usuario con ID % no existe', p_id;
    END IF;

    -- Validar nick único si cambia
    IF EXISTS (SELECT 1 FROM usuarios WHERE nick = p_nick AND id <> p_id) THEN
        RAISE EXCEPTION 'El nick "%" ya está en uso por otro usuario', p_nick;
    END IF;

    -- Actualizar correo
    UPDATE correo_usuarios 
    SET correo = p_correo 
    WHERE id = v_correo_id;

    -- Actualizar teléfono
    UPDATE telefono_usuarios 
    SET telefono = p_telefono 
    WHERE id = v_telefono_id;

    -- Actualizar usuario
    UPDATE usuarios
    SET 
        nombre = p_nombre,
        apellido = p_apellido,
        nick = p_nick,
        contrasena = p_contrasena,
        fecha_nacimiento = p_fecha_nacimiento
    WHERE id = p_id;
END;
$$;

-- =========================================
-- CRUD: sp_eliminar_usuario (Soft-delete)
-- =========================================
CREATE OR REPLACE PROCEDURE sp_eliminar_usuario(
    p_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_id) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe', p_id;
    END IF;

    -- Hacemos soft-delete desactivando la cuenta
    UPDATE usuarios 
    SET activo = FALSE 
    WHERE id = p_id;
END;
$$;

-- =========================================
-- CRUD: sp_crear_ticket (Con validaciones de negocio)
-- =========================================
CREATE OR REPLACE PROCEDURE sp_crear_ticket(
    p_precio       DECIMAL(10,2),
    p_tipo_ticket  INT,
    p_cantidad     INT,
    p_evento       INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Validaciones de existencia
    IF NOT EXISTS (SELECT 1 FROM tipo_tickets WHERE id = p_tipo_ticket) THEN
        RAISE EXCEPTION 'El tipo de ticket con id % no existe', p_tipo_ticket;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM eventos WHERE id = p_evento) THEN
        RAISE EXCEPTION 'El evento con id % no existe', p_evento;
    END IF;

    -- 2. Validaciones de negocio
    IF p_precio < 0 THEN
        RAISE EXCEPTION 'El precio no puede ser negativo';
    END IF;

    IF p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor a cero';
    END IF;

    -- 3. Duplicidad
    IF EXISTS (
        SELECT 1 FROM ticket
        WHERE tipo_ticket_id = p_tipo_ticket
        AND evento_id = p_evento
    ) THEN
        RAISE EXCEPTION 'Ya existe un ticket de tipo % para el evento %', p_tipo_ticket, p_evento;
    END IF;

    -- 4. Llamar a la función insert
    PERFORM fn_crear_ticket(p_precio, p_tipo_ticket, p_cantidad, p_evento);
END;
$$;

-- =========================================
-- CRUD: sp_actualizar_ticket
-- =========================================
CREATE OR REPLACE PROCEDURE sp_actualizar_ticket(
    p_id           INT,
    p_precio       DECIMAL(10,2),
    p_cantidad     INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM ticket WHERE id = p_id) THEN
        RAISE EXCEPTION 'El ticket con id % no existe', p_id;
    END IF;

    IF p_precio < 0 THEN
        RAISE EXCEPTION 'El precio no puede ser negativo';
    END IF;

    IF p_cantidad < 0 THEN
        RAISE EXCEPTION 'El stock no puede ser negativo';
    END IF;

    UPDATE ticket
    SET precio = p_precio,
        cantidad = p_cantidad
    WHERE id = p_id;
END;
$$;

-- =========================================
-- CRUD: sp_eliminar_ticket
-- =========================================
CREATE OR REPLACE PROCEDURE sp_eliminar_ticket(
    p_ticket INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM ticket WHERE id = p_ticket) THEN
        RAISE EXCEPTION 'El ticket con id % no existe', p_ticket;
    END IF;

    -- Validar si ya tiene órdenes registradas
    IF EXISTS (SELECT 1 FROM ordenes WHERE ticket_id = p_ticket) THEN
        RAISE EXCEPTION 'No se puede eliminar: el ticket % ya tiene órdenes registradas', p_ticket;
    END IF;
    
    PERFORM fn_eliminar_ticket(p_ticket); 
END;
$$;

-- =========================================
-- TRANSACCIÓN COMPRA: sp_comprar_tickets
-- =========================================
CREATE OR REPLACE PROCEDURE sp_comprar_tickets(
    p_usuario  INT,
    p_ticket   INT,
    p_cantidad INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INT;
    v_orden_id INT;
BEGIN
    -- 1. Validaciones básicas
    IF p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor a cero';
    END IF;

    -- 2. Validar que el usuario exista y esté activo
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario AND activo = TRUE) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe o está inactivo', p_usuario;
    END IF;

    -- 3. Bloquear la fila del ticket (control de concurrencia)
    SELECT cantidad
    INTO v_stock
    FROM ticket
    WHERE id = p_ticket
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El ticket con id % no existe', p_ticket;
    END IF;

    -- 4. Validar stock disponible
    IF p_cantidad > v_stock THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %, solicitado: %', v_stock, p_cantidad;
    END IF;

    -- 5. Insertar la orden. El trigger 'trg_validar_stock_antes_de_orden'
    -- se disparará automáticamente para re-verificar y descontar del stock.
    v_orden_id := fn_insertar_orden(p_usuario, p_ticket, p_cantidad, CURRENT_DATE, 'pagado');
    
    RAISE NOTICE 'Compra completada exitosamente. Orden ID: %, Ticket ID: %, Cantidad: %', v_orden_id, p_ticket, p_cantidad;
END;
$$;

-- =========================================
-- CRUD: sp_crear_evento
-- Creación transaccional de un evento asociando artistas.
-- =========================================
CREATE OR REPLACE PROCEDURE sp_crear_evento(
    p_nombre            VARCHAR(100),
    p_descripcion       TEXT,
    p_fecha_inicio      DATE,
    p_fecha_fin         DATE,
    p_estado            VARCHAR(50),
    p_es_publico        BOOLEAN,
    p_organizador_id    INT,
    p_tipo_evento_id    INT,
    p_venue_id          INT,
    p_artista_ids       INT[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_evento_id INT;
    v_art_id INT;
BEGIN
    -- Validar FKs iniciales
    IF NOT EXISTS (SELECT 1 FROM organizadores WHERE id = p_organizador_id) THEN
        RAISE EXCEPTION 'El organizador con ID % no existe', p_organizador_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tipo_evento WHERE id = p_tipo_evento_id) THEN
        RAISE EXCEPTION 'El tipo de evento con ID % no existe', p_tipo_evento_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM venues WHERE id = p_venue_id) THEN
        RAISE EXCEPTION 'El venue con ID % no existe', p_venue_id;
    END IF;

    -- Insertar evento
    INSERT INTO eventos (
        nombre, descripcion, fecha_inicio, fecha_fin, estado, 
        es_publico, organizador_id, tipo_evento_id, venue_id
    )
    VALUES (
        p_nombre, p_descripcion, p_fecha_inicio, p_fecha_fin, p_estado, 
        p_es_publico, p_organizador_id, p_tipo_evento_id, p_venue_id
    )
    RETURNING id INTO v_evento_id;

    -- Asociar artistas
    IF p_artista_ids IS NOT NULL THEN
        FOREACH v_art_id IN ARRAY p_artista_ids LOOP
            IF NOT EXISTS (SELECT 1 FROM artistas WHERE id = v_art_id) THEN
                RAISE EXCEPTION 'El artista con ID % no existe', v_art_id;
            END IF;
            INSERT INTO evento_artistas (evento_id, artista_id)
            VALUES (v_evento_id, v_art_id);
        END LOOP;
    END IF;
END;
$$;

-- =========================================
-- CRUD: sp_actualizar_evento
-- =========================================
CREATE OR REPLACE PROCEDURE sp_actualizar_evento(
    p_id                INT,
    p_nombre            VARCHAR(100),
    p_descripcion       TEXT,
    p_fecha_inicio      DATE,
    p_fecha_fin         DATE,
    p_estado            VARCHAR(50),
    p_es_publico        BOOLEAN,
    p_organizador_id    INT,
    p_tipo_evento_id    INT,
    p_venue_id          INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM eventos WHERE id = p_id) THEN
        RAISE EXCEPTION 'El evento con ID % no existe', p_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM organizadores WHERE id = p_organizador_id) THEN
        RAISE EXCEPTION 'El organizador con ID % no existe', p_organizador_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tipo_evento WHERE id = p_tipo_evento_id) THEN
        RAISE EXCEPTION 'El tipo de evento con ID % no existe', p_tipo_evento_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM venues WHERE id = p_venue_id) THEN
        RAISE EXCEPTION 'El venue con ID % no existe', p_venue_id;
    END IF;

    UPDATE eventos
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        estado = p_estado,
        es_publico = p_es_publico,
        organizador_id = p_organizador_id,
        tipo_evento_id = p_tipo_evento_id,
        venue_id = p_venue_id
    WHERE id = p_id;
END;
$$;

-- =========================================
-- CRUD: sp_eliminar_evento
-- =========================================
CREATE OR REPLACE PROCEDURE sp_eliminar_evento(
    p_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM eventos WHERE id = p_id) THEN
        RAISE EXCEPTION 'El evento con ID % no existe', p_id;
    END IF;

    IF EXISTS (SELECT 1 FROM ticket WHERE evento_id = p_id) THEN
        RAISE EXCEPTION 'No se puede eliminar el evento %: tiene tickets registrados', p_id;
    END IF;

    -- Eliminar asociaciones de artistas
    DELETE FROM evento_artistas WHERE evento_id = p_id;

    -- Eliminar evento
    DELETE FROM eventos WHERE id = p_id;
END;
$$;

-- =========================================
-- SP: sp_refresh_resumen_ventas
-- =========================================
CREATE OR REPLACE PROCEDURE sp_refresh_resumen_ventas()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mv_resumen_ventas_evento;
END;
$$;
