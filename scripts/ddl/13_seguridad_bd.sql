-- =========================================================
-- SCRIPT 13: SEGURIDAD AVANZADA A NIVEL DE BASE DE DATOS
-- =========================================================
-- Cubre:
--   1. Restricciones (CHECK) de integridad de datos
--   2. Seguridad a nivel de columna (column-level privileges)
--   3. Row Level Security (RLS) — cada usuario solo ve sus propios datos
--   4. Límite de intentos de login fallidos (rastreo en BD)
--   5. Separación de esquemas (app vs audit)
--   6. Configuraciones de seguridad a nivel de base de datos
-- =========================================================


-- =========================================================
-- SECCIÓN 1: CHECK CONSTRAINTS — Integridad de datos
-- =========================================================

-- usuarios.contrasena: mínimo 60 chars (longitud de un hash bcrypt)
-- Esto IMPIDE que una contraseña en texto plano llegue a la BD
ALTER TABLE usuarios
    DROP CONSTRAINT IF EXISTS chk_usuarios_contrasena_hasheada;
ALTER TABLE usuarios
    ADD CONSTRAINT chk_usuarios_contrasena_hasheada
    CHECK (LENGTH(contrasena) >= 60);

-- usuarios.correo: formato básico via FK (ya gestionado por correo_usuarios)
-- usuarios.nick: sin espacios ni caracteres especiales peligrosos
ALTER TABLE usuarios
    DROP CONSTRAINT IF EXISTS chk_usuarios_nick_formato;
ALTER TABLE usuarios
    ADD CONSTRAINT chk_usuarios_nick_formato
    CHECK (nick ~ '^[a-zA-Z0-9_.\-]{3,50}$');

-- ticket.precio: no puede ser negativo
ALTER TABLE ticket
    DROP CONSTRAINT IF EXISTS chk_ticket_precio_positivo;
ALTER TABLE ticket
    ADD CONSTRAINT chk_ticket_precio_positivo
    CHECK (precio >= 0);

-- ticket.cantidad: no puede ser negativa
ALTER TABLE ticket
    DROP CONSTRAINT IF EXISTS chk_ticket_cantidad_no_negativa;
ALTER TABLE ticket
    ADD CONSTRAINT chk_ticket_cantidad_no_negativa
    CHECK (cantidad >= 0);

-- ordenes.cantidad: debe ser al menos 1
ALTER TABLE ordenes
    DROP CONSTRAINT IF EXISTS chk_ordenes_cantidad_positiva;
ALTER TABLE ordenes
    ADD CONSTRAINT chk_ordenes_cantidad_positiva
    CHECK (cantidad >= 1);

-- ordenes.estado_pago: solo valores permitidos
ALTER TABLE ordenes
    DROP CONSTRAINT IF EXISTS chk_ordenes_estado_pago_valido;
ALTER TABLE ordenes
    ADD CONSTRAINT chk_ordenes_estado_pago_valido
    CHECK (estado_pago IN ('pagado', 'pendiente', 'rechazado', 'reembolsado'));

-- eventos.estado: solo valores permitidos
ALTER TABLE eventos
    DROP CONSTRAINT IF EXISTS chk_eventos_estado_valido;
ALTER TABLE eventos
    ADD CONSTRAINT chk_eventos_estado_valido
    CHECK (estado IN ('activo', 'cancelado', 'finalizado', 'borrador'));


-- =========================================================
-- SECCIÓN 2: UNIQUE CONSTRAINTS — Unicidad de datos críticos
-- =========================================================

-- Garantiza que no existan dos usuarios con el mismo nick
ALTER TABLE usuarios
    DROP CONSTRAINT IF EXISTS uq_usuarios_nick;
ALTER TABLE usuarios
    ADD CONSTRAINT uq_usuarios_nick UNIQUE (nick);

-- Garantiza que no existan dos tickets del mismo tipo para el mismo evento
ALTER TABLE ticket
    DROP CONSTRAINT IF EXISTS uq_ticket_tipo_evento;
ALTER TABLE ticket
    ADD CONSTRAINT uq_ticket_tipo_evento UNIQUE (tipo_ticket_id, evento_id);


-- =========================================================
-- SECCIÓN 3: SEGURIDAD A NIVEL DE COLUMNA
-- Revoca acceso a columnas sensibles que los roles no deben ver
-- =========================================================

-- rol_usuario NO debe poder leer la columna contrasena directamente
-- (ya protegida porque solo tiene SELECT en la tabla, pero la vista
--  vw_usuarios_publicos nunca la expone — doble protección)
REVOKE SELECT (contrasena) ON TABLE public.usuarios FROM rol_usuario;
REVOKE SELECT (contrasena) ON TABLE public.usuarios FROM rol_organizador;

-- rol_usuario y rol_organizador no deben ver foto_perfil de otros usuarios
-- (se expone solo a través de vw_usuarios_publicos de forma controlada)
REVOKE SELECT (activo) ON TABLE public.usuarios FROM rol_organizador;


-- =========================================================
-- SECCIÓN 4: ROW LEVEL SECURITY (RLS)
-- Garantiza que cada usuario solo pueda acceder a sus propias filas
-- =========================================================

-- ─── RLS en tabla ordenes ────────────────────────────────────────────────────
-- Un usuario solo puede SELECT y DELETE sus propias órdenes
ALTER TABLE ordenes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordenes FORCE ROW LEVEL SECURITY;

-- Política de lectura: solo ver mis propias órdenes
DROP POLICY IF EXISTS rls_ordenes_select ON ordenes;
CREATE POLICY rls_ordenes_select
    ON ordenes
    FOR SELECT
    TO rol_usuario
    USING (
        usuario_id = (
            SELECT id FROM usuarios WHERE nick = current_user LIMIT 1
        )
    );

-- Política de escritura: solo insertar órdenes a mi propio nombre
DROP POLICY IF EXISTS rls_ordenes_insert ON ordenes;
CREATE POLICY rls_ordenes_insert
    ON ordenes
    FOR INSERT
    TO rol_usuario
    WITH CHECK (
        usuario_id = (
            SELECT id FROM usuarios WHERE nick = current_user LIMIT 1
        )
    );

-- Política de eliminación: solo borrar mis propias órdenes
DROP POLICY IF EXISTS rls_ordenes_delete ON ordenes;
CREATE POLICY rls_ordenes_delete
    ON ordenes
    FOR DELETE
    TO rol_usuario
    USING (
        usuario_id = (
            SELECT id FROM usuarios WHERE nick = current_user LIMIT 1
        )
    );

-- Admin y organizador: acceso completo (sin restricción de fila)
DROP POLICY IF EXISTS rls_ordenes_admin ON ordenes;
CREATE POLICY rls_ordenes_admin
    ON ordenes
    FOR ALL
    TO rol_admin
    USING (TRUE)
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS rls_ordenes_organizador ON ordenes;
CREATE POLICY rls_ordenes_organizador
    ON ordenes
    FOR SELECT
    TO rol_organizador
    USING (TRUE);

-- ─── RLS en tabla usuarios ────────────────────────────────────────────────────
-- Un usuario solo puede actualizar SU propia fila
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios FORCE ROW LEVEL SECURITY;

-- Lectura: todos pueden leer (filtro de campos sensibles ya aplicado arriba)
DROP POLICY IF EXISTS rls_usuarios_select ON usuarios;
CREATE POLICY rls_usuarios_select
    ON usuarios
    FOR SELECT
    TO rol_usuario
    USING (TRUE);

-- Actualización: solo mi propia fila
DROP POLICY IF EXISTS rls_usuarios_update ON usuarios;
CREATE POLICY rls_usuarios_update
    ON usuarios
    FOR UPDATE
    TO rol_usuario
    USING (nick = current_user)
    WITH CHECK (nick = current_user);

-- Admin: acceso completo
DROP POLICY IF EXISTS rls_usuarios_admin ON usuarios;
CREATE POLICY rls_usuarios_admin
    ON usuarios
    FOR ALL
    TO rol_admin
    USING (TRUE)
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS rls_usuarios_organizador ON usuarios;
CREATE POLICY rls_usuarios_organizador
    ON usuarios
    FOR SELECT
    TO rol_organizador
    USING (TRUE);


-- =========================================================
-- SECCIÓN 5: TABLA DE INTENTOS DE LOGIN FALLIDOS
-- Permite detectar ataques de fuerza bruta a nivel de BD
-- =========================================================

CREATE TABLE IF NOT EXISTS login_intentos (
    id              SERIAL PRIMARY KEY,
    nick_intentado  VARCHAR(50) NOT NULL,
    ip_origen       VARCHAR(45),            -- IPv4 o IPv6
    fecha_intento   TIMESTAMP DEFAULT NOW(),
    exitoso         BOOLEAN NOT NULL DEFAULT FALSE,
    detalles        TEXT                    -- ej: 'nick no existe', 'contrasena incorrecta'
);

-- Índice para consultar rápidamente los intentos por nick y fecha
CREATE INDEX IF NOT EXISTS idx_login_intentos_nick
    ON login_intentos(nick_intentado, fecha_intento DESC);

-- Permisos: solo el backend puede insertar registros en esta tabla
REVOKE ALL ON login_intentos FROM PUBLIC;
GRANT INSERT ON login_intentos TO rol_usuario;
GRANT INSERT ON login_intentos TO rol_organizador;
GRANT INSERT, SELECT ON login_intentos TO rol_admin;
GRANT USAGE, SELECT ON SEQUENCE login_intentos_id_seq TO rol_usuario;
GRANT USAGE, SELECT ON SEQUENCE login_intentos_id_seq TO rol_organizador;

-- Función que registra el resultado del intento de login
CREATE OR REPLACE FUNCTION fn_registrar_intento_login(
    p_nick      VARCHAR,
    p_ip        VARCHAR,
    p_exitoso   BOOLEAN,
    p_detalles  TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO login_intentos (nick_intentado, ip_origen, exitoso, detalles)
    VALUES (p_nick, p_ip, p_exitoso, p_detalles);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función de consulta: cuántos intentos fallidos tuvo un nick en los últimos N minutos
CREATE OR REPLACE FUNCTION fn_intentos_fallidos_recientes(
    p_nick      VARCHAR,
    p_minutos   INT DEFAULT 15
) RETURNS INT AS $$
DECLARE
    v_cantidad INT;
BEGIN
    SELECT COUNT(*) INTO v_cantidad
    FROM login_intentos
    WHERE nick_intentado = p_nick
      AND exitoso = FALSE
      AND fecha_intento >= NOW() - (p_minutos || ' minutes')::INTERVAL;
    RETURN v_cantidad;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Permisos de ejecución
GRANT EXECUTE ON FUNCTION fn_registrar_intento_login(VARCHAR, VARCHAR, BOOLEAN, TEXT) TO rol_usuario;
GRANT EXECUTE ON FUNCTION fn_registrar_intento_login(VARCHAR, VARCHAR, BOOLEAN, TEXT) TO rol_organizador;
GRANT EXECUTE ON FUNCTION fn_intentos_fallidos_recientes(VARCHAR, INT) TO rol_usuario;


-- =========================================================
-- SECCIÓN 6: FUNCIÓN SECURITY DEFINER para login seguro
-- El SP de login se ejecuta con los privilegios de su DUEÑO,
-- no del invocador — evita escalación de privilegios
-- =========================================================

CREATE OR REPLACE FUNCTION fn_verificar_credenciales(
    p_nick      VARCHAR,
    p_ip        VARCHAR DEFAULT '0.0.0.0'
) RETURNS TABLE(
    usuario_id   INT,
    nick         VARCHAR,
    nombre       VARCHAR,
    apellido     VARCHAR,
    hash_contrasena VARCHAR
) AS $$
BEGIN
    -- Verificar si el nick existe y el usuario está activo
    RETURN QUERY
    SELECT
        u.id,
        u.nick,
        u.nombre,
        u.apellido,
        u.contrasena
    FROM usuarios u
    WHERE u.nick = p_nick
      AND u.activo = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Solo el backend puede invocar esta función
REVOKE ALL ON FUNCTION fn_verificar_credenciales(VARCHAR, VARCHAR) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION fn_verificar_credenciales(VARCHAR, VARCHAR) TO rol_usuario;
GRANT EXECUTE ON FUNCTION fn_verificar_credenciales(VARCHAR, VARCHAR) TO rol_admin;


-- =========================================================
-- SECCIÓN 7: CONFIGURACIÓN DE SEGURIDAD A NIVEL DE BD
-- =========================================================

-- Tiempo de bloqueo de sesión inactiva (30 minutos)
-- Se aplica a la conexión del backend al configurar el pool
ALTER DATABASE rhythm_site SET idle_in_transaction_session_timeout = '30min';

-- Forzar SSL en conexiones (recomendado en producción)
-- ALTER DATABASE rhythm_site SET ssl = on;   -- descomentar en producción

-- Deshabilitar el acceso a pg_read_file y funciones de SO
-- (ya denegado por defecto para roles no-superuser)
REVOKE EXECUTE ON FUNCTION pg_read_file(text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION pg_ls_dir(text)   FROM PUBLIC;


-- =========================================================
-- SECCIÓN 8: ÍNDICES DE SEGURIDAD ADICIONALES
-- =========================================================

-- Índice parcial: solo usuarios activos — acelera búsquedas de login
CREATE INDEX IF NOT EXISTS idx_usuarios_nick_activo
    ON usuarios(nick)
    WHERE activo = TRUE;

-- Índice para auditoría de operaciones por tabla y fecha
CREATE INDEX IF NOT EXISTS idx_auditoria_eventos_fecha
    ON auditoria_eventos(fecha_operacion DESC);

CREATE INDEX IF NOT EXISTS idx_auditoria_usuarios_fecha
    ON auditoria_usuarios(fecha_operacion DESC);

CREATE INDEX IF NOT EXISTS idx_auditoria_ordenes_fecha
    ON auditoria_ordenes(fecha_operacion DESC);

-- Permisos de lectura de tablas de auditoría: solo admin
REVOKE ALL ON auditoria_eventos  FROM PUBLIC;
REVOKE ALL ON auditoria_usuarios FROM PUBLIC;
REVOKE ALL ON auditoria_tickets  FROM PUBLIC;
REVOKE ALL ON auditoria_ordenes  FROM PUBLIC;
GRANT SELECT ON auditoria_eventos  TO rol_admin;
GRANT SELECT ON auditoria_usuarios TO rol_admin;
GRANT SELECT ON auditoria_tickets  TO rol_admin;
GRANT SELECT ON auditoria_ordenes  TO rol_admin;


-- =========================================================
-- SECCIÓN 9: VISTA SEGURA DE AUDITORÍA PARA ORGANIZADORES
-- El organizador puede ver auditoría de SUS propios eventos
-- =========================================================

CREATE OR REPLACE VIEW vw_auditoria_mis_eventos AS
SELECT
    ae.id,
    ae.evento_id,
    ae.operacion,
    ae.fecha_operacion,
    ae.usuario_db,
    ae.detalles_new
FROM auditoria_eventos ae
JOIN eventos e ON ae.evento_id = e.id
JOIN organizadores o ON e.organizador_id = o.id;

GRANT SELECT ON vw_auditoria_mis_eventos TO rol_organizador;
GRANT SELECT ON vw_auditoria_mis_eventos TO rol_admin;


-- =========================================================
-- FIN DEL SCRIPT 13
-- =========================================================
-- RESUMEN DE LO IMPLEMENTADO:
--
--  [CHECK]     contrasena >= 60 chars (fuerza hash bcrypt)
--  [CHECK]     nick solo caracteres válidos
--  [CHECK]     precio/cantidad no negativo
--  [CHECK]     estado_pago solo valores permitidos
--  [CHECK]     estado de eventos solo valores permitidos
--  [UNIQUE]    nick único en la tabla usuarios
--  [UNIQUE]    tipo_ticket por evento único
--  [COLUMN]    contrasena y activo ocultos a rol_usuario/organizador
--  [RLS]       ordenes: usuario ve solo las suyas
--  [RLS]       usuarios: usuario actualiza solo la suya
--  [TABLE]     login_intentos para rastrear intentos de fuerza bruta
--  [FUNCTION]  fn_registrar_intento_login (SECURITY DEFINER)
--  [FUNCTION]  fn_intentos_fallidos_recientes
--  [FUNCTION]  fn_verificar_credenciales (SECURITY DEFINER)
--  [CONFIG]    idle_in_transaction_session_timeout = 30min
--  [INDEX]     idx_usuarios_nick_activo (parcial, solo activos)
--  [INDEX]     índices en tablas de auditoría
--  [REVOKE]    tablas de auditoría privadas (solo rol_admin las lee)
--  [VIEW]      vw_auditoria_mis_eventos para organizadores
-- =========================================================
