-- =========================================
-- INSERTS: ordenes
-- Segun backup real: cantidad, fecha_compra, estado_pago, usuario_id
-- (No existe ticket_id en el schema real)
-- usuario_id: 1-20 | estado_pago: 'pagado', 'pendiente', 'cancelado'
-- =========================================

INSERT INTO ordenes (cantidad, fecha_compra, estado_pago, usuario_id) VALUES
(2, '2025-06-01', 'pagado',    1),
(1, '2025-06-02', 'pagado',    2),
(1, '2025-06-03', 'pagado',    3),
(2, '2025-06-04', 'pendiente', 4),
(1, '2025-06-05', 'pagado',    5),
(3, '2025-06-06', 'pagado',    6),
(2, '2025-06-07', 'cancelado', 7),
(1, '2025-06-08', 'pagado',    8),
(5, '2025-06-09', 'pagado',    1),
(2, '2025-06-10', 'pagado',    2),
(1, '2025-06-11', 'pendiente', 3),
(3, '2025-06-12', 'pagado',    4),
(2, '2025-06-13', 'pagado',    5),
(1, '2025-06-14', 'pagado',    6),
(4, '2025-06-15', 'cancelado', 7),
(2, '2025-06-16', 'pagado',    8),
(1, '2025-06-17', 'pagado',    1),
(3, '2025-06-18', 'pagado',    2),
(2, '2025-06-19', 'pendiente', 3),
(1, '2025-06-20', 'pagado',    4);
