#!/bin/sh

set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMPOSE_FILE="$LAB_DIR/compose.yaml"

docker compose -f "$COMPOSE_FILE" exec -T mongodb mongoimport \
  --db=formation_nosql \
  --collection=produits \
  --drop \
  --file=/lab/data/catalogue-produits.jsonl

docker compose -f "$COMPOSE_FILE" exec -T mongodb mongoimport \
  --db=formation_nosql \
  --collection=evenements \
  --drop \
  --file=/lab/data/evenements.jsonl

docker compose -f "$COMPOSE_FILE" exec -T mongodb mongosh \
  --quiet \
  mongodb://localhost:27017/formation_nosql \
  --eval 'JSON.stringify({ produits: db.produits.countDocuments(), evenements: db.evenements.countDocuments() })'
