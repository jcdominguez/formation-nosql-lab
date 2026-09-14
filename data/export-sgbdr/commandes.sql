-- Extrait de la base relationnelle de la boutique (PostgreSQL).
-- Trois tables normalisées : une commande, ses lignes, le client.
CREATE TABLE clients   (client_id VARCHAR(10) PRIMARY KEY, email VARCHAR(100), ville VARCHAR(50));
CREATE TABLE commandes (order_id VARCHAR(10) PRIMARY KEY, client_id VARCHAR(10) REFERENCES clients, ordered_at TIMESTAMP, statut VARCHAR(20));
CREATE TABLE lignes    (order_id VARCHAR(10) REFERENCES commandes, product_id VARCHAR(10), name VARCHAR(100), qty INT, unit_price NUMERIC(10,2), PRIMARY KEY (order_id, product_id));

INSERT INTO clients VALUES ('C117', 'c117@example.com', 'Lyon'), ('C205', 'c205@example.com', 'Nantes');
INSERT INTO commandes VALUES ('O5001', 'C117', '2026-09-12 10:17:11', 'payee'), ('O5002', 'C205', '2026-09-12 10:31:02', 'payee');
INSERT INTO lignes VALUES ('O5001', 'P101', 'Horizon X100', 1, 749.00), ('O5002', 'P105', 'Transit 24', 1, 89.00), ('O5002', 'P108', 'Altitude Brésil', 2, 10.90);

-- La requête d'export : une commande par ligne, ses lignes et son client imbriqués.
-- Le SGBDR fait la jointure une dernière fois ; le JSON produit est déjà un document.
SELECT json_build_object(
  'order_id',   c.order_id,
  'ordered_at', c.ordered_at,
  'statut',     c.statut,
  'client',     json_build_object('client_id', cl.client_id, 'email', cl.email, 'ville', cl.ville),
  'lignes',     (SELECT json_agg(json_build_object('product_id', l.product_id, 'name', l.name, 'qty', l.qty, 'unit_price', l.unit_price))
                 FROM lignes l WHERE l.order_id = c.order_id)
)
FROM commandes c JOIN clients cl ON cl.client_id = c.client_id;
