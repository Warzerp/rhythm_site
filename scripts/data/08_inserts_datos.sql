-- =========================================
-- SCRIPT 08: INSERTS - DATOS DE PRUEBA
-- =========================================

INSERT INTO rol_cuentas (nombre) VALUES
    ('usuario'),
    ('organizador'),
    ('artista'),
    ('venues');

INSERT INTO clasificaciones (nombre) VALUES
    ('usuario'),
    ('organizador'),
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

INSERT INTO asientos (asiento) VALUES
    ('A1'), ('A2'), ('A3'), ('A4'), ('A5'),
    ('B1'), ('B2'), ('B3'), ('B4'), ('B5'),
    ('C1'), ('C2'), ('C3'), ('C4'), ('C5'),
    ('VIP-1'), ('VIP-2'), ('VIP-3'), ('VIP-4'), ('VIP-5'),
    ('CAMPO');

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

INSERT INTO telefono_organizadores (clasificacion_id, telefono) VALUES
    (2, '6017001000'),
    (2, '6017002000'),
    (2, '6017003000'),
    (2, '6017004000');

INSERT INTO direcciones (clasificacion_id, departamento_id, municipio_id, ciudad_id) VALUES
    (2, 1, 1, 1),
    (2, 2, 2, 2),
    (4, 1, 1, 1),
    (4, 2, 2, 2),
    (4, 3, 3, 3),
    (4, 4, 4, 4);

INSERT INTO direcciones_organizador (direccion_id, linea_direccion) VALUES
    (1, 'Cra 7 32-16 Oficina 301'),
    (2, 'Calle 10 43E-31 Piso 2');

INSERT INTO direcciones_venues (linea_direccion, direccion_id) VALUES
    ('Autopista Norte Km 1.5', 3),
    ('Calle 29 44-35', 4),
    ('Av. Roosevelt 38-33', 5),
    ('Cra 46 74-39', 6);

INSERT INTO usuarios (nombre, apellido, nick, correo_id, contrasena, rol_cuenta, activo, telefono_usuario_id, fecha_nacimiento, foto_perfil_png) VALUES
    ('Juan', 'Perez', 'juanp', 1, 'hash1', 1, TRUE, 1, '1995-03-15', NULL),
    ('Maria', 'Gomez', 'mariag', 2, 'hash2', 1, TRUE, 2, '1998-07-22', NULL),
    ('Carlos', 'Rodriguez', 'carlosr', 3, 'hash3', 1, TRUE, 3, '1990-11-08', NULL),
    ('Ana', 'Martinez', 'anam', 4, 'hash4', 1, TRUE, 4, '2000-01-30', NULL),
    ('Luis', 'Hernandez', 'luish', 5, 'hash5', 1, TRUE, 5, '1993-06-18', NULL),
    ('Sofia', 'Torres', 'sofiat', 6, 'hash6', 1, TRUE, 6, '1997-09-25', NULL),
    ('Pedro', 'Ramirez', 'pedror', 7, 'hash7', 1, TRUE, 7, '1988-12-03', NULL),
    ('Valentina', 'Cruz', 'valic', 8, 'hash8', 1, TRUE, 8, '2001-04-14', NULL);

INSERT INTO artistas (nombre, nombre_artistico, correo_artista_id, telefono_artista_id, pais_de_origen_id, tipo_id, activo, biografia) VALUES
    ('Juan Luis Londono Arias', 'Maluma', 1, 1, 1, 1, TRUE, 'Cantante colombiano de reggaeton y pop urbano nacido en Medellin.'),
    ('Juan Esteban Aristizabal', 'Juanes', 2, 2, 1, 1, TRUE, 'Musico colombiano conocido mundialmente por su fusion de rock y musica latina.'),
    ('Shakira Isabel Mebarak', 'Shakira', 3, 3, 1, 1, TRUE, 'Cantante y compositora barranquillera de fama mundial.'),
    ('Carlos Vives', 'Carlos Vives', 4, 4, 1, 1, TRUE, 'Artista colombiano reconocido por revivir el vallenato con un toque moderno.'),
    ('Jose Alvaro Osorio', 'J Balvin', 5, 5, 1, 1, TRUE, 'Reguetonero colombiano referente del genero urbano global.'),
    ('Carolina Giraldo Navarro', 'Karol G', 6, 6, 1, 1, TRUE, 'Cantante de reggaeton y trap latino, originaria de Medellin.'),
    ('Andres Caro Mesa', 'Andres Caro', 7, 7, 1, 3, TRUE, 'DJ colombiano con amplia trayectoria en electronica y house music.'),
    ('Silvia Moreno', 'Silvia Moreno', 8, 8, 1, 1, TRUE, 'Soprano colombiana de musica clasica y opera.');

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

INSERT INTO organizadores (nombre, NIT, estado, descripcion, sitio_web, correo_organizador_id, telefono_organizador_id, direccion_organizador_id) VALUES
    ('OCESA Colombia', '900123456-1', 'activo', 'Productora lider de eventos masivos en Colombia.', 'https://www.ocesa.com.co', 1, 1, 1),
    ('Movistar Arena Eventos', '900234567-2', 'activo', 'Division de eventos del Movistar Arena de Bogota.', 'https://www.movistararena.com', 2, 2, 2),
    ('Productora Los Andes', '900345678-3', 'activo', 'Empresa de produccion de eventos culturales y musicales.', 'https://www.productorandes.co', 3, 3, NULL),
    ('Festival Rumba Colombia', '900456789-4', 'activo', 'Organizadora del Festival Rumba anual en Colombia.', 'https://www.festivalrumba.co', 4, 4, NULL);

INSERT INTO venues (nombre_venue, direcciones_id) VALUES
    ('El Campin', 1),
    ('Movistar Arena', 2),
    ('Estadio Pascual Guerrero', 3),
    ('Estadio Metropolitano', 4);

INSERT INTO eventos (nombre, organizador_id, tipo_evento_id, descripcion, fecha_inicio, fecha_fin, estado, es_publico, imagen_url, venue_id) VALUES
    ('Papi Juancho World Tour', 1, 1, 'Gira mundial de Maluma en Colombia.', '2025-08-15 20:00:00', '2025-08-15 23:30:00', 'programado', TRUE, 'https://cdn.rhythmsite.co/maluma2025.jpg', 1),
    ('Vida Cotidiana Tour', 2, 1, 'Tour de Juanes celebrando sus 25 anos de carrera.', '2025-09-20 19:00:00', '2025-09-20 22:30:00', 'programado', TRUE, 'https://cdn.rhythmsite.co/juanes2025.jpg', 2),
    ('Las Mujeres Ya No Lloran', 2, 1, 'Concierto de Shakira en Bogota.', '2025-10-05 21:00:00', '2025-10-06 00:30:00', 'programado', TRUE, 'https://cdn.rhythmsite.co/shakira2025.jpg', 2),
    ('Festival Vallenato Moderno', 3, 2, 'Festival con Carlos Vives y artistas invitados.', '2025-11-01 16:00:00', '2025-11-01 23:00:00', 'programado', TRUE, 'https://cdn.rhythmsite.co/festival2025.jpg', 3),
    ('Noche Electronica Bogota', 1, 1, 'Noche de electronica con DJ Andres Caro.', '2025-07-26 22:00:00', '2025-07-27 04:00:00', 'programado', TRUE, 'https://cdn.rhythmsite.co/electronica2025.jpg', 1);

INSERT INTO evento_artistas (evento_id, artista_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (3, 6),
    (4, 4),
    (5, 7);

INSERT INTO ticket (precio, asiento_id, tipo_ticket_id, cantidad_total, evento_id) VALUES
    (80000.00, 21, 1, 5000, 1),
    (150000.00, 16, 2, 500, 1),
    (300000.00, 17, 3, 100, 1),
    (90000.00, 21, 1, 3000, 2),
    (200000.00, 16, 3, 200, 2),
    (120000.00, 21, 1, 4000, 3),
    (250000.00, 16, 2, 300, 3),
    (450000.00, 17, 3, 80, 3),
    (60000.00, 21, 1, 8000, 4),
    (70000.00, 21, 1, 2000, 5),
    (150000.00, 16, 3, 150, 5);

INSERT INTO ordenes (usuario_id, ticket_id, cantidad_tickets, fecha_compra, estado_pago) VALUES
    (1, 1, 2, '2025-05-10', 'pagado'),
    (2, 6, 4, '2025-05-11', 'pagado'),
    (3, 7, 2, '2025-05-12', 'pagado'),
    (4, 8, 1, '2025-05-13', 'pagado'),
    (5, 4, 3, '2025-05-14', 'pagado'),
    (6, 9, 2, '2025-05-15', 'pagado'),
    (7, 10, 1, '2025-05-16', 'pendiente'),
    (8, 3, 1, '2025-05-17', 'pagado'),
    (1, 5, 2, '2025-05-18', 'pagado'),
    (2, 11, 2, '2025-05-19', 'pendiente');