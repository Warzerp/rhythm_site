-- =========================================
-- INSERTS: usuarios
-- Columnas segun DDL real (04_usuarios_artistas.sql):
--   correo_usuarios_id (FK correo_usuarios), foto_perfil
-- rol_cuenta: 1=usuario, 2=Organizador, 3=artista, 4=venues
-- =========================================

INSERT INTO usuarios (nombre, apellido, nick, contrasena, activo, fecha_nacimiento, foto_perfil, rol_cuenta, correo_usuarios_id, telefono_usuario_id) VALUES
('Carlos',     'Mendez',    'carlosmx',   'hash_pass_01', TRUE,  '1995-03-12', 'pfp/carlos.jpg',    1,  1,  1),
('Sofia',      'Ruiz',      'sofiar',     'hash_pass_02', TRUE,  '1998-07-24', 'pfp/sofia.jpg',     1,  2,  2),
('Andres',     'Torres',    'andrestgt',  'hash_pass_03', TRUE,  '1992-11-05', 'pfp/andres.jpg',    1,  3,  3),
('Lucia',      'Garcia',    'luciag',     'hash_pass_04', TRUE,  '2000-01-18', 'pfp/lucia.jpg',     1,  4,  4),
('Miguel',     'Lopez',     'miguelL',    'hash_pass_05', TRUE,  '1997-09-30', 'pfp/miguel.jpg',    1,  5,  5),
('Valeria',    'Martinez',  'valemartin', 'hash_pass_06', TRUE,  '1999-04-15', 'pfp/valeria.jpg',   1,  6,  6),
('Jose',       'Hernandez', 'josehgt',    'hash_pass_07', FALSE, '1994-06-22', 'pfp/jose.jpg',      1,  7,  7),
('Ana',        'Jimenez',   'anajim',     'hash_pass_08', TRUE,  '2001-02-08', 'pfp/ana.jpg',       1,  8,  8),
('Pedro',      'Ramirez',   'pedroram',   'hash_pass_09', TRUE,  '1996-08-14', NULL,                1,  NULL, NULL),
('Isabella',   'Morales',   'bellamor',   'hash_pass_10', TRUE,  '1993-12-01', NULL,                1,  NULL, NULL),
('Diego',      'Castillo',  'diegocast',  'hash_pass_11', TRUE,  '1990-05-17', NULL,                2,  NULL, NULL),
('Camila',     'Vargas',    'camilavar',  'hash_pass_12', TRUE,  '2002-10-09', NULL,                1,  NULL, NULL),
('Fernando',   'Reyes',     'ferreyes',   'hash_pass_13', TRUE,  '1988-03-25', NULL,                2,  NULL, NULL),
('Natalia',    'Diaz',      'natadiaz',   'hash_pass_14', FALSE, '1995-07-11', NULL,                1,  NULL, NULL),
('Roberto',    'Silva',     'robsilva',   'hash_pass_15', TRUE,  '1991-01-29', NULL,                3,  NULL, NULL),
('Paola',      'Mendez',    'paolamen',   'hash_pass_16', TRUE,  '1997-11-03', NULL,                1,  NULL, NULL),
('Julian',     'Perez',     'julianp',    'hash_pass_17', TRUE,  '1989-08-20', NULL,                3,  NULL, NULL),
('Daniela',    'Gomez',     'danigomez',  'hash_pass_18', TRUE,  '2003-04-07', NULL,                1,  NULL, NULL),
('Alejandro',  'Rojas',     'alexrojas',  'hash_pass_19', TRUE,  '1986-09-16', NULL,                2,  NULL, NULL),
('Maria',      'Fuentes',   'mariafuen',  'hash_pass_20', TRUE,  '1998-06-28', NULL,                1,  NULL, NULL);
