#!/bin/sh

# Initialise le mini-cluster shardé du lab : deux shards, un serveur de configuration,
# un routeur mongos. Idempotent : relancer le script ne recrée rien.
#
# Usage : sh scripts/init-sharding.sh
# Arrêt   : docker compose --profile cluster down
# Effacement des données : docker compose --profile cluster down -v

set -eu

LAB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMPOSE="docker compose -f $LAB_DIR/compose.yaml --profile cluster"

echo "1/4  Démarrage des serveurs de stockage et de configuration"
$COMPOSE up -d --wait config1 shard1 shard2

echo "2/4  Initialisation des replica sets"
$COMPOSE exec -T config1 mongosh --quiet --port 27019 --eval \
  'try { rs.status().ok } catch (e) { rs.initiate({ _id: "cfgrs", configsvr: true, members: [ { _id: 0, host: "config1:27019" } ] }).ok }' >/dev/null
$COMPOSE exec -T shard1 mongosh --quiet --eval \
  'try { rs.status().ok } catch (e) { rs.initiate({ _id: "shard1rs", members: [ { _id: 0, host: "shard1:27017" } ] }).ok }' >/dev/null
$COMPOSE exec -T shard2 mongosh --quiet --eval \
  'try { rs.status().ok } catch (e) { rs.initiate({ _id: "shard2rs", members: [ { _id: 0, host: "shard2:27017" } ] }).ok }' >/dev/null

echo "3/4  Démarrage du routeur mongos"
$COMPOSE up -d --wait mongos

echo "4/4  Rattachement des shards"
$COMPOSE exec -T mongos mongosh --quiet --eval '
const shards = db.adminCommand({ listShards: 1 }).shards;
if (!shards.some((s) => s._id === "shard1rs")) { sh.addShard("shard1rs/shard1:27017"); }
if (!shards.some((s) => s._id === "shard2rs")) { sh.addShard("shard2rs/shard2:27017"); }
printjson(db.adminCommand({ listShards: 1 }).shards.map((s) => s._id + " -> " + s.host));
'
