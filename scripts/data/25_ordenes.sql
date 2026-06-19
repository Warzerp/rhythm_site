-- =========================================
-- INSERTS: ordenes
-- Segun backup real: cantidad, fecha_compra, estado_pago, usuario_id
-- (No existe ticket_id en el schema real)
-- usuario_id: 1-20 | estado_pago: 'pagado', 'pendiente', 'cancelado'
-- =========================================

INSERT INTO ordenes (cantidad, fecha_compra, estado_pago, usuario_id, ticket_id) VALUES
(2, '2025-06-01', 'pagado',    1, 1),
(1, '2025-06-02', 'pagado',    2, 2),
(1, '2025-06-03', 'pagado',    3, 3),
(2, '2025-06-04', 'pendiente', 4, 4),
(1, '2025-06-05', 'pagado',    5, 5),
(3, '2025-06-06', 'pagado',    6, 6),
(2, '2025-06-07', 'cancelado', 7, 7),
(1, '2025-06-08', 'pagado',    8, 8),
(5, '2025-06-09', 'pagado',    1, 9),
(2, '2025-06-10', 'pagado',    2, 10),
(1, '2025-06-11', 'pendiente', 3, 11),
(3, '2025-06-12', 'pagado',    4, 12),
(2, '2025-06-13', 'pagado',    5, 13),
(1, '2025-06-14', 'pagado',    6, 14),
(4, '2025-06-15', 'cancelado', 7, 15),
(2, '2025-06-16', 'pagado',    8, 16),
(1, '2025-06-17', 'pagado',    1, 17),
(3, '2025-06-18', 'pagado',    2, 18),
(2, '2025-06-19', 'pendiente', 3, 19),
(1, '2025-06-20', 'pagado',    4, 20);
