-- =========================================
-- INSERTS: usuarios
-- Columnas segun DDL real (04_usuarios_artistas.sql):
--   correo_id (FK correo_usuarios), foto_perfil_png
-- rol_cuenta: 1=usuario, 2=Organizador, 3=artista, 4=venues
-- =========================================

INSERT INTO usuarios (nombre, apellido, nick, correo_id, contrasena, rol_cuenta, activo, telefono_usuario_id, fecha_nacimiento, foto_perfil_png) VALUES
('Carlos',     'Mendez',    'carlosmx',   1,  'hash_pass_01', 1, TRUE,  1,  '1995-03-12', 'pfp/carlos.jpg'),
('Sofia',      'Ruiz',      'sofiar',     2,  'hash_pass_02', 1, TRUE,  2,  '1998-07-24', 'pfp/sofia.jpg'),
('Andres',     'Torres',    'andrestgt',  3,  'hash_pass_03', 1, TRUE,  3,  '1992-11-05', 'pfp/andres.jpg'),
('Lucia',      'Garcia',    'luciag',     4,  'hash_pass_04', 1, TRUE,  4,  '2000-01-18', 'pfp/lucia.jpg'),
('Miguel',     'Lopez',     'miguelL',    5,  'hash_pass_05', 1, TRUE,  5,  '1997-09-30', 'pfp/miguel.jpg'),
('Valeria',    'Martinez',  'valemartin', 6,  'hash_pass_06', 1, TRUE,  6,  '1999-04-15', 'pfp/valeria.jpg'),
('Jose',       'Hernandez', 'josehgt',    7,  'hash_pass_07', 1, FALSE, 7,  '1994-06-22', 'pfp/jose.jpg'),
('Ana',        'Jimenez',   'anajim',     8,  'hash_pass_08', 1, TRUE,  8,  '2001-02-08', 'pfp/ana.jpg'),
('Pedro',      'Ramirez',   'pedroram',   9,  'hash_pass_09', 1, TRUE,  9,  '1996-08-14', 'pfp/pedro.jpg'),
('Isabella',   'Morales',   'bellamor',   10, 'hash_pass_10', 1, TRUE,  10, '1993-12-01', 'pfp/isabella.jpg'),
('Diego',      'Castillo',  'diegocast',  11, 'hash_pass_11', 2, TRUE,  11, '1990-05-17', 'pfp/diego.jpg'),
('Camila',     'Vargas',    'camilavar',  12, 'hash_pass_12', 1, TRUE,  12, '2002-10-09', 'pfp/camila.jpg'),
('Fernando',   'Reyes',     'ferreyes',   13, 'hash_pass_13', 2, TRUE,  13, '1988-03-25', 'pfp/fernando.jpg'),
('Natalia',    'Diaz',      'natadiaz',   14, 'hash_pass_14', 1, FALSE, 14, '1995-07-11', 'pfp/natalia.jpg'),
('Roberto',    'Silva',     'robsilva',   15, 'hash_pass_15', 3, TRUE,  15, '1991-01-29', 'pfp/roberto.jpg'),
('Paola',      'Mendez',    'paolamen',   16, 'hash_pass_16', 1, TRUE,  16, '1997-11-03', 'pfp/paola.jpg'),
('Julian',     'Perez',     'julianp',    17, 'hash_pass_17', 3, TRUE,  17, '1989-08-20', 'pfp/julian.jpg'),
('Daniela',    'Gomez',     'danigomez',  18, 'hash_pass_18', 1, TRUE,  18, '2003-04-07', 'pfp/daniela.jpg'),
('Alejandro',  'Rojas',     'alexrojas',  19, 'hash_pass_19', 2, TRUE,  19, '1986-09-16', 'pfp/alejandro.jpg'),
('Maria',      'Fuentes',   'mariafuen',  20, 'hash_pass_20', 1, TRUE,  20, '1998-06-28', 'pfp/maria.jpg');
