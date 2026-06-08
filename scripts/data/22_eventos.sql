-- =========================================
-- INSERTS: eventos
-- fecha_inicio / fecha_fin -> TIMESTAMP (segun DDL real)
-- organizador_id: 1-10 | tipo_evento_id: 1-8 | venue_id: 1-10
-- =========================================

INSERT INTO eventos (nombre, organizador_id, tipo_evento_id, descripcion, fecha_inicio, fecha_fin, estado, es_publico, imagen_url, venue_id) VALUES
('Noche de Rock GT 2025',        1,  1, 'La mejor noche de rock guatemalteco con bandas locales e internacionales.',           '2025-08-15 20:00:00', '2025-08-16 01:00:00', 'programado', TRUE,  'img/noche_rock.jpg',        1),
('Festival Centroamerica Unida', 2,  2, 'Gran festival multigenero con artistas de toda la region centroamericana.',           '2025-09-20 15:00:00', '2025-09-22 23:59:00', 'programado', TRUE,  'img/festival_ca.jpg',       2),
('Club Night Electronica Vol.5', 3,  3, 'Noche de musica electronica con los mejores DJs del pais.',                          '2025-07-05 22:00:00', '2025-07-06 04:00:00', 'finalizado', TRUE,  'img/club_night.jpg',        6),
('Showcase Artistas Nuevos',     4,  4, 'Plataforma para nuevos artistas guatemaltecos.',                                     '2025-06-10 18:00:00', '2025-06-10 23:00:00', 'finalizado', TRUE,  'img/showcase.jpg',          4),
('Open Air Antigua 2025',        5,  5, 'Festival al aire libre en el corazon de La Antigua Guatemala.',                     '2025-10-04 14:00:00', '2025-10-05 22:00:00', 'programado', TRUE,  'img/open_air.jpg',          3),
('Tributo a Los Beatles',        6,  6, 'Noche de tributo al legendario cuarteto de Liverpool con artistas locales.',         '2025-11-15 19:30:00', '2025-11-15 23:30:00', 'programado', TRUE,  'img/beatles_tributo.jpg',   7),
('Festival Andino 2025',         10, 2, 'Decimocuarta edicion del festival anual de musica andina y latinoamericana.',        '2025-08-29 12:00:00', '2025-08-31 23:59:00', 'programado', TRUE,  'img/festival_andino.jpg',   1),
('Noche Unplugged Acustico',     4,  7, 'Una noche magica de musica acustica e intima en el Teatro Nacional.',                '2025-07-19 20:00:00', '2025-07-19 23:00:00', 'finalizado', FALSE, 'img/unplugged.jpg',         7),
('Tour Nacional Ritmo Vivo',     5,  8, 'Primera fecha del tour nacional por las principales ciudades del pais.',             '2025-09-01 20:00:00', '2025-09-01 23:30:00', 'programado', TRUE,  'img/tour_nacional.jpg',     5),
('Club Privado Sessions Vol.2',  7,  3, 'Sesiones privadas de musica electronica en Club Privado 21.',                        '2025-08-02 22:00:00', '2025-08-03 04:00:00', 'finalizado', FALSE, 'img/privado_sessions.jpg',  6),
('Concierto Homenaje Marimba',   4,  1, 'Gran concierto de marimba y musica tradicional guatemalteca.',                      '2025-11-01 18:00:00', '2025-11-01 22:00:00', 'programado', TRUE,  'img/marimba_homenaje.jpg',  7),
('Reggae y Ska Fest',            2,  2, 'Festival de reggae y ska con artistas nacionales e internacionales.',                '2025-10-18 14:00:00', '2025-10-19 23:00:00', 'programado', TRUE,  'img/reggae_ska.jpg',        5),
('Noche Jazz Capital',           8,  1, 'Velada de jazz en vivo con musicos invitados internacionales.',                     '2025-09-12 20:00:00', '2025-09-12 23:30:00', 'programado', TRUE,  'img/jazz_capital.jpg',      8),
('Hip-Hop Underground GT',       3,  4, 'Show de hip-hop underground con MCs y beatmakers guatemaltecos.',                   '2025-07-26 21:00:00', '2025-07-27 02:00:00', 'finalizado', TRUE,  'img/hiphop_underground.jpg',10),
('Festival Zona Viva Summer',    8,  2, 'Gran festival de verano en la Zona Viva de la ciudad.',                             '2025-06-28 14:00:00', '2025-06-29 23:59:00', 'finalizado', TRUE,  'img/zonaviva_summer.jpg',   8),
('Cumbia Night Especial',        1,  1, 'Una noche de cumbia y baile con las mejores agrupaciones del genero.',              '2025-08-23 20:00:00', '2025-08-24 00:30:00', 'programado', TRUE,  'img/cumbia_night.jpg',      4),
('Metal Fest Guatemala',         7,  2, 'Festival de metal con bandas locales e internacionales.',                           '2025-11-22 15:00:00', '2025-11-23 23:59:00', 'programado', TRUE,  'img/metal_fest.jpg',        1),
('Indie Pop Showcase',           9,  4, 'Showcase de artistas de indie y pop alternativo.',                                  '2025-09-06 19:00:00', '2025-09-06 23:00:00', 'programado', TRUE,  'img/indie_pop.jpg',         4),
('Latin Beats Open Air',         6,  5, 'Festival al aire libre de ritmos latinos con artistas de toda la region.',          '2025-10-25 14:00:00', '2025-10-26 22:00:00', 'programado', TRUE,  'img/latin_beats.jpg',       2),
('Noche de Gala Musical',        1,  1, 'Gala musical de fin de ano con los mejores artistas del 2025.',                    '2025-12-20 20:00:00', '2025-12-21 01:00:00', 'programado', TRUE,  'img/gala_musical.jpg',      7);
