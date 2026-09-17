-- TP « Séparer une table de 5 millions de lignes »
-- Génère la table facturation.factures, 10 ans d'historique, N lignes.
-- Nombre de lignes fourni par la variable psql -v n=500000 (obligatoire).

\if :{?n}
\else
  \echo 'Variable n manquante. Lancer avec : psql ... -v n=500000'
  \quit
\endif

DROP TABLE IF EXISTS factures;

CREATE TABLE factures (
    facture_id  bigint PRIMARY KEY,
    client_id   integer NOT NULL,
    emise_le    date NOT NULL,
    montant     numeric(10, 2) NOT NULL,
    statut      text NOT NULL
);

INSERT INTO factures (facture_id, client_id, emise_le, montant, statut)
SELECT
    s AS facture_id,
    1 + floor(random() * 5000)::int AS client_id,
    (current_date - (floor(random() * 3650))::int) AS emise_le,
    round((10 + random() * 4990)::numeric, 2) AS montant,
    (ARRAY['payee', 'en_attente', 'annulee'])[1 + floor(random() * 3)::int] AS statut
FROM generate_series(1, :n) AS s;

CREATE INDEX idx_factures_client_date ON factures (client_id, emise_le);

ANALYZE factures;

SELECT count(*) AS lignes, sum(montant) AS somme_montants FROM factures;
