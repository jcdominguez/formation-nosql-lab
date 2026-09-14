-- Format des données Cassandra : le même fil rouge, vu par un moteur en colonnes larges.
-- Ce fichier se lit ; il ne s'exécute pas pendant la formation (pas de conteneur Cassandra
-- dans le lab, voir le Guide). La syntaxe est CQL, proche de SQL en apparence.

-- 1. Un keyspace = l'équivalent d'une base. On y déclare la stratégie de réplication.
CREATE KEYSPACE boutique
  WITH replication = { 'class': 'NetworkTopologyStrategy', 'dc1': 3 };

USE boutique;

-- 2. La table est conçue à partir de LA requête qu'elle doit servir :
--    « tous les événements d'un client, du plus récent au plus ancien ».
--    client_id  = clé de partition : décide sur quel nœud vivent les lignes
--    occurred_at, event_id = colonnes de clustering : ordre des lignes dans la partition
CREATE TABLE events_by_client (
  client_id    text,
  occurred_at  timestamp,
  event_id     text,
  event_type   text,
  session_id   text,
  product_id   text,
  channel      text,
  payload      map<text, text>,
  PRIMARY KEY ((client_id), occurred_at, event_id)
) WITH CLUSTERING ORDER BY (occurred_at DESC, event_id ASC);

-- 3. Les écritures : une ligne par événement, la partition regroupe le client.
INSERT INTO events_by_client (client_id, occurred_at, event_id, event_type, session_id, product_id, channel, payload)
VALUES ('C042', '2026-09-12T09:58:10Z', 'E000181', 'product_viewed',  'S0184', 'P101', 'mobile', {});
INSERT INTO events_by_client (client_id, occurred_at, event_id, event_type, session_id, product_id, channel, payload)
VALUES ('C042', '2026-09-12T10:00:42Z', 'E000182', 'product_viewed',  'S0184', 'P103', 'mobile', {});
INSERT INTO events_by_client (client_id, occurred_at, event_id, event_type, session_id, product_id, channel, payload)
VALUES ('C042', '2026-09-12T10:02:15Z', 'E000183', 'cart_item_added', 'S0184', 'P103', 'mobile', {'quantity': '1'});
INSERT INTO events_by_client (client_id, occurred_at, event_id, event_type, session_id, product_id, channel, payload)
VALUES ('C042', '2026-09-12T10:03:21Z', 'E000184', 'cart_abandoned',  'S0184', 'P103', 'mobile', {});

-- 4. La requête pour laquelle la table existe : rapide, elle lit UNE partition.
SELECT occurred_at, event_type, product_id
FROM events_by_client
WHERE client_id = 'C042';

-- 5. La requête que la table NE sait PAS servir : filtrer sur une colonne
--    qui n'est pas dans la clé. Cassandra refuse, sauf à forcer un parcours complet.
-- SELECT * FROM events_by_client WHERE product_id = 'P103';
-- → InvalidRequest: Cannot execute this query as it might involve data filtering
--   and thus may have unpredictable performance. If you want to execute this query
--   despite the performance unpredictability, use ALLOW FILTERING

-- 6. La réponse Cassandra : une seconde table, dénormalisée, pour cette autre requête.
CREATE TABLE events_by_product (
  product_id   text,
  occurred_at  timestamp,
  event_id     text,
  client_id    text,
  event_type   text,
  PRIMARY KEY ((product_id), occurred_at, event_id)
) WITH CLUSTERING ORDER BY (occurred_at DESC, event_id ASC);
