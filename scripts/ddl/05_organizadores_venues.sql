-- =========================================
-- SCRIPT 05: ORGANIZADORES Y VENUES
-- =========================================

-- =========================================
-- TABLA ORGANIZADORES
-- =========================================

CREATE TABLE organizadores (
    id                       SERIAL PRIMARY KEY,
    nombre                   VARCHAR(150) NOT NULL,
    NIT                      VARCHAR(20),
    estado                   VARCHAR(50),
    descripcion              TEXT,
    sitio_web                VARCHAR(255),
    correo_organizador_id    INT,
    telefono_organizador_id  INT,
    direccion_organizador_id INT,
    FOREIGN KEY (correo_organizador_id)    REFERENCES correo_organizadores(id),
    FOREIGN KEY (telefono_organizador_id)  REFERENCES telefono_organizadores(id),
    FOREIGN KEY (direccion_organizador_id) REFERENCES direcciones_organizador(id)
);

-- =========================================
-- TABLA VENUES
-- =========================================

CREATE TABLE venues (
    id             SERIAL PRIMARY KEY,
    nombre_venue   VARCHAR(150) NOT NULL,
    direcciones_id INT,
    FOREIGN KEY (direcciones_id) REFERENCES direcciones_venues(id)
);
