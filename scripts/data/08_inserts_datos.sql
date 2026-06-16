-- =========================================
-- SCRIPT 08: INSERTS - DATOS DE PRUEBA
-- (Alineado al backup real de pgAdmin)
-- =========================================

INSERT INTO rol_cuentas (nombre) VALUES
    ('usuario'),
    ('Organizador'),
    ('artista'),
    ('venues');

INSERT INTO clasificaciones (nombre) VALUES
    ('usuario'),
    ('Organizador'),
    ('artista'),
    ('venues');

INSERT INTO tipo_tickets (tipo) VALUES
    ('Basico'),
    ('Plus'),
    ('VIP');

INSERT INTO tipo_evento (nombre) VALUES
    ('Concierto'),
    ('Festival'),
    ('Teatro'),
    ('Stand-up'),
    ('Opera');

INSERT INTO generos (nombre) VALUES
    ('Rock'),
    ('Pop'),
    ('Electronica'),
    ('Hip-Hop'),
    ('Reggaeton'),
    ('Jazz'),
    ('Clasica'),
    ('Metal'),
    ('Salsa'),
    ('Cumbia');

INSERT INTO tipos_artista (nombre) VALUES
    ('Solista'),
    ('Banda'),
    ('DJ'),
    ('Duo'),
    ('Orquesta');

INSERT INTO paises (nombre) VALUES
    ('Colombia'),
    ('Argentina'),
    ('Mexico'),
    ('Espana'),
    ('Estados Unidos'),
    ('Brasil'),
    ('Chile'),
    ('Peru'),
    ('Venezuela'),
    ('Uruguay');

INSERT INTO departamentos (nombre_departamento) VALUES
    ('Cundinamarca'),
    ('Antioquia'),
    ('Valle del Cauca'),
    ('Atlantico'),
    ('Santander');

INSERT INTO municipio (nombre_municipio) VALUES
    ('Bogota D.C.'),
    ('Medellin'),
    ('Cali'),
    ('Barranquilla'),
    ('Bucaramanga');

INSERT INTO ciudad (ciudad_nombre) VALUES
    ('Bogota'),
    ('Medellin'),
    ('Cali'),
    ('Barranquilla'),
    ('Bucaramanga');


INSERT INTO correo_usuarios (correo, clasificacion_id) VALUES
    ('juan.perez@gmail.com', 1),
    ('maria.gomez@hotmail.com', 1),
    ('carlos.rodriguez@gmail.com', 1),
    ('ana.martinez@yahoo.com', 1),
    ('luis.hernandez@gmail.com', 1),
    ('sofia.torres@outlook.com', 1),
    ('pedro.ramirez@gmail.com', 1),
    ('valentina.cruz@gmail.com', 1);

INSERT INTO telefono_usuarios (telefono, clasificacion_id) VALUES
    ('3001234567', 1),
    ('3112345678', 1),
    ('3223456789', 1),
    ('3334567890', 1),
    ('3445678901', 1),
    ('3556789012', 1),
    ('3667890123', 1),
    ('3778901234', 1);

INSERT INTO correo_artistas (correo, clasificacion_id) VALUES
    ('booking@maluma.com', 3),
    ('booking@juanes.com', 3),
    ('contact@shakira.com', 3),
    ('info@carlosvives.com', 3),
    ('booking@j-balvin.com', 3),
    ('management@karolg.com', 3),
    ('contact@andrescaro.com', 3),
    ('info@silviamoreno.com', 3);

INSERT INTO telefono_artistas (telefono, clasificacion_id) VALUES
    ('6041111111', 3),
    ('6042222222', 3),
    ('6043333333', 3),
    ('6044444444', 3),
    ('6045555555', 3),
    ('6046666666', 3),
    ('6047777777', 3),
    ('6048888888', 3);

INSERT INTO correo_organizadores (clasificacion_id, correo_organizador) VALUES
    (2, 'info@ocesa.com.co'),
    (2, 'contacto@movistararena.com'),
    (2, 'eventos@productorandes.co'),
    (2, 'booking@festivalrumba.co');

INSERT INTO telefono_organizadores (telefono, clasificacion_id) VALUES
    ('6017001000', 2),
    ('6017002000', 2),
    ('6017003000', 2),
    ('6017004000', 2);

INSERT INTO direcciones (clasificacion_id, departamento_id, municipio_id, ciudad_id) VALUES
    (2, 1, 1, 1),
    (2, 2, 2, 2),
    (4, 1, 1, 1),
    (4, 2, 2, 2),
    (4, 3, 3, 3),
    (4, 4, 4, 4);

INSERT INTO direcciones_organizador (linea_direccion, direccion_id) VALUES
    ('Cra 7 32-16 Oficina 301', 1),
    ('Calle 10 43E-31 Piso 2', 2);

INSERT INTO direcciones_venues (linea_direccion, direccion_id) VALUES
    ('Autopista Norte Km 1.5', 3),
    ('Calle 29 44-35', 4),
    ('Av. Roosevelt 38-33', 5),
    ('Cra 46 74-39', 6);

INSERT INTO usuarios (nombre, apellido, nick, contrasena, activo, fecha_nacimiento, foto_perfil, rol_cuenta, correo_usuarios_id, telefono_usuario_id) VALUES
    ('Juan',      'Perez',     'juanp',    'hash1', TRUE, '1995-03-15', NULL, 1, 1, 1),
    ('Maria',     'Gomez',     'mariag',   'hash2', TRUE, '1998-07-22', NULL, 1, 2, 2),
    ('Carlos',    'Rodriguez', 'carlosr',  'hash3', TRUE, '1990-11-08', NULL, 1, 3, 3),
    ('Ana',       'Martinez',  'anam',     'hash4', TRUE, '2000-01-30', NULL, 1, 4, 4),
    ('Luis',      'Hernandez', 'luish',    'hash5', TRUE, '1993-06-18', NULL, 1, 5, 5),
    ('Sofia',     'Torres',    'sofiat',   'hash6', TRUE, '1997-09-25', NULL, 1, 6, 6),
    ('Pedro',     'Ramirez',   'pedror',   'hash7', TRUE, '1988-12-03', NULL, 1, 7, 7),
    ('Valentina', 'Cruz',      'valic',    'hash8', TRUE, '2001-04-14', NULL, 1, 8, 8);

INSERT INTO artistas (nombre, nombre_artistico, activo, biografia, correo_artista_id, telefono_artista_id, pais_de_origen_id, tipo_id) VALUES
    ('Juan Luis Londono Arias', 'Maluma',        TRUE, 'Cantante colombiano de reggaeton y pop urbano nacido en Medellin.', 1, 1, 1, 1),
    ('Juan Esteban Aristizabal','Juanes',         TRUE, 'Musico colombiano conocido mundialmente por su fusion de rock y musica latina.', 2, 2, 1, 1),
    ('Shakira Isabel Mebarak',  'Shakira',        TRUE, 'Cantante y compositora barranquillera de fama mundial.', 3, 3, 1, 1),
    ('Carlos Vives',            'Carlos Vives',   TRUE, 'Artista colombiano reconocido por revivir el vallenato con un toque moderno.', 4, 4, 1, 1),
    ('Jose Alvaro Osorio',      'J Balvin',       TRUE, 'Reguetonero colombiano referente del genero urbano global.', 5, 5, 1, 1),
    ('Carolina Giraldo Navarro','Karol G',         TRUE, 'Cantante de reggaeton y trap latino, originaria de Medellin.', 6, 6, 1, 1),
    ('Andres Caro Mesa',        'Andres Caro',    TRUE, 'DJ colombiano con amplia trayectoria en electronica y house music.', 7, 7, 1, 3),
    ('Silvia Moreno',           'Silvia Moreno',  TRUE, 'Soprano colombiana de musica clasica y opera.', 8, 8, 1, 1);

INSERT INTO artista_genero (genero_id, artista_id) VALUES
    (5, 1),
    (2, 1),
    (1, 2),
    (2, 2),
    (2, 3),
    (1, 3),
    (9, 4),
    (5, 5),
    (5, 6),
    (3, 7),
    (7, 8);

INSERT INTO organizadores (nombre, nit, estado, descripcion, sitio_web, correo_organizador_id, telefono_organizador_id, direccion_organizador_id) VALUES
    ('OCESA Colombia',          '900123456-1', 'activo', 'Productora lider de eventos masivos en Colombia.',               'https://www.ocesa.com.co',        1, 1, 1),
    ('Movistar Arena Eventos',  '900234567-2', 'activo', 'Division de eventos del Movistar Arena de Bogota.',              'https://www.movistararena.com',   2, 2, 2),
    ('Productora Los Andes',    '900345678-3', 'activo', 'Empresa de produccion de eventos culturales y musicales.',       'https://www.productorandes.co',   3, 3, NULL),
    ('Festival Rumba Colombia', '900456789-4', 'activo', 'Organizadora del Festival Rumba anual en Colombia.',             'https://www.festivalrumba.co',    4, 4, NULL);

INSERT INTO venues (nombre_venue, direcciones_id) VALUES
    ('El Campin',                  1),
    ('Movistar Arena',             2),
    ('Estadio Pascual Guerrero',   3),
    ('Estadio Metropolitano',      4);

INSERT INTO eventos (nombre, descripcion, fecha_inicio, fecha_fin, estado, es_publico, organizador_id, tipo_evento_id, venue_id) VALUES
    ('Papi Juancho World Tour',    'Gira mundial de Maluma en Colombia.',                       '2025-08-15', '2025-08-15', 'programado', TRUE, 1, 1, 1),
    ('Vida Cotidiana Tour',        'Tour de Juanes celebrando sus 25 anos de carrera.',          '2025-09-20', '2025-09-20', 'programado', TRUE, 2, 1, 2),
    ('Las Mujeres Ya No Lloran',   'Concierto de Shakira en Bogota.',                           '2025-10-05', '2025-10-06', 'programado', TRUE, 2, 1, 2),
    ('Festival Vallenato Moderno', 'Festival con Carlos Vives y artistas invitados.',            '2025-11-01', '2025-11-01', 'programado', TRUE, 3, 2, 3),
    ('Noche Electronica Bogota',   'Noche de electronica con DJ Andres Caro.',                  '2025-07-26', '2025-07-27', 'programado', TRUE, 1, 1, 1);

INSERT INTO evento_artistas (evento_id, artista_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (3, 6),
    (4, 4),
    (5, 7);

INSERT INTO ticket (precio, cantidad, tipo_ticket_id, evento_id) VALUES
    (80000.00,  5000, 1, 1),
    (150000.00,  500, 2, 1),
    (300000.00,  100, 3, 1),
    (90000.00,  3000, 1, 2),
    (200000.00,  200, 3, 2),
    (120000.00, 4000, 1, 3),
    (250000.00,  300, 2, 3),
    (450000.00,   80, 3, 3),
    (60000.00,  8000, 1, 4),
    (70000.00,  2000, 1, 5),
    (150000.00,  150, 3, 5);

INSERT INTO ordenes (cantidad, fecha_compra, estado_pago, usuario_id) VALUES
    (2, '2025-05-10', 'pagado',   1),
    (4, '2025-05-11', 'pagado',   2),
    (2, '2025-05-12', 'pagado',   3),
    (1, '2025-05-13', 'pagado',   4),
    (3, '2025-05-14', 'pagado',   5),
    (2, '2025-05-15', 'pagado',   6),
    (1, '2025-05-16', 'pendiente',7),
    (1, '2025-05-17', 'pagado',   8),
    (2, '2025-05-18', 'pagado',   1),
    (2, '2025-05-19', 'pendiente',2);