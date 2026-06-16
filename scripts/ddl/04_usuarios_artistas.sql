-- =========================================
-- SCRIPT 04: USUARIOS Y ARTISTAS
-- =========================================

-- =========================================
-- TABLA USUARIOS
-- =========================================

CREATE TABLE usuarios (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100),
    apellido            VARCHAR(100),
    nick                VARCHAR(50),
    contrasena          VARCHAR(255),
    activo              BOOLEAN,
    fecha_nacimiento    DATE,
    foto_perfil         VARCHAR(255),
    rol_cuenta          INT,
    correo_usuarios_id  INT,
    telefono_usuario_id INT,
    FOREIGN KEY (rol_cuenta)          REFERENCES rol_cuentas(id),
    FOREIGN KEY (correo_usuarios_id)  REFERENCES correo_usuarios(id),
    FOREIGN KEY (telefono_usuario_id) REFERENCES telefono_usuarios(id)
);

-- =========================================
-- TABLA ARTISTAS
-- =========================================

CREATE TABLE artistas (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100),
    nombre_artistico    VARCHAR(100),
    activo              BOOLEAN,
    biografia           TEXT,
    correo_artista_id   INT,
    telefono_artista_id INT,
    pais_de_origen_id   INT,
    tipo_id             INT,
    FOREIGN KEY (correo_artista_id)   REFERENCES correo_artistas(id),
    FOREIGN KEY (telefono_artista_id) REFERENCES telefono_artistas(id),
    FOREIGN KEY (pais_de_origen_id)   REFERENCES paises(id),
    FOREIGN KEY (tipo_id)             REFERENCES tipos_artista(id)
);

-- =========================================
-- TABLA ARTISTA_GENERO
-- =========================================

CREATE TABLE artista_genero (
    id         SERIAL PRIMARY KEY,
    genero_id  INT,
    artista_id INT,
    FOREIGN KEY (genero_id)  REFERENCES generos(id),
    FOREIGN KEY (artista_id) REFERENCES artistas(id)
);
