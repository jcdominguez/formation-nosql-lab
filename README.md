# Lab MongoDB de la formation NoSQL

## Supports de formation

- [Guide participant en ligne](https://jcdominguez.github.io/formation-nosql-lab/GUIDE.html)
- [Guide participant en Markdown](GUIDE.md)
- [Quiz interactif en ligne](https://jcdominguez.github.io/formation-nosql-lab/quiz-nosql.html)
- [Cours MongoDB pas à pas en ligne](https://jcdominguez.github.io/formation-nosql-lab/COURS-MONGODB.html)
- [Cours MongoDB pas à pas en Markdown](COURS-MONGODB.md)

Après téléchargement ou clonage du dépôt, ouvrir `GUIDE.html`, `quiz-nosql.html` et `COURS-MONGODB.html` dans un navigateur pour les utiliser hors connexion. Le deck PDF est distribué séparément.

Ce dossier sert à valider localement le contenu MongoDB du cours. Il ne préjuge pas de l'environnement qui sera retenu pour les stagiaires.

## Périmètre actuel

- un serveur MongoDB Community accessible uniquement depuis la machine locale ;
- un volume Docker persistant ;
- un petit catalogue lisible pendant les démonstrations ;
- des événements synthétiques cohérents avec le fil rouge du cours.

L'image est fixée sur MongoDB Community `7.0.40-ubuntu2204`. L'image MongoDB 8 correspondant au tag `latest` ne démarre pas avec le noyau Linux récent de la version de Docker Desktop testée le 30 août 2026. Son script d'entrée bloque ce démarrage à cause d'une incompatibilité connue de l'allocateur `tcmalloc` avec les noyaux Linux 6.19 et ultérieurs.

Au moment du test, le même script d'entrée bloque également l'image MongoDB 7 alors que le binaire embarqué est bien `mongod` 7.0.40. La configuration Compose lance donc directement ce binaire avec `--bind_ip_all`. Ce choix désactive les fonctions d'initialisation portées par le script d'entrée de l'image. Le lab n'utilise pour l'instant ni authentification ni scripts placés dans `/docker-entrypoint-initdb.d`.

## Démarrage

Démarrer Docker Desktop, puis exécuter depuis ce dossier :

```shell
docker compose up -d
```

Contrôler l'état du service :

```shell
docker compose ps
```

Le service est prêt pour les exercices quand son état est `healthy`. Le contrôle de santé exécute un véritable `ping` MongoDB, pas seulement un contrôle du processus Docker.

Consulter les journaux si le service ne démarre pas :

```shell
docker compose logs mongodb
```

La chaîne de connexion locale est :

```text
mongodb://localhost:27017
```

## Données

- `data/catalogue-produits.jsonl` : produits aux attributs variables ;
- `data/evenements.jsonl` : parcours synthétiques de consultation, panier, achat et abandon.

Le conteneur fournit `mongoimport` et `mongosh`. Charger ou réinitialiser les deux collections avec :

```shell
./scripts/load-data.sh
```

Le script recrée les collections `formation_nosql.produits` et `formation_nosql.evenements`, puis affiche leur nombre de documents.

Ouvrir ensuite un shell MongoDB dans le conteneur :

```shell
docker compose exec mongodb mongosh mongodb://localhost:27017/formation_nosql
```

## Exercices

### 01 - Premiers documents

- Énoncé : `exercices/01-premiers-documents/README.md`
- Solution : `solutions/01-premiers-documents.js`

Exécuter la solution vérifiée :

```shell
docker compose exec -T mongodb mongosh --quiet mongodb://localhost:27017 --file /lab/solutions/01-premiers-documents.js
```

### 02 - Requêtes et mises à jour

- Énoncé : `exercices/02-requetes-et-mises-a-jour/README.md`
- Solution : `solutions/02-requetes-et-mises-a-jour.js`

Réinitialiser les données avant l'exercice :

```shell
./scripts/load-data.sh
```

Exécuter la solution vérifiée :

```shell
docker compose exec -T mongodb mongosh --quiet mongodb://localhost:27017 --file /lab/solutions/02-requetes-et-mises-a-jour.js
```

### 03 - Indexation

- Énoncé : `exercices/03-indexation/README.md`
- Solution : `solutions/03-indexation.js`

Exécuter la solution vérifiée :

```shell
docker compose exec -T mongodb mongosh --quiet mongodb://localhost:27017 --file /lab/solutions/03-indexation.js
```

La solution supprime l'index de l'exercice à la fin afin de laisser le lab dans son état initial.

### 04 - Import d'un export SGBDR

- Énoncé et corrigé : Guide participant, section « Importation de données des SGBDR au format JSON »
- Fichiers : `data/export-sgbdr/`, procédure dans `exercices/04-import-json/README.md`

### 05 - Replica set

- Énoncé et corrigé : Guide participant, section « Répliquer les données »
- Procédure : `exercices/05-replica-set/README.md`, fichier `compose.replica.yaml` indépendant du lab principal

## Cours MongoDB pas à pas

Cours pour découvrir MongoDB depuis zéro, en 14 modules et 108 étapes, calqué sur la [roadmap MongoDB de roadmap.sh](https://roadmap.sh/mongodb). Chaque étape suit le même format : objectif, explication, commande à copier-coller, résultat attendu, complément.

L'environnement : les premiers modules s'exécutent sur le serveur `mongodb` par défaut. Six services optionnels, chacun sous son propre profil Compose, servent aux modules sur les transactions, le partitionnement, la sécurité, TLS et les pilotes.

- `scripts/init-rs.sh` : nœud replica set (transactions, réplication) ;
- `scripts/init-sharding.sh` : mini-cluster à deux shards (partitionnement, le plus lourd, quatre conteneurs) ;
- `scripts/init-auth.sh` : serveur avec authentification ;
- `docker compose --profile tls up -d --build mongodb-tls` : serveur en TLS obligatoire, certificat auto-signé ;
- `docker compose --profile driver run --rm driver` : pilote Python `pymongo` et chiffrement côté client.

Les scripts d'initialisation sont idempotents. Les données des serveurs optionnels vivent dans des volumes séparés : elles ne sont pas concernées par `scripts/load-data.sh`.

## Scénario migration - Séparer une table de 5 millions de lignes

TP complémentaire, hors plan de cours : séparer une table PostgreSQL en chaud (récent) et froid (archive), le froid partant vers MongoDB. Démarche complète, énoncé et corrigé chiffré : [TP-MIGRATION-5M.md](TP-MIGRATION-5M.md) / [TP-MIGRATION-5M.html](https://jcdominguez.github.io/formation-nosql-lab/TP-MIGRATION-5M.html).

Démarrer le service PostgreSQL dédié, sous son propre profil :

```shell
docker compose --profile migration up -d --wait postgres
```

Scripts, dans l'ordre du TP :

- `scripts/migration/01-generer-factures.sql` : génère la table `factures` (nombre de lignes en paramètre `-v n=500000`)
- `scripts/migration/02-mesurer.sh <avant|apres>` : sauvegarde, requête du quotidien, taille sur disque
- `scripts/migration/03-exporter-froid.sh` : export du froid, import et indexation dans l'archive MongoDB
- `scripts/migration/04-purger-froid.sh` : retrait du froid de PostgreSQL

## Autres fichiers ajoutés pour le Guide

- `data/formats/` : quatre échantillons (log web, IoT, HTML, CSV) pour l'atelier « quatre formats face au relationnel »
- `data/messages-applicatifs.jsonl` : messages de plusieurs applications, atelier « intégration de données au format JSON »
- `demos/cassandra-format.cql` : format Cassandra du fil rouge, à lire (aucun conteneur Cassandra dans le lab)
- service `redis`, profil Compose `familles` : `docker compose --profile familles up -d --wait redis`

## Arrêt et remise à zéro

Arrêter le serveur en conservant les données :

```shell
docker compose down
```

Cette commande arrête **tous** les services du projet, y compris les profils qui tournent. Pour n'arrêter qu'un service sans toucher aux autres :

```shell
docker compose stop nom_du_service
```

Supprimer également le volume de données pour repartir de zéro :

```shell
docker compose down --volumes
```

Cette dernière commande efface les données MongoDB du lab.
