USE db_tp2;

-- REQ-02 : Trouver tous les équipements d'un propriétaire donné
-- Cas d'usage : un département veut lister tous ses équipements
-- ⚠ ALLOW FILTERING nécessaire car proprietaire_nom n'est pas une clé
SELECT equip_numero, nom, type_equip, proprietaire_nom, latitude, longitude
FROM equipements_sportifs
WHERE proprietaire_nom = 'Mairie de Tocane'
ALLOW FILTERING;
