# Documentation — Modélisation & Requêtes Métier
## TP 2 : Exploitation des Données avec Apache Cassandra
### API : Équipements Sportifs — Ministère des Sports (data.gouv.fr)

---

# 4. Requêtes Métier

---

## REQ-01

**Besoin métier :**
Récupérer toutes les informations d'un équipement sportif à partir de son identifiant unique. Cas d'usage : un agent administratif consulte la fiche complète d'un équipement donné.

**Requête CQL :**
```cql
SELECT *
FROM db_tp2.equipements_sportifs
WHERE equip_numero = 'E001I232420001';
```

**Clé de partition utilisée :** `equip_numero`

**Justification :**
`equip_numero` est la clé de partition (PRIMARY KEY). Cassandra accède directement à la partition sans scan. C'est la requête la plus performante possible : accès O(1), aucun `ALLOW FILTERING` requis.

---

## REQ-02

**Besoin métier :**
Lister tous les équipements sportifs appartenant à un propriétaire donné (commune, département, association). Cas d'usage : une mairie souhaite inventorier tous ses équipements.

**Requête CQL :**
```cql
SELECT equip_numero, nom, type_equip, proprietaire_nom, latitude, longitude
FROM db_tp2.equipements_sportifs
WHERE proprietaire_nom = 'Mairie de Tocane'
ALLOW FILTERING;
```

**Clé de partition utilisée :** aucune (filtrage sur colonne non-clé)

**Justification :**
`proprietaire_nom` n'est pas une clé de partition dans ce modèle. Le filtre nécessite donc `ALLOW FILTERING`, ce qui implique un scan complet. Acceptable dans un contexte de TP ou pour de faibles volumes. En production, on créerait une table secondaire avec `proprietaire_nom` comme clé de partition.

---

## REQ-03

**Besoin métier :**
Filtrer les équipements par type d'infrastructure pour identifier la disponibilité d'un type précis sur le territoire. Cas d'usage : un citoyen cherche tous les courts de tennis disponibles.

**Requête CQL :**
```cql
SELECT equip_numero, nom, type_equip, proprietaire_nom
FROM db_tp2.equipements_sportifs
WHERE type_equip = 'Court de tennis'
ALLOW FILTERING;
```

**Clé de partition utilisée :** aucune (filtrage sur colonne non-clé)

**Justification :**
`type_equip` n'est pas une clé de partition. Le `ALLOW FILTERING` est nécessaire. Pour optimiser cette requête en production, il faudrait une table dédiée avec `type_equip` comme clé de partition et `equip_numero` comme clé de clustering.

---

## REQ-04

**Besoin métier :**
Connaître le nombre total d'équipements sportifs recensés dans la base de données. Cas d'usage : rapport statistique ou vérification de l'ingestion des données.

**Requête CQL :**
```cql
SELECT COUNT(*)
FROM db_tp2.equipements_sportifs;
```

**Clé de partition utilisée :** aucune (agrégation globale)

**Justification :**
`COUNT(*)` effectue un scan complet de la table (full scan). Cassandra génère un avertissement car cette opération ignore les clés de partition. Utilisée uniquement pour les vérifications ou bilans, jamais en chemin critique d'une application.

---

## REQ-05

**Besoin métier :**
Mettre à jour le propriétaire d'un équipement suite à un transfert administratif. Cas d'usage : une intercommunalité reprend la gestion d'un équipement communal.

**Requête CQL :**
```cql
UPDATE db_tp2.equipements_sportifs
SET proprietaire_nom = 'Communauté de Communes Hérault'
WHERE equip_numero = 'E001I232420001';

-- Vérification
SELECT equip_numero, nom, proprietaire_nom
FROM db_tp2.equipements_sportifs
WHERE equip_numero = 'E001I232420001';
```

**Clé de partition utilisée :** `equip_numero`

**Justification :**
La mise à jour cible directement la clé de partition. Cassandra exécute cette opération en O(1) sans scan, ce qui en fait une opération d'écriture très efficace, cohérente avec le paradigme Cassandra.

---

# 5. Modélisation Cassandra

## Choix de la clé de partition

La clé de partition choisie est **`equip_numero`** (identifiant unique de l'équipement, ex : `E001I232420001`).

**Raisons :**
- Chaque équipement possède un identifiant **universel et unique** dans le référentiel national du Ministère des Sports.
- Il garantit une **distribution homogène** des données entre les nœuds Cassandra (pas de hot spot).
- Il permet un **accès direct O(1)** à n'importe quel enregistrement sans scan (REQ-01, REQ-05).

## Clé de clustering — Nécessaire ou non ?

Dans ce modèle, **aucune clé de clustering n'est définie**, car :
- Chaque partition correspond à **un seul équipement** (relation 1:1 entre `equip_numero` et la ligne).
- Il n'y a pas de besoin de trier des données **au sein** d'une même partition.
- Les requêtes de filtrage (REQ-02, REQ-03) portent sur des attributs différents, qui nécessiteraient des tables séparées plutôt qu'une clé de clustering.

> En production, on pourrait imaginer une table `equipements_par_type` avec `type_equip` comme partition key et `equip_numero` comme clustering key, pour éviter le `ALLOW FILTERING` de REQ-03.

## Comment le modèle répond aux requêtes métier

| Requête | Performance | Mécanisme |
|---|---|---|
| REQ-01 (SELECT par id) | ⚡ Optimale | Accès direct par clé de partition |
| REQ-02 (filtre propriétaire) | ⚠ Acceptable | `ALLOW FILTERING` — scan complet |
| REQ-03 (filtre type) | ⚠ Acceptable | `ALLOW FILTERING` — scan complet |
| REQ-04 (COUNT) | ⚠ Coûteux | Full scan — usage ponctuel uniquement |
| REQ-05 (UPDATE) | ⚡ Optimale | Écriture directe par clé de partition |

> **Rappel Cassandra :** on conçoit les tables **en fonction des requêtes**, pas l'inverse. Si REQ-02 et REQ-03 devaient être critiques en production, on créerait des tables dédiées avec les colonnes de filtrage comme clés de partition.
