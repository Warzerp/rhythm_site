-- =========================================
-- INSERTS: ticket
-- tipo_ticket_id: 1=Basico, 2=Plus, 3=VIP
-- evento_id: 1-20
-- asiento: texto libre (General, Preferente, VIP, etc.)
-- =========================================

INSERT INTO ticket (precio, asiento, cantidad_total, tipo_ticket_id, evento_id) VALUES
(150.00, 'General',    500, 1,  1),
(280.00, 'Preferente', 200, 2,  1),
(500.00, 'VIP',         50, 3,  1),
(200.00, 'General',    800, 1,  2),
(350.00, 'Preferente', 300, 2,  2),
(650.00, 'VIP',        100, 3,  2),
(120.00, 'General',    300, 1,  3),
(220.00, 'Preferente', 150, 2,  3),
(100.00, 'General',    200, 1,  4),
(180.00, 'Preferente', 100, 2,  4),
(175.00, 'General',    600, 1,  5),
(320.00, 'Preferente', 250, 2,  5),
(575.00, 'VIP',         75, 3,  5),
(130.00, 'Platea',     400, 1,  6),
(250.00, 'Palco',      150, 2,  6),
(450.00, 'VIP',         40, 3,  6),
(190.00, 'General',    700, 1,  7),
(380.00, 'Preferente', 250, 2,  7),
(700.00, 'VIP',        120, 3,  7),
(85.00,  'General',    150, 1,  8),
(160.00, 'Preferente',  80, 2,  8),
(140.00, 'General',    400, 1,  9),
(260.00, 'Preferente', 200, 2,  9),
(100.00, 'General',    100, 1,  10),
(200.00, 'VIP',         30, 3,  10),
(110.00, 'General',    350, 1,  11),
(210.00, 'Preferente', 180, 2,  11),
(165.00, 'General',    500, 1,  12),
(290.00, 'Preferente', 200, 2,  12),
(125.00, 'General',    250, 1,  13);
