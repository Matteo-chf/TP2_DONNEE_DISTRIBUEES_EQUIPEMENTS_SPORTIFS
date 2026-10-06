USE db_tp2;

-- REQ-01 : Récupérer toutes les informations d'un équipement par son numéro unique
-- Requête la plus efficace en Cassandra : accès direct par clé de partition (O(1))
SELECT *
FROM equipements_sportifs
WHERE equip_numero = 'E001I232420001';
