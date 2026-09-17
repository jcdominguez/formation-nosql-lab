> [!abstract] TP - Séparer une table de 5 millions de lignes
> Scénario fictif : sortir une table volumineuse de PostgreSQL, en partie vers MongoDB, pour soulager la sauvegarde et gagner en performance sur les opérations du quotidien.

> [!info] Le 99ᵉ centile (p99)
> Le temps que 99 % des requêtes ne dépassent pas. Sur 1000 requêtes triées de la plus rapide à la plus lente, c'est le temps de la 990ᵉ, les 10 plus lentes étant ignorées. Une moyenne cache les cas rares mais réels : une base qui répond en 2 ms en moyenne mais en 800 ms une fois sur cent laisse un client sur cent attendre presque une seconde. C'est le p99 qu'on surveille en production, pas la moyenne.

# Le scénario

L'entreprise fictive « Gestion & Facturation » fait tourner une application autour d'une base PostgreSQL. La table `factures` porte dix ans d'historique, cinq millions de lignes chez elle en production. Deux symptômes remontent :

- la sauvegarde nocturne (`pg_dump`) prend de plus en plus de temps et de place ;
- les requêtes du quotidien, qui ne portent que sur les derniers mois, traversent une table où la grande majorité des lignes ne bouge plus jamais.

Hypothèse à tester : sortir les factures de plus de deux ans (le **froid**) vers une archive MongoDB, garder les factures récentes (le **chaud**) en PostgreSQL. C'est exactement la démarche du chapitre Migration : identifier l'accès qui ne va plus, remodeler pour l'usage, faire coexister avant de basculer.

> [!warning] Ce que ce TP prouve, et ce qu'il ne prouve pas
> Les chiffres obtenus ici viennent d'un conteneur Docker unique, sur un seul poste, avec des données synthétiques réparties uniformément. Aucune charge concurrente, aucun 99ᵉ centile, aucun matériel de production. Ils montrent **la méthode de mesure**, pas un verdict « MongoDB plus rapide que PostgreSQL ». La section « Ce que la comparaison ne dit pas » revient dessus.

# Avant de commencer

## Ce dont vous avez besoin

Le TP réutilise le lab Docker de la formation, avec un service PostgreSQL en plus, sous le profil `migration`.

```
cd formation-nosql-lab
```

```
docker compose --profile migration up -d --wait postgres
```

```
docker compose up -d --wait mongodb
```

Contrôler que les deux services répondent :

```
docker compose ps
```

Les deux doivent afficher `healthy`.

# Étape 1 - Poser le diagnostic

Avant de toucher une seule ligne, appliquer la grille de diagnostic vue dans le chapitre Migration à la table `factures` :

| Accès | Volume et croissance | Forme des données | Ce qui est lu ensemble | Garantie supposée | Verdict |
|---|---|---|---|---|---|
| Factures de plus de 2 ans | 80 % de la table, ne bouge plus | Stable, normalisée | Rarement, sauf audit ou litige | Conservation légale, pas de transaction active | **Candidat, archive froide** |
| Factures des 2 dernières années | 20 % de la table, lu et écrit en continu | Stable, normalisée | Avec le client courant, pour l'afficher ou facturer | Cohérence avec les paiements en cours | **Reste en PostgreSQL** |

Le verdict n'est pas « migrer toute la table ». C'est « séparer un accès qui ne va plus d'un accès qui va très bien ».

# Étape 2 - Générer la table de départ

Un script SQL génère une table `factures` avec le nombre de lignes demandé, des clients et des dates réparties sur dix ans.

```
docker compose exec -T postgres psql -U postgres -d facturation -v n=500000 -f /lab/scripts/migration/01-generer-factures.sql
```

Résultat attendu (obtenu sur la machine du formateur) :

```
 lignes | somme_montants
--------+----------------
 500000 |  1253018070.10
```

> [!question] Pourquoi 500 000 et pas 5 millions tout de suite ?
> Le script accepte n'importe quel `n`. Sur la machine du formateur, 500 000 lignes se génèrent en environ 1,6 seconde et 5 millions en environ 15 secondes pour 512 Mo sur disque. Faire le premier passage à 500 000 pour ne pas attendre à chaque essai, puis rejouer tout le TP avec `-v n=5000000` une fois le parcours compris.

# Étape 3 - Mesurer l'avant

Un script regroupe les trois mesures : durée et taille de la sauvegarde, plan d'exécution de la requête du quotidien, taille sur disque.

```
./scripts/migration/02-mesurer.sh avant
```

Résultats obtenus (500 000 lignes) :

| Mesure | Résultat |
|---|---|
| Sauvegarde `pg_dump -Fc` | 1,15 s, 6,0 Mo |
| Requête « factures d'un client sur le mois courant » | Index Scan, 0,12 ms |
| Taille sur disque (table + index) | 52 Mo |

> [!info] La requête est déjà rapide
> L'index `(client_id, emise_le)` existe depuis la génération : ce TP ne rejoue pas l'Atelier 5 sur l'indexation, il porte sur la séparation chaud/froid. La requête du quotidien reste rapide avant comme après, parce qu'elle est déjà bien indexée. C'est la **sauvegarde** et la **taille sur disque** que la séparation va changer, pas cette requête.

# Étape 4 - Exporter le froid vers MongoDB

Le script exporte les factures de plus de deux ans en JSON, les importe dans une base `archive` MongoDB, convertit la date et pose un index.

```
./scripts/migration/03-exporter-froid.sh
```

Résultats obtenus :

```
400062 factures-froid.jsonl
400062 document(s) imported successfully.
{"documents":400062,"somme_montants":1002860655.68}
```

400 062 lignes, soit 80 % de la table : cohérent avec dix ans d'historique dont deux ans restent chauds.

# Étape 5 - Vérifier avant de basculer

Ne jamais faire confiance à une copie sans la contrôler. Comparer le compte et la somme des montants des deux côtés :

```
docker compose exec -T postgres psql -U postgres -d facturation -c "SELECT count(*), sum(montant) FROM factures WHERE emise_le < current_date - interval '2 years';"
```

Résultat obtenu :

```
 count  |      sum
--------+---------------
 400062 | 1002860655.68
```

Même compte, même somme que MongoDB à l'étape précédente. C'est cette réconciliation qui autorise à retirer les données de PostgreSQL, pas la seule réussite de l'import.

# Étape 6 - Basculer : retirer le froid de PostgreSQL

```
./scripts/migration/04-purger-froid.sh
```

Ce script fait un `DELETE` puis un `VACUUM FULL`, qui rend vraiment l'espace disque au système. `VACUUM FULL` prend un verrou exclusif sur la table pendant l'opération : acceptable en TP sur une table isolée, à proscrire en production sur une table sollicitée en continu. La solution de production est le **partitionnement natif de PostgreSQL** (`PARTITION BY RANGE (emise_le)`) : détacher une partition entière est immédiat et ne verrouille rien.

Résultat obtenu :

```
lignes_restantes
------------------
            99938
```

# Étape 7 - Mesurer l'après

```
./scripts/migration/02-mesurer.sh apres
```

| Mesure | Avant | Après |
|---|---|---|
| Sauvegarde `pg_dump -Fc` | 1,15 s, 6,0 Mo | 0,32 s, 1,2 Mo |
| Taille sur disque (table + index) | 52 Mo | 10 Mo |
| Requête du quotidien | 0,12 ms | 0,09 ms |

La sauvegarde de production ne disparaît pas, elle change de volume : cinq fois moins de données à sauvegarder chaque nuit. La requête du quotidien ne gagne presque rien ici, parce qu'elle était déjà indexée ; sur une table sans index adapté, l'écart aurait été plus net.

# Étape 8 - Sauvegarder l'archive et interroger le froid

L'archive a sa propre sauvegarde, séparée et plus rare :

```
docker compose exec -T mongodb mongodump --db=archive --archive=/tmp/archive.mongodump
```

```
docker compose cp mongodb:/tmp/archive.mongodump ./data/generated/archive.mongodump
```

Résultat obtenu : 0,5 s, 41 Mo pour 400 062 documents.

Retrouver « les factures d'un client sur une année » dans l'archive, sans puis avec index, comme à l'Atelier 5 :

```
docker compose exec -T mongodb mongosh --quiet mongodb://localhost:27017/archive --eval 'db.factures.dropIndex({ client_id: 1, emise_le: 1 }); printjson(db.factures.find({ client_id: 42, emise_le: { $gte: new Date("2020-01-01"), $lt: new Date("2021-01-01") } }).explain("executionStats").executionStats)'
```

```
docker compose exec -T mongodb mongosh --quiet mongodb://localhost:27017/archive --eval 'db.factures.createIndex({ client_id: 1, emise_le: 1 }); printjson(db.factures.find({ client_id: 42, emise_le: { $gte: new Date("2020-01-01"), $lt: new Date("2021-01-01") } }).explain("executionStats").executionStats)'
```

Résultats obtenus :

| | Sans index | Avec index |
|---|---|---|
| Étage | COLLSCAN | FETCH (IXSCAN) |
| Documents examinés | 400 062 | 10 |
| Documents retournés | 10 | 10 |
| Temps d'exécution | 98 ms | 2 ms |

Même résultat, chemin totalement différent : un index sur l'archive reste indispensable, exactement comme sur une table PostgreSQL.

# Ce que la comparaison ne dit pas

**Ce que la séparation coûte au code .NET.** L'application doit maintenant interroger deux bases : PostgreSQL pour le chaud, MongoDB pour le froid. Plus de jointure unique entre les deux : un écran qui affiche l'historique complet d'un client fait deux requêtes et fusionne côté application. Le retour arrière, si l'archive ne convient pas, consiste à réimporter le froid dans PostgreSQL. La règle de conservation légale des factures (durée de conservation, format probant) reste à vérifier avant d'effacer quoi que ce soit d'un système de production réel.

**Ce qu'un vrai protocole de mesure exigerait**, au-delà de ce TP : une charge concurrente plutôt qu'une seule requête isolée, une mesure en 99ᵉ centile plutôt qu'un temps unique, des données de production plutôt qu'une distribution uniforme, une durée d'observation assez longue pour que les compactions et le cache du système d'exploitation ne faussent pas le résultat. C'est exactement le protocole que la section « Et les performances ? Quelques benchmarks » du Guide décrit avec YCSB.

**Les alternatives que ce même protocole permettrait de comparer**, avant de conclure que MongoDB est le bon choix pour l'archive : le partitionnement natif PostgreSQL évoqué à l'étape 6, ou une seconde base PostgreSQL dédiée à l'archive. Aucune des trois n'est meilleure dans l'absolu, chacune se mesure avec le même protocole.

# Pour aller plus loin

- Rejouer le TP avec `-v n=5000000` : sur la machine du formateur, la génération prend environ 15 secondes et la table complète 512 Mo. Comparer l'écart de sauvegarde et de taille sur ce volume, plus proche de la question initiale.
- Lire la démarche complète de bascule progressive (chargement initial, double écriture, réconciliation continue, bascule des lectures puis des écritures) : elle s'applique à ce scénario si l'application ne peut pas s'arrêter le temps de la séparation.
- Comparer avec le partitionnement natif de PostgreSQL, qui résout le même problème de sauvegarde et de taille sans sortir de moteur relationnel.

# Remise à zéro

```
docker compose exec -T postgres psql -U postgres -d facturation -c "DROP TABLE IF EXISTS factures;"
```

```
docker compose exec -T mongodb mongosh --quiet mongodb://localhost:27017/archive --eval 'db.dropDatabase()'
```

```
docker compose --profile migration down
```

Repartir de l'étape 2 rejoue tout le TP depuis une base vide.
