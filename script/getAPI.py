import requests
from cassandra.cluster import Cluster
from cassandra import ConsistencyLevel

# ============================================================
# Script d'ingestion — Équipements Sportifs France
# API : https://equipements.sports.gouv.fr
# Dataset : data-es-equipement (~334 473 enregistrements)
# Table : db_tp2.equipements_sportifs (7 colonnes)
# ============================================================

# ----------------------------------------------------------
# 1. Connexion à Cassandra
# ----------------------------------------------------------
print("Connexion à Cassandra...")
cluster = Cluster(['127.0.0.1'], port=9042)
session = cluster.connect('db_tp2')
print("Connecté au keyspace db_tp2.")

# ----------------------------------------------------------
# 2. Paramètres de l'API
# ----------------------------------------------------------
BASE_URL = (
    "https://equipements.sports.gouv.fr/api/explore/v2.1"
    "/catalog/datasets/data-es-equipement/records"
)
LIMIT = 100        # résultats par page (max 100)
MAX_RECORDS = 500  # mettre None pour tout importer

# ----------------------------------------------------------
# 3. Requête CQL préparée — alignée sur les 7 colonnes de la table
# ----------------------------------------------------------
insert_query = session.prepare("""
    INSERT INTO equipements_sportifs (
        equip_numero,
        installation_numero,
        nom,
        type_equip,
        proprietaire_nom,
        latitude,
        longitude
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
""")
insert_query.consistency_level = ConsistencyLevel.ONE

# ----------------------------------------------------------
# 4. Boucle de pagination et insertion
# ----------------------------------------------------------
offset = 0
total_inserted = 0

print(f"\nDébut de l'ingestion (LIMIT={LIMIT}, MAX={MAX_RECORDS or 'ALL'})...\n")

while True:
    if MAX_RECORDS and total_inserted >= MAX_RECORDS:
        break

    params = {"limit": LIMIT, "offset": offset}
    response = requests.get(BASE_URL, params=params, timeout=30)
    response.raise_for_status()
    data = response.json()

    results = data.get("results", [])
    if not results:
        print("Plus de données disponibles.")
        break

    for item in results:
        if MAX_RECORDS and total_inserted >= MAX_RECORDS:
            break

        # Extraction des champs
        equip_numero        = str(item.get("numero") or "")
        installation_numero = item.get("installation_numero")
        nom                 = item.get("nom")
        type_equip          = item.get("type")
        proprietaire_nom    = item.get("proprietaire_principal_nom")

        coordonnees = item.get("coordonnees") or {}
        latitude    = coordonnees.get("lat")
        longitude   = coordonnees.get("lon")

        # Insertion dans Cassandra
        session.execute(insert_query, (
            equip_numero,
            installation_numero,
            nom,
            type_equip,
            proprietaire_nom,
            latitude,
            longitude,
        ))

        total_inserted += 1
        print(f"  [{total_inserted}] {equip_numero} — {nom}")

    offset += LIMIT

# ----------------------------------------------------------
# 5. Fin
# ----------------------------------------------------------
print(f"\n✅ Import terminé : {total_inserted} équipements insérés dans Cassandra.")
cluster.shutdown()
