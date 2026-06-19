-- =========================================
-- SCRIPT 01: CREAR BASE DE DATOS
-- =========================================

-- Terminar conexiones activas para poder borrarla
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'rhythm_site'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS rhythm_site;

CREATE DATABASE rhythm_site;
