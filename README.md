# Lab MongoDB de la formation NoSQL

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

Supprimer également le volume de données pour repartir de zéro :

```shell
docker compose down --volumes
```

Cette dernière commande efface les données MongoDB du lab.
