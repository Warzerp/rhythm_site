-- =========================================
-- INSERTS: eventos
-- fecha_inicio / fecha_fin -> DATE (segun backup real)
-- organizador_id: 1-10 | tipo_evento_id: 1-5 | venue_id: 1-4
-- =========================================

INSERT INTO eventos (nombre, descripcion, fecha_inicio, fecha_fin, estado, es_publico, organizador_id, tipo_evento_id, venue_id) VALUES
('Noche de Rock GT 2025',        'La mejor noche de rock guatemalteco con bandas locales e internacionales.',           '2025-08-15', '2025-08-16', 'programado', TRUE,  1,  1, 1),
('Festival Centroamerica Unida', 'Gran festival multigenero con artistas de toda la region centroamericana.',           '2025-09-20', '2025-09-22', 'programado', TRUE,  2,  2, 2),
('Club Night Electronica Vol.5', 'Noche de musica electronica con los mejores DJs del pais.',                          '2025-07-05', '2025-07-06', 'finalizado', TRUE,  3,  3, NULL),
('Showcase Artistas Nuevos',     'Plataforma para nuevos artistas guatemaltecos.',                                     '2025-06-10', '2025-06-10', 'finalizado', TRUE,  4,  4, NULL),
('Open Air Antigua 2025',        'Festival al aire libre en el corazon de La Antigua Guatemala.',                     '2025-10-04', '2025-10-05', 'programado', TRUE,  1,  2, NULL),
('Tributo a Los Beatles',        'Noche de tributo al legendario cuarteto de Liverpool con artistas locales.',         '2025-11-15', '2025-11-15', 'programado', TRUE,  2,  1, NULL),
('Festival Andino 2025',         'Decimocuarta edicion del festival anual de musica andina y latinoamericana.',        '2025-08-29', '2025-08-31', 'programado', TRUE,  3,  2, NULL),
('Noche Unplugged Acustico',     'Una noche magica de musica acustica e intima en el Teatro Nacional.',                '2025-07-19', '2025-07-19', 'finalizado', FALSE, 4,  3, NULL),
('Tour Nacional Ritmo Vivo',     'Primera fecha del tour nacional por las principales ciudades del pais.',             '2025-09-01', '2025-09-01', 'programado', TRUE,  1,  3, NULL),
('Club Privado Sessions Vol.2',  'Sesiones privadas de musica electronica en Club Privado 21.',                        '2025-08-02', '2025-08-03', 'finalizado', FALSE, 2,  3, NULL),
('Concierto Homenaje Marimba',   'Gran concierto de marimba y musica tradicional guatemalteca.',                      '2025-11-01', '2025-11-01', 'programado', TRUE,  3,  1, NULL),
('Reggae y Ska Fest',            'Festival de reggae y ska con artistas nacionales e internacionales.',                '2025-10-18', '2025-10-19', 'programado', TRUE,  2,  2, NULL),
('Noche Jazz Capital',           'Velada de jazz en vivo con musicos invitados internacionales.',                     '2025-09-12', '2025-09-12', 'programado', TRUE,  4,  1, NULL),
('Hip-Hop Underground GT',       'Show de hip-hop underground con MCs y beatmakers guatemaltecos.',                   '2025-07-26', '2025-07-27', 'finalizado', TRUE,  1,  4, NULL),
('Festival Zona Viva Summer',    'Gran festival de verano en la Zona Viva de la ciudad.',                             '2025-06-28', '2025-06-29', 'finalizado', TRUE,  2,  2, NULL),
('Cumbia Night Especial',        'Una noche de cumbia y baile con las mejores agrupaciones del genero.',              '2025-08-23', '2025-08-24', 'programado', TRUE,  1,  1, NULL),
('Metal Fest Guatemala',         'Festival de metal con bandas locales e internacionales.',                           '2025-11-22', '2025-11-23', 'programado', TRUE,  3,  2, NULL),
('Indie Pop Showcase',           'Showcase de artistas de indie y pop alternativo.',                                  '2025-09-06', '2025-09-06', 'programado', TRUE,  4,  4, NULL),
('Latin Beats Open Air',         'Festival al aire libre de ritmos latinos con artistas de toda la region.',          '2025-10-25', '2025-10-26', 'programado', TRUE,  1,  2, NULL),
('Noche de Gala Musical',        'Gala musical de fin de ano con los mejores artistas del 2025.',                    '2025-12-20', '2025-12-21', 'programado', TRUE,  2,  1, NULL);
