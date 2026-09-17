#!/bin/sh
# TP « Séparer une table de 5 millions de lignes »
# Mesure sauvegarde, requête du quotidien et taille sur disque de facturation.factures.
# Usage : ./scripts/migration/02-mesurer.sh <avant|apres>

set -eu

LABEL=${1:?Usage : 02-mesurer.sh <avant|apres>}
LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
COMPOSE_FILE="$LAB_DIR/compose.yaml"
DUMP_DIR="$LAB_DIR/data/generated"
DUMP_FILE="$DUMP_DIR/factures-$LABEL.dump"

mkdir -p "$DUMP_DIR"

echo "== Sauvegarde ($LABEL) =="
time docker compose -f "$COMPOSE_FILE" exec -T postgres \
  pg_dump -U postgres -d facturation -Fc -t factures -f "/lab/data/generated/factures-$LABEL.dump"
ls -lh "$DUMP_FILE"

echo
echo "== Requête du quotidien ($LABEL) : factures d'un client sur le mois courant =="
docker compose -f "$COMPOSE_FILE" exec -T postgres \
  psql -U postgres -d facturation -c \
  "EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM factures WHERE client_id = 42 AND emise_le >= date_trunc('month', current_date);"

echo
echo "== Taille sur disque ($LABEL) : table + index =="
docker compose -f "$COMPOSE_FILE" exec -T postgres \
  psql -U postgres -d facturation -c \
  "SELECT pg_size_pretty(pg_total_relation_size('factures')) AS taille_totale;"
