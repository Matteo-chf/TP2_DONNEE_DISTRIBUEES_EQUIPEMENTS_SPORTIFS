-- ============================================================
-- 03_requetes_metier.sql — 5 Requêtes Métier documentées
-- TP 2 Cassandra — Équipements Sportifs France
-- ============================================================

USE db_tp2;

-- -------------------------------------------------------
-- REQ-01 : Consultation d'un équipement par identifiant
-- -------------------------------------------------------
-- Besoin métier : Un agent administratif consulte la fiche
-- complète d'un équipement à partir de son identifiant unique.
-- Clé utilisée : equip_numero (PRIMARY KEY) → accès O(1)

SELECT *
FROM equipements_sportifs
WHERE equip_numero = 'E001I232420001';


-- -------------------------------------------------------
-- REQ-02 : Équipements d'un propriétaire donné
-- -------------------------------------------------------
-- Besoin métier : Une mairie souhaite inventorier tous les
-- équipements sportifs dont elle est propriétaire.
-- ⚠ ALLOW FILTERING car proprietaire_nom n'est pas clé.

SELECT equip_numero, nom, type_equip, proprietaire_nom, latitude, longitude
FROM equipements_sportifs
WHERE proprietaire_nom = 'Mairie de Tocane'
ALLOW FILTERING;


-- -------------------------------------------------------
-- REQ-03 : Filtrage par type d'infrastructure
-- -------------------------------------------------------
-- Besoin métier : Un citoyen recherche tous les courts de
-- tennis disponibles dans le référentiel national.
-- ⚠ ALLOW FILTERING car type_equip n'est pas clé.

SELECT equip_numero, nom, type_equip, proprietaire_nom
FROM equipements_sportifs
WHERE type_equip = 'Court de tennis'
ALLOW FILTERING;


-- -------------------------------------------------------
-- REQ-04 : Volume total des équipements recensés
-- -------------------------------------------------------
-- Besoin métier : Rapport statistique sur le nombre total
-- d'équipements sportifs présents dans la base.
-- ⚠ Full scan — usage ponctuel uniquement.

SELECT COUNT(*)
FROM equipements_sportifs;


-- -------------------------------------------------------
-- REQ-05 : Mise à jour du propriétaire d'un équipement
-- -------------------------------------------------------
-- Besoin métier : Suite à un transfert administratif,
-- une intercommunalité reprend la gestion d'un équipement.
-- Clé utilisée : equip_numero (PRIMARY KEY) → écriture O(1)

UPDATE equipements_sportifs
SET proprietaire_nom = 'Communauté de Communes Hérault'
WHERE equip_numero = 'E001I232420001';

-- Vérification
SELECT equip_numero, nom, proprietaire_nom
FROM equipements_sportifs
WHERE equip_numero = 'E001I232420001';
