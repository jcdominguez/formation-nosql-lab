#!/bin/sh

# Démarre le noeud unique en replica set et l'initialise.
# Idempotent : relancer le script ne réinitialise rien.
#
# Usage : sh scripts/init-rs.sh
# Arrêt   : docker compose --profile rs down
# Effacer les données : docker compose --profile rs down -v

set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMPOSE="docker compose -f $LAB_DIR/compose.yaml --profile rs"

echo "1/2  Démarrage du noeud replica set"
$COMPOSE up -d --wait mongodb-rs

echo "2/2  Initialisation du replica set"
$COMPOSE exec -T mongodb-rs mongosh --quiet --eval '
try { rs.status().ok } catch (e) { rs.initiate({ _id: "rs0", members: [ { _id: 0, host: "127.0.0.1:27017" } ] }).ok }
printjson(rs.status().members.map((m) => ({ name: m.name, state: m.stateStr })));
'
