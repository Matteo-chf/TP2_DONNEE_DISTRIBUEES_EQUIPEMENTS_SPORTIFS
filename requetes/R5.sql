USE db_tp2;

-- REQ-05 : Mettre à jour le nom du propriétaire d'un équipement
-- Cas d'usage : correction administrative après transfert de propriété
-- UPDATE en Cassandra est efficace : ciblage direct par clé de partition
UPDATE equipements_sportifs
SET proprietaire_nom = 'Communauté de Communes Hérault'
WHERE equip_numero = 'E001I232420001';

-- Vérification de la modification
SELECT equip_numero, nom, proprietaire_nom
FROM equipements_sportifs
WHERE equip_numero = 'E001I232420001';
