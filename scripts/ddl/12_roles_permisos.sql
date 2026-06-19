-- =========================================
-- SCRIPT 12: ROLES Y PERMISOS
-- =========================================

-- =========================================
-- CREACIÓN DE ROLES (Evitando errores si ya existen)
-- =========================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'rol_usuario') THEN
        CREATE ROLE rol_usuario;
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'rol_organizador') THEN
        CREATE ROLE rol_organizador;
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'rol_admin') THEN
        CREATE ROLE rol_admin;
    END IF;
END
$$;

-- Revocar todos los privilegios por defecto del esquema public a PUBLIC (buena práctica de seguridad)
REVOKE ALL PRIVILEGES ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO PUBLIC;

-- =========================================
-- PERMISOS: rol_usuario
-- =========================================

-- Tabla ordenes: Select, Insert, Delete
GRANT SELECT, INSERT, DELETE ON TABLE public.ordenes TO rol_usuario;
-- Secuencia asociada a ordenes (necesaria para inserciones SERIAL)
GRANT USAGE, SELECT ON SEQUENCE public.ordenes_id_seq TO rol_usuario;

-- Tabla usuarios: Update en columnas específicas y Select
GRANT SELECT ON TABLE public.usuarios TO rol_usuario;
GRANT UPDATE (nombre, nick, contrasena, apellido) ON TABLE public.usuarios TO rol_usuario;

-- Permisos adicionales requeridos para que un usuario pueda operar en la tienda
GRANT SELECT ON TABLE public.ticket TO rol_usuario;
GRANT SELECT ON TABLE public.eventos TO rol_usuario;
GRANT SELECT ON TABLE public.tipo_tickets TO rol_usuario;
GRANT SELECT ON TABLE public.tipo_evento TO rol_usuario;
GRANT SELECT ON TABLE public.venues TO rol_usuario;

-- Permisos de lectura en vistas públicas
GRANT SELECT ON public.vw_usuarios_publicos TO rol_usuario;
GRANT SELECT ON public.vw_tickets_evento TO rol_usuario;
GRANT SELECT ON public.vw_eventos_detallados TO rol_usuario;
GRANT SELECT ON public.vw_historial_compras_usuario TO rol_usuario;

-- Permiso de ejecución en el procedimiento de compra y funciones auxiliares
GRANT EXECUTE ON FUNCTION fn_insertar_orden(INT, INT, INT, DATE, VARCHAR) TO rol_usuario;
GRANT EXECUTE ON PROCEDURE sp_comprar_tickets(INT, INT, INT) TO rol_usuario;

-- =========================================
-- PERMISOS: rol_organizador
-- =========================================

-- Tabla eventos: Insert, Update (all), Delete
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.eventos TO rol_organizador;
GRANT USAGE, SELECT ON SEQUENCE public.eventos_id_seq TO rol_organizador;

-- Tabla ticket: Insert, Update (precio, cantidad)
GRANT SELECT, INSERT ON TABLE public.ticket TO rol_organizador;
GRANT UPDATE (precio, cantidad) ON TABLE public.ticket TO rol_organizador;
GRANT USAGE, SELECT ON SEQUENCE public.ticket_id_seq TO rol_organizador;

-- Permisos de lectura auxiliares para gestionar sus eventos
GRANT SELECT ON TABLE public.tipo_tickets TO rol_organizador;
GRANT SELECT ON TABLE public.tipo_evento TO rol_organizador;
GRANT SELECT ON TABLE public.venues TO rol_organizador;
GRANT SELECT ON TABLE public.organizadores TO rol_organizador;

-- Permisos de lectura en vistas y ejecución en procedimientos de tickets
GRANT SELECT ON public.vw_eventos_detallados TO rol_organizador;
GRANT SELECT ON public.vw_tickets_evento TO rol_organizador;
GRANT EXECUTE ON FUNCTION fn_crear_ticket(DECIMAL, INT, INT, INT) TO rol_organizador;
GRANT EXECUTE ON FUNCTION fn_eliminar_ticket(INT) TO rol_organizador;
GRANT EXECUTE ON PROCEDURE sp_crear_ticket(DECIMAL, INT, INT, INT) TO rol_organizador;
GRANT EXECUTE ON PROCEDURE sp_actualizar_ticket(INT, DECIMAL, INT) TO rol_organizador;
GRANT EXECUTE ON PROCEDURE sp_eliminar_ticket(INT) TO rol_organizador;

-- Permisos adicionales para gestión de eventos y artistas
GRANT SELECT ON TABLE public.artistas TO rol_organizador;
GRANT SELECT, INSERT, DELETE ON TABLE public.evento_artistas TO rol_organizador;
GRANT EXECUTE ON PROCEDURE sp_crear_evento(VARCHAR, TEXT, DATE, DATE, VARCHAR, BOOLEAN, INT, INT, INT, INT[]) TO rol_organizador;
GRANT EXECUTE ON PROCEDURE sp_actualizar_evento(INT, VARCHAR, TEXT, DATE, DATE, VARCHAR, BOOLEAN, INT, INT, INT) TO rol_organizador;
GRANT EXECUTE ON PROCEDURE sp_eliminar_evento(INT) TO rol_organizador;

-- =========================================
-- PERMISOS: rol_organizador — vista materializada de ventas
-- =========================================
GRANT SELECT ON public.mv_resumen_ventas_evento TO rol_organizador;

-- =========================================
-- PERMISOS: rol_admin (Acceso Completo)
-- =========================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rol_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO rol_admin;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public TO rol_admin;

-- =========================================
-- USUARIOS DE LOGIN (app users)
-- Se crean con contraseñas de ejemplo; cambiarlas en producción.
-- =========================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_usuario') THEN
        CREATE USER app_usuario WITH PASSWORD 'usr_rhythm_2024' CONNECTION LIMIT 50;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_organizador') THEN
        CREATE USER app_organizador WITH PASSWORD 'org_rhythm_2024' CONNECTION LIMIT 20;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_admin') THEN
        CREATE USER app_admin WITH PASSWORD 'adm_rhythm_2024' CONNECTION LIMIT 10;
    END IF;
END
$$;

-- Asignar roles a los usuarios de login
GRANT rol_usuario      TO app_usuario;
GRANT rol_organizador  TO app_organizador;
GRANT rol_admin        TO app_admin;
