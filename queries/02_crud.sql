-- ============================================================
-- 02_crud.sql — Opérations CRUD de base
-- TP 2 Cassandra — Équipements Sportifs France
-- ============================================================

USE db_tp2;

-- -------------------------------------------------------
-- CREATE — Insertion manuelle d'un équipement de test
-- -------------------------------------------------------
INSERT INTO equipements_sportifs (
    equip_numero,
    installation_numero,
    nom,
    type_equip,
    proprietaire_nom,
    latitude,
    longitude
) VALUES (
    'E999TEST001',
    'I999TEST001',
    'Stade Municipal Test',
    'Terrain de football',
    'Mairie de Test',
    48.8566,
    2.3522
);

-- -------------------------------------------------------
-- READ — Consultation de l'équipement inséré
-- -------------------------------------------------------
SELECT *
FROM equipements_sportifs
WHERE equip_numero = 'E999TEST001';

-- -------------------------------------------------------
-- UPDATE — Modification du propriétaire
-- -------------------------------------------------------
UPDATE equipements_sportifs
SET proprietaire_nom = 'Communauté de Communes Test'
WHERE equip_numero = 'E999TEST001';

-- Vérification de la mise à jour
SELECT equip_numero, nom, proprietaire_nom
FROM equipements_sportifs
WHERE equip_numero = 'E999TEST001';

-- -------------------------------------------------------
-- DELETE — Suppression de l'équipement de test
-- -------------------------------------------------------
DELETE FROM equipements_sportifs
WHERE equip_numero = 'E999TEST001';

-- Vérification de la suppression (doit retourner 0 ligne)
SELECT * FROM equipements_sportifs
WHERE equip_numero = 'E999TEST001';
