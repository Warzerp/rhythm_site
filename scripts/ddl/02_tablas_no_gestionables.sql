-- =========================================
-- SCRIPT 02: TABLAS NO GESTIONABLES
-- =========================================

-- =========================================
-- TABLA ROL_CUENTAS
-- =========================================

CREATE TABLE rol_cuentas (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(50)
);

-- =========================================
-- TABLA CLASIFICACIONES
-- =========================================

CREATE TABLE clasificaciones (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(50)
);

-- =========================================
-- TABLA PAISES
-- =========================================

CREATE TABLE paises (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

-- =========================================
-- TABLA DEPARTAMENTOS
-- =========================================

CREATE TABLE departamentos (
    departamento_id     SERIAL PRIMARY KEY,
    nombre_departamento VARCHAR(100)
);

-- =========================================
-- TABLA MUNICIPIO
-- =========================================

CREATE TABLE municipio (
    municipio_id     SERIAL PRIMARY KEY,
    nombre_municipio VARCHAR(100)
);

-- =========================================
-- TABLA CIUDAD
-- =========================================

CREATE TABLE ciudad (
    ciudad_id     SERIAL PRIMARY KEY,
    ciudad_nombre VARCHAR(100)
);

-- =========================================
-- TABLA TIPO_EVENTO
-- =========================================

CREATE TABLE tipo_evento (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

-- =========================================
-- TABLA TIPO_TICKETS
-- =========================================

CREATE TABLE tipo_tickets (
    id   SERIAL PRIMARY KEY,
    tipo VARCHAR(50)
);

-- =========================================
-- TABLA GENEROS
-- =========================================

CREATE TABLE generos (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

-- =========================================
-- TABLA TIPOS_ARTISTA
-- =========================================

CREATE TABLE tipos_artista (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

-- NOTA: Los INSERTs de estas tablas están centralizados
--       en el script 08_inserts_datos.sql
