-- =========================================
-- SCRIPT 03: TABLAS DE CONTACTO
-- =========================================

-- =========================================
-- TABLA CORREO_USUARIOS
-- =========================================

CREATE TABLE correo_usuarios (
    id               SERIAL PRIMARY KEY,
    correo           VARCHAR(150),
    clasificacion_id INT,
    FOREIGN KEY (clasificacion_id) REFERENCES clasificaciones(id)
);

-- =========================================
-- TABLA TELEFONO_USUARIOS
-- =========================================

CREATE TABLE telefono_usuarios (
    id               SERIAL PRIMARY KEY,
    telefono         VARCHAR(20),
    clasificacion_id INT,
    FOREIGN KEY (clasificacion_id) REFERENCES clasificaciones(id)
);

-- =========================================
-- TABLA CORREO_ARTISTAS
-- =========================================

CREATE TABLE correo_artistas (
    id               SERIAL PRIMARY KEY,
    correo           VARCHAR(150),
    clasificacion_id INT,
    FOREIGN KEY (clasificacion_id) REFERENCES clasificaciones(id)
);

-- =========================================
-- TABLA TELEFONO_ARTISTAS
-- =========================================

CREATE TABLE telefono_artistas (
    id               SERIAL PRIMARY KEY,
    telefono         VARCHAR(20),
    clasificacion_id INT,
    FOREIGN KEY (clasificacion_id) REFERENCES clasificaciones(id)
);

-- =========================================
-- TABLA CORREO_ORGANIZADORES
-- =========================================

CREATE TABLE correo_organizadores (
    id                 SERIAL PRIMARY KEY,
    clasificacion_id   INT,
    correo_organizador VARCHAR(150),
    FOREIGN KEY (clasificacion_id) REFERENCES clasificaciones(id)
);

-- =========================================
-- TABLA TELEFONO_ORGANIZADORES
-- =========================================

CREATE TABLE telefono_organizadores (
    id               SERIAL PRIMARY KEY,
    telefono         VARCHAR(20),
    clasificacion_id INT,
    FOREIGN KEY (clasificacion_id) REFERENCES clasificaciones(id)
);

-- =========================================
-- TABLA DIRECCIONES
-- Nota: direccion_organizadores_id y direcciones_venues_id
--       son columnas de referencia presentes en el schema real.
-- =========================================

CREATE TABLE direcciones (
    id                       SERIAL PRIMARY KEY,
    clasificacion_id         INT,
    departamento_id          INT,
    municipio_id             INT,
    ciudad_id                INT,
    direccion_organizadores_id INT,
    direcciones_venues_id    INT,
    FOREIGN KEY (clasificacion_id) REFERENCES clasificaciones(id),
    FOREIGN KEY (departamento_id)  REFERENCES departamentos(departamento_id),
    FOREIGN KEY (municipio_id)     REFERENCES municipio(municipio_id),
    FOREIGN KEY (ciudad_id)        REFERENCES ciudad(ciudad_id)
);

-- =========================================
-- TABLA DIRECCIONES_ORGANIZADOR
-- =========================================

CREATE TABLE direcciones_organizador (
    id              SERIAL PRIMARY KEY,
    linea_direccion VARCHAR(255),
    direccion_id    INT,
    FOREIGN KEY (direccion_id) REFERENCES direcciones(id)
);

-- =========================================
-- TABLA DIRECCIONES_VENUES
-- =========================================

CREATE TABLE direcciones_venues (
    id              SERIAL PRIMARY KEY,
    linea_direccion VARCHAR(255),
    direccion_id    INT,
    FOREIGN KEY (direccion_id) REFERENCES direcciones(id)
);
