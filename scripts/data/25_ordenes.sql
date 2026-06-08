-- =========================================
-- INSERTS: ordenes
-- DDL real incluye ticket_id (FK a ticket)
-- usuario_id: 1-20 | ticket_id: 1-30
-- estado_pago: 'pagado', 'pendiente', 'cancelado'
-- =========================================

INSERT INTO ordenes (usuario_id, ticket_id, cantidad, fecha_compra, estado_pago) VALUES
(1,  1,  2, '2025-06-01', 'pagado'),
(2,  2,  1, '2025-06-02', 'pagado'),
(3,  3,  1, '2025-06-03', 'pagado'),
(4,  4,  2, '2025-06-04', 'pendiente'),
(5,  5,  1, '2025-06-05', 'pagado'),
(6,  6,  3, '2025-06-06', 'pagado'),
(7,  7,  2, '2025-06-07', 'cancelado'),
(8,  8,  1, '2025-06-08', 'pagado'),
(9,  9,  5, '2025-06-09', 'pagado'),
(10, 10, 2, '2025-06-10', 'pagado'),
(11, 11, 1, '2025-06-11', 'pendiente'),
(12, 12, 3, '2025-06-12', 'pagado'),
(1,  13, 2, '2025-06-13', 'pagado'),
(2,  14, 1, '2025-06-14', 'pagado'),
(3,  15, 4, '2025-06-15', 'cancelado'),
(4,  16, 2, '2025-06-16', 'pagado'),
(5,  17, 1, '2025-06-17', 'pagado'),
(6,  18, 3, '2025-06-18', 'pagado'),
(7,  19, 2, '2025-06-19', 'pendiente'),
(8,  20, 1, '2025-06-20', 'pagado');
