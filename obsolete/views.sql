-- =========================================
-- SCRIPT 08: VISTAS Y VISTAS MATERIALIZADAS
-- =========================================

-- =========================================
-- VISTA: vw_usuarios_publicos
-- Muestra la información pública de los usuarios activos.
-- =========================================
CREATE OR REPLACE VIEW vw_usuarios_publicos AS
SELECT 
    id, 
    nick, 
    nombre, 
    apellido, 
    foto_perfil
FROM usuarios
WHERE activo = TRUE;

-- =========================================
-- VISTA: vw_tickets_evento
-- Muestra los tickets disponibles para cada evento con sus precios y stock.
-- =========================================
CREATE OR REPLACE VIEW vw_tickets_evento AS
SELECT 
    t.id AS ticket_id,
    e.id AS evento_id,
    e.nombre AS nombre_evento, 
    tt.tipo AS tipo_ticket,
    t.precio, 
    t.cantidad AS stock_disponible
FROM ticket t
JOIN eventos e ON t.evento_id = e.id
JOIN tipo_tickets tt ON t.tipo_ticket_id = tt.id;

-- =========================================
-- VISTA: vw_eventos_detallados
-- Información detallada de los eventos, incluyendo venues y organizadores.
-- =========================================
CREATE OR REPLACE VIEW vw_eventos_detallados AS
SELECT 
    e.id AS evento_id,
    e.nombre AS nombre_evento,
    e.descripcion,
    e.fecha_inicio,
    e.fecha_fin,
    e.estado,
    e.es_publico,
    te.nombre AS tipo_evento,
    o.nombre AS nombre_organizador,
    v.nombre_venue,
    c.ciudad_nombre AS ciudad,
    dep.nombre_departamento AS departamento
FROM eventos e
JOIN tipo_evento te ON e.tipo_evento_id = te.id
JOIN organizadores o ON e.organizador_id = o.id
JOIN venues v ON e.venue_id = v.id
LEFT JOIN direcciones_venues dv ON v.direcciones_id = dv.id
LEFT JOIN direcciones dir ON dv.direccion_id = dir.id
LEFT JOIN ciudad c ON dir.ciudad_id = c.ciudad_id
LEFT JOIN departamentos dep ON dir.departamento_id = dep.departamento_id;

-- =========================================
-- VISTA MATERIALIZADA: mv_resumen_ventas_evento
-- Resumen financiero y de ventas de cada evento.
-- =========================================
DROP MATERIALIZED VIEW IF EXISTS mv_resumen_ventas_evento;

CREATE MATERIALIZED VIEW mv_resumen_ventas_evento AS
SELECT 
    e.id AS evento_id,
    e.nombre AS nombre_evento,
    COUNT(o.id) AS total_ordenes,
    COALESCE(SUM(o.cantidad), 0) AS total_tickets_vendidos,
    COALESCE(SUM(o.cantidad * t.precio), 0) AS total_recaudado
FROM eventos e
LEFT JOIN ticket t ON t.evento_id = e.id
LEFT JOIN ordenes o ON o.ticket_id = t.id
GROUP BY e.id, e.nombre;

-- Crear un índice único en la vista materializada para permitir refrescos concurrentes si se desea más adelante.
CREATE UNIQUE INDEX idx_mv_resumen_ventas_evento ON mv_resumen_ventas_evento(evento_id);

-- =========================================
-- VISTA: vw_historial_compras_usuario
-- Muestra el historial completo de compras de los usuarios con detalles de evento.
-- =========================================
CREATE OR REPLACE VIEW vw_historial_compras_usuario AS
SELECT 
    ord.id AS orden_id,
    u.id AS usuario_id,
    u.nick AS usuario_nick,
    e.nombre AS nombre_evento,
    tt.tipo AS tipo_ticket,
    t.precio AS precio_unitario,
    ord.cantidad,
    (ord.cantidad * t.precio) AS total_pagado,
    ord.fecha_compra,
    ord.estado_pago
FROM ordenes ord
JOIN usuarios u ON ord.usuario_id = u.id
JOIN ticket t ON ord.ticket_id = t.id
JOIN eventos e ON t.evento_id = e.id
JOIN tipo_tickets tt ON t.tipo_ticket_id = tt.id;