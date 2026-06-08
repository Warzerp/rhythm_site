-- =========================================
-- SCRIPT 07: TICKETS Y ÓRDENES
-- =========================================

-- =========================================
-- TABLA TICKET
-- =========================================

CREATE TABLE ticket (
    id             SERIAL PRIMARY KEY,
    precio         DECIMAL(10,2) NOT NULL,
    asiento_id     INT,
    tipo_ticket_id INT,
    cantidad_total INT,
    evento_id      INT,
    FOREIGN KEY (asiento_id)     REFERENCES asientos(id),
    FOREIGN KEY (tipo_ticket_id) REFERENCES tipo_tickets(id),
    FOREIGN KEY (evento_id)      REFERENCES eventos(id)
);

-- =========================================
-- TABLA ORDENES
-- =========================================

CREATE TABLE ordenes (
    id               SERIAL PRIMARY KEY,
    usuario_id       INT,
    ticket_id        INT,
    cantidad_tickets INT NOT NULL,
    fecha_compra     DATE,
    estado_pago      VARCHAR(50),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (ticket_id)  REFERENCES ticket(id)
);
