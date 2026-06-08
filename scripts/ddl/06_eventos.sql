-- =========================================
-- SCRIPT 06: EVENTOS
-- =========================================

-- =========================================
-- TABLA EVENTOS
-- =========================================

CREATE TABLE eventos (
    id             SERIAL PRIMARY KEY,
    nombre         VARCHAR(150) NOT NULL,
    organizador_id INT,
    tipo_evento_id INT,
    descripcion    TEXT,
    fecha_inicio   TIMESTAMP,
    fecha_fin      TIMESTAMP,
    estado         VARCHAR(50),
    es_publico     BOOLEAN DEFAULT TRUE,
    imagen_url     VARCHAR(255),
    venue_id       INT,
    FOREIGN KEY (organizador_id) REFERENCES organizadores(id),
    FOREIGN KEY (tipo_evento_id) REFERENCES tipo_evento(id),
    FOREIGN KEY (venue_id)       REFERENCES venues(id)
);

-- =========================================
-- TABLA EVENTO_ARTISTAS
-- =========================================

CREATE TABLE evento_artistas (
    evento_id  INT,
    artista_id INT,
    PRIMARY KEY (evento_id, artista_id),
    FOREIGN KEY (evento_id)  REFERENCES eventos(id),
    FOREIGN KEY (artista_id) REFERENCES artistas(id)
);
