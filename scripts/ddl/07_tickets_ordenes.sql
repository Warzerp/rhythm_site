-- =========================================
-- SCRIPT 07: TICKETS Y ÓRDENES
-- =========================================

-- =========================================
-- TABLA TICKET
-- =========================================

CREATE TABLE ticket (
    id             SERIAL PRIMARY KEY,
    precio         NUMERIC(10,2),
    cantidad       INT,
    tipo_ticket_id INT,
    evento_id      INT,
    FOREIGN KEY (tipo_ticket_id) REFERENCES tipo_tickets(id),
    FOREIGN KEY (evento_id)      REFERENCES eventos(id)
);

-- =========================================
-- TABLA ORDENES
-- =========================================

CREATE TABLE ordenes (
    id           SERIAL PRIMARY KEY,
    cantidad     INT,
    fecha_compra DATE,
    estado_pago  VARCHAR(50),
    usuario_id   INT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);
