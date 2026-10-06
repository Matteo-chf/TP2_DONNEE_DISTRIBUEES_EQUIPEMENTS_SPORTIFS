-- ============================================================
-- SCHEMA CASSANDRA — Équipements Sportifs (data.gouv.fr)
-- API  : https://equipements.sports.gouv.fr/api/explore/v2.1/
--         catalog/datasets/data-es-equipement/records
-- Total: ~334 473 équipements en France
-- ============================================================

-- 1. Création du keyspace dédié
CREATE KEYSPACE IF NOT EXISTS db_tp2
    WITH replication = {
        'class': 'SimpleStrategy',
        'replication_factor': 1
    };

USE db_tp2;

-- 2. Création de la table principale
--
-- Clé de partition : equip_numero (TEXT)
--   → identifiant unique de l'équipement (ex: "E001I342550017")
--   → permet une recherche directe en O(1) sans ALLOW FILTERING
--
CREATE TABLE IF NOT EXISTS equipements_sportifs (
    equip_numero        TEXT PRIMARY KEY,   -- ex: E001I342550017
    installation_numero TEXT,               -- ex: I342550017
    nom                 TEXT,               -- ex: Plateau d'EPS
    type_equip          TEXT,               -- ex: Multisports/City-stades
    proprietaire_nom    TEXT,               -- ex: Commune de Saint-Genies
    latitude            DOUBLE,             -- coordonnée GPS
    longitude           DOUBLE              -- coordonnée GPS
);
