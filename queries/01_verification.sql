-- ============================================================
-- 01_verification.sql — Création du schéma & vérifications
-- TP 2 Cassandra — Équipements Sportifs France
-- ============================================================

-- 1. Création du keyspace
CREATE KEYSPACE IF NOT EXISTS db_tp2
    WITH replication = {
        'class': 'SimpleStrategy',
        'replication_factor': 1
    };

USE db_tp2;

-- 2. Création de la table
CREATE TABLE IF NOT EXISTS equipements_sportifs (
    equip_numero        TEXT PRIMARY KEY,
    installation_numero TEXT,
    nom                 TEXT,
    type_equip          TEXT,
    proprietaire_nom    TEXT,
    latitude            DOUBLE,
    longitude           DOUBLE
);

-- 3. Vérification de la structure
DESCRIBE TABLE equipements_sportifs;

-- 4. Vérification du volume de données après ingestion
SELECT COUNT(*) FROM equipements_sportifs;

-- 5. Aperçu des premières lignes
SELECT * FROM equipements_sportifs LIMIT 10;
