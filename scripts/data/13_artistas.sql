-- =========================================
-- INSERTS: artistas
-- pais_de_origen_id: 1=Guatemala, 2=Mexico, 3=Colombia...
-- tipo_id: 1=Solista, 2=Banda, 3=Duo, 4=DJ, 5=Colectivo
-- =========================================

INSERT INTO artistas (nombre, nombre_artistico, activo, biografia, correo_artista_id, telefono_artista_id, pais_de_origen_id, tipo_id) VALUES
('Roberto Silva',       'Sonic Wave',        TRUE,  'Banda de rock alternativo formada en Guatemala en 2010. Con 3 albumes publicados.',                  1,  1,  1, 2),
('Maria Luna',          'Luna Sound',        TRUE,  'Cantante solista de indie pop originaria de la Ciudad de Guatemala.',                                 2,  2,  1, 1),
('Kevin Castro',        'Neon Pulse',        TRUE,  'DJ de musica electronica con residencias en los mejores clubes de Centroamerica.',                   3,  3,  2, 4),
('Las Brisas GT',       'Las Brisas',        TRUE,  'Agrupacion de cumbia y marimba que fusiona ritmos tradicionales guatemaltecos con pop moderno.',     4,  4,  1, 2),
('Marco Salas',         'DJ Matrix',         TRUE,  'DJ y productor musical con mas de 10 anos de experiencia en festivales internacionales.',             5,  5,  3, 4),
('Ritmo Negro Band',    'Ritmo Negro',        TRUE,  'Banda de salsa y jazz tropical fundada en 2015 en Ciudad de Mexico.',                                6,  6,  2, 2),
('Echo Collective',     'Echo Collective',   FALSE, 'Colectivo de musica experimental que mezcla electronica con instrumentos acusticos.',                7,  7,  6, 5),
('Daniel Vega',         'Solstice',          TRUE,  'Banda de metal progresivo con influencias latinas y europeas.',                                      8,  8,  4, 2),
('Victor Mendez',       'Vertex DJ',         TRUE,  'DJ de house y techno radicado en Colombia con mas de 200 presentaciones en vivo.',                   9,  9,  3, 4),
('La Cumbia Maquina',   'La Cumbia Maquina', TRUE,  'Agrupacion de cumbia electronica que combina sintetizadores con percusion tradicional.',             10, 10, 1, 2),
('Crater Band',         'Crater',            TRUE,  'Banda de indie rock guatemalteca con influencias de los anos 90.',                                   11, 11, 1, 2),
('Puente Sonoro',       'Puente Sonoro',     TRUE,  'Duo acustico de folk latinoamericano con letras poeticas y profundas.',                              12, 12, 5, 3),
('Luna Cheia',          'Luna Cheia',        TRUE,  'Artista de MPB y bossa nova originaria de Brasil con presencia internacional.',                      13, 13, 7, 1),
('Alex Storm',          'DJ Storm',          TRUE,  'DJ guatemalteco especializado en EDM y trap electronico.',                                           14, 14, 1, 4),
('La Ola Sound',        'La Ola',            TRUE,  'Banda de reggae y ska que promueve mensajes de paz y union.',                                        15, 15, 1, 2);
