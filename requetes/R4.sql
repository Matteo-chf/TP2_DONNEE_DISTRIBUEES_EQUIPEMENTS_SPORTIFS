USE db_tp2;

-- REQ-04 : Obtenir le volume total d'équipements sportifs recensés
-- ⚠ Avertissement Cassandra : COUNT(*) effectue un scan complet (full scan)
-- À utiliser avec précaution sur de grands volumes en production
SELECT COUNT(*)
FROM equipements_sportifs;
