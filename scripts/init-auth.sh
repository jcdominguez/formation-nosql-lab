#!/bin/sh

# Démarre le serveur en authentification et crée l'administrateur.
# Le premier utilisateur est créé grâce à l'exception localhost : tant qu'aucun
# utilisateur n'existe, mongod accepte une création depuis la machine locale.
#
# Usage : sh scripts/init-auth.sh
# Arrêt   : docker compose --profile auth down
# Effacer les comptes : docker compose --profile auth down -v

set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMPOSE="docker compose -f $LAB_DIR/compose.yaml --profile auth"

echo "1/2  Démarrage du serveur en authentification"
$COMPOSE up -d --wait mongodb-auth

echo "2/2  Création de l'administrateur"
$COMPOSE exec -T mongodb-auth mongosh --quiet --eval '
const admin = db.getSiblingDB("admin");
try {
  admin.createUser({ user: "admin", pwd: "Change3Moi!", roles: ["root"] });
  print("administrateur créé");
} catch (e) {
  if (e.code === 11000 || e.codeName === "DuplicateKey" || e.codeName === "Unauthorized") {
    print("administrateur déjà présent");
  } else {
    throw e;
  }
}
'
