# TP 2 — Exploitation des Données avec Apache Cassandra

## Sujet

Gestion et interrogation d'une base de données distribuée pour des **infrastructures sportives françaises**.  
L'objectif est d'ingérer des données géolocalisées depuis une API publique, de les stocker dans Cassandra, et de répondre à des besoins métier via des requêtes CQL.

---

## API

| Champ | Valeur |
|---|---|
| **Source** | Ministère des Sports / data.gouv.fr |
| **Dataset** | `data-es-equipement` |
| **URL** | `https://equipements.sports.gouv.fr/api/explore/v2.1/catalog/datasets/data-es-equipement/records` |
| **Volume** | ~334 473 équipements recensés en France |
| **Authentification** | Aucune (API publique) |

---

## Données

L'API recense l'ensemble des équipements sportifs de France : terrains, gymnases, piscines, stades, courts, circuits…  
Chaque enregistrement contient un identifiant unique, un nom, un type, les coordonnées GPS et le propriétaire.

**Champs retenus pour Cassandra :**

| Colonne | Type | Description |
|---|---|---|
| `equip_numero` | `TEXT PRIMARY KEY` | Identifiant unique (ex: `E001I232420001`) |
| `installation_numero` | `TEXT` | Identifiant de l'installation parente |
| `nom` | `TEXT` | Nom de l'équipement |
| `type_equip` | `TEXT` | Type (Court de tennis, Terrain de football…) |
| `proprietaire_nom` | `TEXT` | Nom du propriétaire (commune, département…) |
| `latitude` | `DOUBLE` | Coordonnée GPS |
| `longitude` | `DOUBLE` | Coordonnée GPS |

---

## Modèle Cassandra

- **Keyspace :** `db_tp2` (SimpleStrategy, replication_factor = 1)
- **Table :** `equipements_sportifs`
- **Clé de partition :** `equip_numero`
  - Identifiant universel et unique → distribution homogène des données
  - Permet un accès direct O(1) par équipement
- **Clé de clustering :** aucune (1 ligne = 1 équipement, pas de tri intra-partition nécessaire)

---

## Requêtes Métier

| Requête | Besoin | Performance |
|---|---|---|
| REQ-01 | Fiche complète d'un équipement par ID | ⚡ O(1) — clé de partition |
| REQ-02 | Équipements d'un propriétaire donné | ⚠ ALLOW FILTERING |
| REQ-03 | Équipements par type d'infrastructure | ⚠ ALLOW FILTERING |
| REQ-04 | Volume total des équipements | ⚠ Full scan (COUNT) |
| REQ-05 | Mise à jour du propriétaire | ⚡ O(1) — clé de partition |

---

## Arborescence

```
TP-Sports-Equipements/
│
├── README.md
│
├── schema.cql                      ← Création keyspace + table
│
├── script/
│   └── getAPI.py                   ← Ingestion Python (API → Cassandra)
│
├── queries/
│   ├── 01_verification.sql         ← Schéma, DESCRIBE, COUNT, aperçu
│   ├── 02_crud.sql                 ← INSERT / SELECT / UPDATE / DELETE
│   └── 03_requetes_metier.sql      ← REQ-01 à REQ-05 documentées
│
└── documentation/
    └── modelisation.md             ← Modèle Cassandra + 5 besoins métier détaillés
```

---

## Lancer le projet

```bash
# 1. Appliquer le schéma dans Cassandra
docker exec -it cassandra cqlsh
# → coller le contenu de schema.cql

# 2. Ingérer les données
python3 script/getAPI.py

# 3. Tester les requêtes
docker exec -it cassandra cqlsh
# → USE db_tp2; puis coller les fichiers queries/
```
