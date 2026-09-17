#!/bin/sh
# TP « Séparer une table de 5 millions de lignes »
# Exporte les factures de plus de 2 ans (le « froid »), les importe dans l'archive
# MongoDB, puis convertit emise_le en vraie date et indexe.

set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
COMPOSE_FILE="$LAB_DIR/compose.yaml"
EXPORT_FILE="$LAB_DIR/data/generated/factures-froid.jsonl"

mkdir -p "$LAB_DIR/data/generated"

echo "== Export du froid (PostgreSQL) =="
docker compose -f "$COMPOSE_FILE" exec -T postgres \
  psql -U postgres -d facturation -At -c \
  "SELECT row_to_json(f) FROM (SELECT facture_id, client_id, emise_le, montant, statut FROM factures WHERE emise_le < current_date - interval '2 years') f;" \
  > "$EXPORT_FILE"
wc -l "$EXPORT_FILE"

echo
echo "== Import dans l'archive MongoDB =="
docker compose -f "$COMPOSE_FILE" exec -T mongodb \
  mongoimport --db=archive --collection=factures --drop \
  --file=/lab/data/generated/factures-froid.jsonl

echo
echo "== Conversion de emise_le en date et indexation =="
docker compose -f "$COMPOSE_FILE" exec -T mongodb \
  mongosh --quiet mongodb://localhost:27017/archive --eval '
    db.factures.updateMany({}, [{ $set: { emise_le: { $toDate: "$emise_le" } } }]);
    db.factures.createIndex({ client_id: 1, emise_le: 1 });
    JSON.stringify({
      documents: db.factures.countDocuments(),
      somme_montants: db.factures.aggregate([{ $group: { _id: null, total: { $sum: "$montant" } } }]).toArray()[0].total
    })
  '
