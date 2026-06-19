-- =========================================
-- SCRIPT 10: DISPARADORES (TRIGGERS) Y TABLAS DE AUDITORÍA
-- =========================================

-- =========================================
-- TABLA: auditoria_eventos
-- =========================================
CREATE TABLE IF NOT EXISTS auditoria_eventos (
    id              SERIAL PRIMARY KEY,
    evento_id       INT,
    operacion       VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_db      VARCHAR(100) DEFAULT CURRENT_USER,
    detalles_old    TEXT,
    detalles_new    TEXT
);

-- =========================================
-- TABLA: auditoria_usuarios
-- =========================================
CREATE TABLE IF NOT EXISTS auditoria_usuarios (
    id              SERIAL PRIMARY KEY,
    usuario_id      INT,
    operacion       VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_db      VARCHAR(100) DEFAULT CURRENT_USER,
    detalles_old    TEXT,
    detalles_new    TEXT
);

-- =========================================
-- TABLA: auditoria_tickets
-- =========================================
CREATE TABLE IF NOT EXISTS auditoria_tickets (
    id              SERIAL PRIMARY KEY,
    ticket_id       INT,
    operacion       VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_db      VARCHAR(100) DEFAULT CURRENT_USER,
    detalles_old    TEXT,
    detalles_new    TEXT
);

-- =========================================
-- TABLA: auditoria_ordenes
-- =========================================
CREATE TABLE IF NOT EXISTS auditoria_ordenes (
    id              SERIAL PRIMARY KEY,
    orden_id        INT,
    operacion       VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_db      VARCHAR(100) DEFAULT CURRENT_USER,
    detalles_old    TEXT,
    detalles_new    TEXT
);


-- =========================================
-- FUNCIÓN TRIGGER: fn_validar_fechas_evento
-- =========================================
CREATE OR REPLACE FUNCTION fn_validar_fechas_evento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin < NEW.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha de fin (%) no puede ser anterior a la fecha de inicio (%)', NEW.fecha_fin, NEW.fecha_inicio;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- FUNCIÓN TRIGGER: fn_validar_stock_antes_de_orden
-- =========================================
CREATE OR REPLACE FUNCTION fn_validar_stock_antes_de_orden()
RETURNS TRIGGER AS $$
DECLARE
    v_stock INT;
BEGIN
    -- Bloquear y seleccionar stock
    SELECT cantidad INTO v_stock FROM ticket WHERE id = NEW.ticket_id FOR UPDATE;
    
    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'El ticket con ID % no existe', NEW.ticket_id;
    END IF;

    -- Validar cantidad solicitada
    IF NEW.cantidad > v_stock THEN
        RAISE EXCEPTION 'Stock insuficiente para el ticket id %. Disponible: %, solicitado: %', NEW.ticket_id, v_stock, NEW.cantidad;
    END IF;

    -- Descontar el stock automáticamente
    UPDATE ticket 
    SET cantidad = cantidad - NEW.cantidad 
    WHERE id = NEW.ticket_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- =========================================
-- FUNCIÓN TRIGGER: fn_auditar_cambios_evento
-- =========================================
CREATE OR REPLACE FUNCTION fn_auditar_cambios_evento()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_eventos (evento_id, operacion, detalles_new)
        VALUES (NEW.id, 'INSERT', ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_eventos (evento_id, operacion, detalles_old, detalles_new)
        VALUES (NEW.id, 'UPDATE', ROW_TO_JSON(OLD)::TEXT, ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_eventos (evento_id, operacion, detalles_old)
        VALUES (OLD.id, 'DELETE', ROW_TO_JSON(OLD)::TEXT);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- FUNCIÓN TRIGGER: fn_auditar_cambios_usuario
-- =========================================
CREATE OR REPLACE FUNCTION fn_auditar_cambios_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_usuarios (usuario_id, operacion, detalles_new)
        VALUES (NEW.id, 'INSERT', ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_usuarios (usuario_id, operacion, detalles_old, detalles_new)
        VALUES (NEW.id, 'UPDATE', ROW_TO_JSON(OLD)::TEXT, ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_usuarios (usuario_id, operacion, detalles_old)
        VALUES (OLD.id, 'DELETE', ROW_TO_JSON(OLD)::TEXT);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- FUNCIÓN TRIGGER: fn_auditar_cambios_ticket
-- =========================================
CREATE OR REPLACE FUNCTION fn_auditar_cambios_ticket()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_tickets (ticket_id, operacion, detalles_new)
        VALUES (NEW.id, 'INSERT', ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_tickets (ticket_id, operacion, detalles_old, detalles_new)
        VALUES (NEW.id, 'UPDATE', ROW_TO_JSON(OLD)::TEXT, ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_tickets (ticket_id, operacion, detalles_old)
        VALUES (OLD.id, 'DELETE', ROW_TO_JSON(OLD)::TEXT);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- FUNCIÓN TRIGGER: fn_auditar_cambios_orden
-- =========================================
CREATE OR REPLACE FUNCTION fn_auditar_cambios_orden()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_ordenes (orden_id, operacion, detalles_new)
        VALUES (NEW.id, 'INSERT', ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_ordenes (orden_id, operacion, detalles_old, detalles_new)
        VALUES (NEW.id, 'UPDATE', ROW_TO_JSON(OLD)::TEXT, ROW_TO_JSON(NEW)::TEXT);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_ordenes (orden_id, operacion, detalles_old)
        VALUES (OLD.id, 'DELETE', ROW_TO_JSON(OLD)::TEXT);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- =========================================
-- CREACIÓN DE TRIGGERS
-- =========================================

-- Triggers de validación de negocio
DROP TRIGGER IF EXISTS trg_validar_fechas_evento ON eventos;
CREATE TRIGGER trg_validar_fechas_evento
BEFORE INSERT OR UPDATE ON eventos
FOR EACH ROW
EXECUTE FUNCTION fn_validar_fechas_evento();

DROP TRIGGER IF EXISTS trg_validar_stock_antes_de_orden ON ordenes;
CREATE TRIGGER trg_validar_stock_antes_de_orden
BEFORE INSERT ON ordenes
FOR EACH ROW
EXECUTE FUNCTION fn_validar_stock_antes_de_orden();

-- Triggers de auditoría
DROP TRIGGER IF EXISTS trg_auditar_cambios_evento ON eventos;
CREATE TRIGGER trg_auditar_cambios_evento
AFTER INSERT OR UPDATE OR DELETE ON eventos
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cambios_evento();

DROP TRIGGER IF EXISTS trg_auditar_cambios_usuario ON usuarios;
CREATE TRIGGER trg_auditar_cambios_usuario
AFTER INSERT OR UPDATE OR DELETE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cambios_usuario();

DROP TRIGGER IF EXISTS trg_auditar_cambios_ticket ON ticket;
CREATE TRIGGER trg_auditar_cambios_ticket
AFTER INSERT OR UPDATE OR DELETE ON ticket
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cambios_ticket();

DROP TRIGGER IF EXISTS trg_auditar_cambios_orden ON ordenes;
CREATE TRIGGER trg_auditar_cambios_orden
AFTER INSERT OR UPDATE OR DELETE ON ordenes
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cambios_orden();
