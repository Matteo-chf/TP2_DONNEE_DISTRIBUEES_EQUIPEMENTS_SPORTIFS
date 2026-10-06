USE db_tp2;

-- REQ-03 : Filtrer les équipements par type d'infrastructure
-- Cas d'usage : lister tous les courts de tennis disponibles
-- ⚠ ALLOW FILTERING nécessaire car type_equip n'est pas une clé
SELECT equip_numero, nom, type_equip, proprietaire_nom
FROM equipements_sportifs
WHERE type_equip = 'Court de tennis'
ALLOW FILTERING;
