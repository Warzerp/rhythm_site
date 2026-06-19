-- =========================================
-- SCRIPT 11: ÍNDICES DE RENDIMIENTO (INDEXES)
-- =========================================

-- =========================================
-- ÍNDICES DE BÚSQUEDA Y FILTRADO
-- =========================================

-- Optimización para búsquedas de usuarios por su nick (ej: inicio de sesión)
CREATE INDEX IF NOT EXISTS idx_usuarios_nick 
ON usuarios(nick);

-- Búsquedas rápidas de artistas por su nombre artístico
CREATE INDEX IF NOT EXISTS idx_artistas_nombre_artistico 
ON artistas(nombre_artistico);

-- Filtrado de eventos futuros por fecha de inicio
CREATE INDEX IF NOT EXISTS idx_eventos_fecha_inicio 
ON eventos(fecha_inicio);

-- =========================================
-- ÍNDICES PARA LLAVES FORÁNEAS (OPTIMIZACIÓN DE JOINS)
-- =========================================

-- Optimización de búsquedas de tickets por evento
CREATE INDEX IF NOT EXISTS idx_ticket_evento_id 
ON ticket(evento_id);

-- Optimización de historial de órdenes por usuario
CREATE INDEX IF NOT EXISTS idx_ordenes_usuario_id 
ON ordenes(usuario_id);

-- Optimización de consultas de ventas por ticket
CREATE INDEX IF NOT EXISTS idx_ordenes_ticket_id 
ON ordenes(ticket_id);

-- Optimización para buscar eventos por artista en la relación muchos a muchos
CREATE INDEX IF NOT EXISTS idx_evento_artistas_artista 
ON evento_artistas(artista_id);
