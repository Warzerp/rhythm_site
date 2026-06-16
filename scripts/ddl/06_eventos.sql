-- =========================================
-- SCRIPT 06: EVENTOS
-- =========================================

-- =========================================
-- TABLA EVENTOS
-- =========================================

CREATE TABLE eventos (
    id             SERIAL PRIMARY KEY,
    nombre         VARCHAR(150),
    descripcion    TEXT,
    fecha_inicio   DATE,
    fecha_fin      DATE,
    estado         VARCHAR(50),
    es_publico     BOOLEAN,
    organizador_id INT,
    tipo_evento_id INT,
    venue_id       INT,
    FOREIGN KEY (organizador_id) REFERENCES organizadores(id),
    FOREIGN KEY (tipo_evento_id) REFERENCES tipo_evento(id),
    FOREIGN KEY (venue_id)       REFERENCES venues(id)
);

-- =========================================
-- TABLA EVENTO_ARTISTAS
-- =========================================

CREATE TABLE evento_artistas (
    evento_id  INT NOT NULL,
    artista_id INT NOT NULL,
    PRIMARY KEY (evento_id, artista_id),
    FOREIGN KEY (evento_id)  REFERENCES eventos(id),
    FOREIGN KEY (artista_id) REFERENCES artistas(id)
);
