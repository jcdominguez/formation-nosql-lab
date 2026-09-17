#!/bin/sh
# TP « Séparer une table de 5 millions de lignes »
# Retire le froid de PostgreSQL, maintenant qu'il vit dans l'archive MongoDB.
# VACUUM FULL prend un verrou exclusif sur la table : acceptable en TP, pas en
# production, où on préférerait détacher une partition (voir le guide).

set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
COMPOSE_FILE="$LAB_DIR/compose.yaml"

docker compose -f "$COMPOSE_FILE" exec -T postgres \
  psql -U postgres -d facturation -c \
  "DELETE FROM factures WHERE emise_le < current_date - interval '2 years';"

docker compose -f "$COMPOSE_FILE" exec -T postgres \
  psql -U postgres -d facturation -c \
  "VACUUM FULL ANALYZE factures;"

docker compose -f "$COMPOSE_FILE" exec -T postgres \
  psql -U postgres -d facturation -c \
  "SELECT count(*) AS lignes_restantes FROM factures;"
