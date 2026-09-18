> [!abstract] MongoDB pas à pas
> Cours pratique pour découvrir MongoDB depuis zéro. Aucune installation : le serveur tourne dans Docker, les données sont fournies, le shell est déjà dans le conteneur.
>
> Chaque étape suit toujours le même format : **Objectif**, **Explication**, **Commande à copier-coller**, **Résultat attendu**, **Pour aller plus loin**.
>
> - [Documentation officielle MongoDB](https://www.mongodb.com/docs/manual/)
> - [Roadmap MongoDB de roadmap.sh](https://roadmap.sh/mongodb)
> - [Dépôt du lab](https://github.com/jcdominguez/formation-nosql-lab)

# Comment suivre ce cours

Le cours s'appuie sur le dépôt `formation-nosql-lab`, qui contient trois choses : le `compose.yaml` qui décrit le conteneur MongoDB, les données d'une boutique en ligne (un catalogue de produits et un journal d'événements de navigation), et les scripts de chargement.

Le principe est simple : **vous lancez chaque commande dans l'ordre**, et vous comparez ce que vous obtenez au **Résultat attendu**. Si les deux diffèrent, arrêtez-vous et relisez l'étape : une commande fonctionne presque toujours telle quelle, et une différence signale en général qu'une étape précédente n'a pas été faite.

Trois repères reviennent :

- **Objectif** : ce que l'étape vous fait acquérir. Une phrase.
- **Explication** : le mécanisme, en mots simples, avant la commande.
- **Pour aller plus loin** : le piège à connaître ou le lien vers la documentation officielle.

Deux conventions d'affichage, à ne pas confondre avec des erreurs :

- Les valeurs `_id` affichées dans ce cours (des identifiants techniques) **diffèrent des vôtres**. MongoDB les génère à l'insertion. Chaque fois qu'une sortie contient un `ObjectId('...')`, lisez-le comme « une valeur unique, la vôtre ».
- Sans tri explicite, MongoDB ne garantit **aucun ordre** de restitution. Deux exécutions de la même requête peuvent rendre les documents dans un ordre différent. C'est normal, et le module M5 apprend à maîtriser ce point.

Prérequis : Docker Desktop installé et démarré, un terminal, et un éditeur de texte. Sous Windows, lancez les commandes dans un terminal WSL (Ubuntu), pas dans PowerShell.

# M0 - Prise en main

Ce module installe le poste de travail : démarrer le serveur, charger les données, ouvrir le shell, lire un premier résultat. À la fin, vous savez faire tourner MongoDB sans l'avoir installé.

## Étape 1 - Vérifier que Docker répond

**Objectif** : s'assurer que le moteur de conteneurs est démarré avant de solliciter MongoDB.

**Explication** : MongoDB ne s'installera pas sur votre machine. Il s'exécutera dans un conteneur, c'est-à-dire une petite machine isolée fournie par Docker. La toute première vérification ne concerne donc pas MongoDB, mais Docker lui-même. La commande `docker version` interroge le client et le serveur Docker.

**Commande à copier-coller** :

```
docker version
```

**Résultat attendu** : deux blocs apparaissent, `Client:` puis `Server:`.

```text
Client: Docker Engine - Community
 Version:           29.8.0
 ...
Server: Docker Engine - Community
 Engine:
  Version:          29.8.0
```

**Pour aller plus loin** : si le bloc `Server` est absent, Docker Desktop n'est pas démarré. Ouvrez-le et attendez que son icône soit stable avant de reprendre. Si vous êtes dans une machine virtuelle, Docker Desktop a lui-même besoin d'une virtualisation imbriquée autorisée par l'hébergeur : c'est un réglage d'infrastructure, à signaler sans attendre.

## Étape 2 - Récupérer le lab

**Objectif** : obtenir sur votre poste le dossier de travail complet (conteneur, données, scripts).

**Explication** : tout le matériel du cours vit dans un dépôt Git public. Le clonage crée un dossier local `formation-nosql-lab`.

**Commande à copier-coller** :

```
git clone https://github.com/jcdominguez/formation-nosql-lab.git
```

**Résultat attendu** :

```text
Cloning into 'formation-nosql-lab'...
remote: Enumerating objects: ...
Receiving objects: 100% ...
```

**Pour aller plus loin** : sans Git, le bouton **Code → Download ZIP** de la page GitHub produit la même chose. Décompressez l'archive pour obtenir un dossier qui s'appelle bien `formation-nosql-lab`.

## Étape 3 - Entrer dans le dossier du lab

**Objectif** : se placer à la racine du lab, d'où partent tous les chemins des commandes suivantes.

**Explication** : les commandes Docker Compose lisent le fichier `compose.yaml` du dossier courant. Se tromper de dossier est la cause la plus fréquente d'un message d'erreur incompréhensible.

**Commande à copier-coller** :

```
cd formation-nosql-lab
```

**Résultat attendu** : aucune sortie. Le prompt du terminal change et se termine par `formation-nosql-lab`.

**Pour aller plus loin** : pour vérifier où vous êtes, `pwd` affiche le chemin complet, et `ls` liste le contenu du dossier. Vous devez y voir `compose.yaml`, `data`, `scripts` et `COURS-MONGODB.md`.

## Étape 4 - Démarrer MongoDB

**Objectif** : lancer le serveur MongoDB dans un conteneur, en tâche de fond.

**Explication** : `docker compose up -d` lit le `compose.yaml`, télécharge l'image si elle n'est pas déjà présente, puis démarre le service `mongodb`. L'option `-d` (detached) rend la main immédiatement : le conteneur continue de tourner en arrière-plan.

**Commande à copier-coller** :

```
docker compose up -d
```

**Résultat attendu** :

```text
 Container formation-nosql-lab-mongodb-1  Started
```

Au premier lancement, des lignes de téléchargement précèdent ce message : l'image fait plusieurs centaines de mégaoctets, il faut la laisser finir.

**Pour aller plus loin** : le fichier `compose.yaml` fixe la version de l'image, ici `mongodb-community-server:7.0.40`. Ne la remplacez pas par `latest` : une version figée est la seule façon de retrouver les mêmes résultats d'une session à l'autre.

## Étape 5 - Vérifier que le serveur est prêt

**Objectif** : confirmer que MongoDB est démarré et capable de répondre.

**Explication** : `docker compose ps` liste les services du projet et leur état. Le `compose.yaml` déclare un contrôle de santé qui interroge MongoDB ; tant qu'il n'a pas répondu, l'état reste `starting`.

**Commande à copier-coller** :

```
docker compose ps
```

**Résultat attendu** :

```text
NAME                            SERVICE   STATUS
formation-nosql-lab-mongodb-1   mongodb   Up (healthy)
```

**Pour aller plus loin** : si l'état reste `starting` ou `unhealthy`, `docker compose logs mongodb` affiche les journaux du serveur. Le mot `healthy` est le seul signal qui garantisse que la suite fonctionnera.

## Étape 6 - Charger les données

**Objectif** : remplir la base avec les données du cours (catalogue de produits et journal d'événements).

**Explication** : le script `scripts/load-data.sh` utilise `mongoimport`, un outil fourni dans le conteneur, pour lire deux fichiers JSONL et les écrire dans les collections `produits` et `evenements`. Il les remplace si elles existent déjà, ce qui rend l'opération rejouable.

**Commande à copier-coller** :

```
sh scripts/load-data.sh
```

**Résultat attendu** :

```text
8 document(s) imported successfully. 0 document(s) failed to import.
16 document(s) imported successfully. 0 document(s) failed to import.
{"produits":8,"evenements":16}
```

**Pour aller plus loin** : cette commande est aussi la remise à zéro du cours. Si vous avez modifié les données et souhaitez repartir d'un état propre, relancez-la. Les valeurs `8` et `16` sont le contrat : si vous en obtenez d'autres, le chargement a échoué.

## Étape 7 - Ouvrir le shell MongoDB

**Objectif** : entrer dans `mongosh`, le shell interactif de MongoDB, connecté à la base du cours.

**Explication** : le serveur tourne dans le conteneur, mais l'outil `mongosh` y est également installé. `docker compose exec mongodb` exécute une commande à l'intérieur du conteneur ; ici, il ouvre `mongosh` sur la base `formation_nosql`. La chaîne de connexion `mongodb://localhost:27017/formation_nosql` désigne l'hôte (`localhost`), le port standard de MongoDB (`27017`) et la base (`formation_nosql`).

**Commande à copier-coller** :

```
docker compose exec mongodb mongosh "mongodb://localhost:27017/formation_nosql"
```

**Résultat attendu** : un prompt apparaît, avec le nom de la base.

```text
Current Mongosh Log ID: ...
Using MongoDB:          7.0.40
Using Mongosh:          ...

formation_nosql>
```

**Pour aller plus loin** : à partir de ce prompt, vous n'êtes plus dans le terminal de votre machine mais dans MongoDB. Tout ce qui suit, jusqu'à l'étape 11, se tape à ce prompt, sans préfixe `docker compose`.

## Étape 8 - Lister les bases de données

**Objectif** : voir que MongoDB héberge plusieurs bases indépendantes.

**Explication** : une **base** regroupe des collections. Trois bases système existent toujours : `admin` (administration), `config` (métadonnées internes de la distribution) et `local` (données propres au serveur, jamais répliquées). La vôtre s'y ajoute.

**Commande à copier-coller** :

```javascript
show dbs
```

**Résultat attendu** : `admin`, `config`, `local` et `formation_nosql`.

```text
admin             40.00 KiB
config           244.00 KiB
formation_nosql  200.00 KiB
local             72.00 KiB
```

**Pour aller plus loin** : `show dbs` est un raccourci du shell, pas du JavaScript. Une base créée mais encore vide n'apparaît pas dans cette liste : MongoDB ne matérialise une base qu'au premier document écrit.

## Étape 9 - Choisir la base et lister ses collections

**Objectif** : se placer dans la base du cours et découvrir ses collections.

**Explication** : `use` change la base courante pour la suite de la session. Une **collection** est un groupe de documents, l'équivalent approximatif d'une table en SQL. Ce lab en fournit deux : `produits` et `evenements`.

**Commande à copier-coller** :

```javascript
use formation_nosql
```

**Résultat attendu** :

```text
already on db formation_nosql
```

**Pour aller plus loin** : vous étiez déjà sur cette base, puisque l'étape 7 l'a passée dans la chaîne de connexion. `show collections` liste ensuite les collections de la base courante.

## Étape 10 - Compter les documents

**Objectif** : produire une première lecture chiffrée, sans écrire de requête complexe.

**Explication** : `db` désigne la base courante, `db.produits` la collection `produits`, et `countDocuments()` une méthode qui compte les documents. Ce n'est pas une requête SQL : c'est un appel de méthode JavaScript, et le shell exécute ce que vous tapez comme du code.

**Commande à copier-coller** :

```javascript
db.produits.countDocuments()
```

**Résultat attendu** :

```text
8
```

**Pour aller plus loin** : `db.produits` ne « charge » rien tant qu'une opération n'est pas appelée. Si vous vous trompez dans le nom d'une collection, MongoDB ne renvoie pas d'erreur : il retourne `0`. Un zéro inattendu signifie donc souvent une faute de frappe, pas un manque de données.

## Étape 11 - Quitter le shell

**Objectif** : sortir proprement de `mongosh` et revenir au terminal de la machine.

**Explication** : `exit` ferme la session du shell. Le serveur MongoDB, lui, continue de tourner dans son conteneur : quitter le shell ne l'arrête pas.

**Commande à copier-coller** :

```javascript
exit
```

**Résultat attendu** : le prompt change, vous êtes revenu au terminal de votre machine (le chemin du dossier `formation-nosql-lab` réapparaît).

**Pour aller plus loin** : pour arrêter réellement le serveur, la commande est `docker compose stop`, et pour le supprimer `docker compose down`. Attention : `docker compose down -v` supprime aussi le volume de données, donc le contenu de votre base.

## Étape 12 - Exécuter une commande sans ouvrir le shell

**Objectif** : savoir lancer une requête isolée, sans entrer dans le shell interactif.

**Explication** : `--eval` exécute une expression passée en argument, puis rend la main. C'est la forme utilisée par les scripts d'automatisation. Elle exige la chaîne de connexion complète, sans quoi `mongosh` se connecte à une base `test` vide et renvoie un résultat trompeur.

**Commande à copier-coller** :

```
docker compose exec mongodb mongosh --quiet "mongodb://localhost:27017/formation_nosql" --eval "db.produits.countDocuments()"
```

**Résultat attendu** :

```text
8
```

**Pour aller plus loin** : l'option `--quiet` supprime la bannière de connexion et ne garde que le résultat. Privez cette commande de sa chaîne de connexion et vous obtiendrez `0` : le piège est classique, et le zéro n'est pas une erreur de MongoDB.

# M1 - Les idées fondatrices

Ce module pose le vocabulaire et le modèle mental. Cette poignée d'idées suffit ensuite à lire n'importe quelle requête MongoDB.

## Étape 1 - Un document est un objet JSON

**Objectif** : reconnaître la forme d'une donnée MongoDB.

**Explication** : l'unité de base s'appelle un **document**. C'est un objet, entouré d'accolades, dont les champs ont un nom et une valeur. Contrairement à une ligne de table SQL, un document peut contenir des sous-objets et des tableaux, sans table annexe ni jointure. Ici, le produit `P101` porte un sous-objet `attributes` et un tableau `media`.

**Commande à copier-coller** :

```javascript
db.produits.findOne({ product_id: "P101" })
```

**Résultat attendu** : un document complet, avec son identifiant technique `_id` et ses champs métier.

```text
{
  _id: ObjectId('...'),
  product_id: 'P101',
  category: 'appareil-photo',
  name: 'Horizon X100',
  active: true,
  price: 749,
  attributes: { sensor: 'APS-C', stabilization: true, color: 'noir' },
  media: [ { kind: 'image', path: 'media/P101-front.jpg' } ]
}
```

**Pour aller plus loin** : `findOne` reçoit un filtre entre accolades, ici `{ product_id: "P101" }`. Ce filtre est un document comme un autre : dans MongoDB, on interroge la base avec la même forme que celle qu'on y écrit.

## Étape 2 - Les documents d'une collection n'ont pas tous le même schéma

**Objectif** : comprendre ce que signifie « schéma flexible », et ce qu'il exige en retour.

**Explication** : une **collection** regroupe des documents de même nature, sans leur imposer une liste de champs identique. Le produit `P102` porte un champ `legacy_label` que `P101` n'a pas : c'est une information héritée d'un ancien système, conservée sur un seul document. MongoDB accepte les deux sans rien redéfinir.

**Commande à copier-coller** :

```javascript
db.produits.findOne({ product_id: "P102" })
```

**Résultat attendu** : le document contient `legacy_label: 'compact'`, absent du produit `P101`.

```text
{
  _id: ObjectId('...'),
  product_id: 'P102',
  category: 'appareil-photo',
  name: 'Horizon Mini',
  active: true,
  price: 429,
  legacy_label: 'compact',
  attributes: { sensor: 'Micro 4/3', stabilization: false, color: 'argent' },
  media: [ { kind: 'image', path: 'media/P102-front.jpg' } ]
}
```

**Pour aller plus loin** : « schéma flexible » ne veut pas dire « aucune règle ». La souplesse est structurelle (MongoDB n'exige pas que tous les documents se ressemblent), pas logique : c'est à l'application, ou à un mécanisme du serveur, de faire respecter les règles métier. L'étape suivante montre comment. La flexibilité déplace la responsabilité, elle ne la supprime pas.

## Étape 3 - Le schéma n'est pas interdit : la validation

**Objectif** : imposer des règles sur les documents d'une collection, sans renoncer à la souplesse.

**Explication** : MongoDB ne vérifie rien par défaut, mais il sait **valider**. À la création d'une collection, un validateur `$jsonSchema` décrit les champs obligatoires et leur type. Tout document qui ne respecte pas le schéma est refusé à l'écriture. La souplesse reste : on peut valider seulement certains champs, ou accepter les documents existants par une option de niveau. La responsabilité n'est plus abandonnée à l'application, elle est confiée au serveur.

**Commande à copier-coller** :

```javascript
db.cours_valide.drop(); db.createCollection("cours_valide", { validator: { $jsonSchema: { bsonType: "object", required: ["product_id", "price"], properties: { product_id: { bsonType: "string" }, price: { bsonType: "number", minimum: 0 } } } } })
```

**Résultat attendu** :

```text
{ ok: 1 }
```

**Pour aller plus loin** : un document conforme passe, un document non conforme est refusé.

```javascript
db.cours_valide.insertOne({ product_id: "V1", price: 10 })
```

renvoie `{ acknowledged: true, insertedId: ObjectId('...') }`, tandis que

```javascript
db.cours_valide.insertOne({ product_id: "V2", price: -1 })
```

échoue avec `MongoServerError: Document failed validation`, suivi du détail : quel champ (`price`), quelle règle (`minimum: 0`), quelle valeur (-1). Le message d'erreur **désigne** le problème, ce qui vaut mieux qu'une incohérence découverte trois mois plus tard. Les options `validationLevel` (`strict` ou `moderate`) et `validationAction` (`error` ou `warn`) dosent la sévérité ; `db.getCollectionInfos({ name: "cours_valide" })` relit le validateur en place.

## Étape 4 - Chaque document reçoit un identifiant technique `_id`

**Objectif** : distinguer la clé technique de MongoDB de votre clé métier.

**Explication** : à l'insertion, si vous ne fournissez pas de `_id`, MongoDB en génère un : un `ObjectId`, valeur de 12 octets quasi unique, sans signification métier. Votre identifiant à vous (`product_id`, `event_id`) reste un champ ordinaire, et c'est lui qui porte le sens.

**Commande à copier-coller** :

```javascript
db.produits.findOne({ product_id: "P101" })._id
```

**Résultat attendu** : un `ObjectId`, différent à chaque chargement des données.

```text
ObjectId('6aac0c31b38a5129fca6f9b4')
```

**Pour aller plus loin** : `_id` est unique par collection, et c'est automatiquement l'index principal. Vous pouvez fournir votre propre `_id` à l'insertion, mais l'usage courant est de garder `_id` pour la technique et un autre champ pour le métier. La valeur affichée ici ne sera pas la vôtre : c'est normal.

## Étape 5 - Un même modèle pour tous les objets de la boutique

**Objectif** : retrouver la même structure sur une autre collection.

**Explication** : la collection `evenements` enregistre la navigation des visiteurs. Ses documents ne décrivent pas des produits mais des actions, avec un champ `payload` dont le contenu change selon le type d'événement : `{ quantity: 1 }` pour un achat, `{ phone: "..." }` pour un début de paiement. La structure est identique au catalogue (objet, champs, sous-document), seule la sémantique change.

**Commande à copier-coller** :

```javascript
db.evenements.findOne({ event_id: "E000188" })
```

**Résultat attendu** :

```text
{
  _id: ObjectId('...'),
  event_id: 'E000188',
  occurred_at: '2026-09-12T10:17:11Z',
  event_type: 'purchase_completed',
  session_id: 'S0185',
  client_id: 'C117',
  product_id: 'P101',
  channel: 'web',
  payload: { quantity: 1 }
}
```

**Pour aller plus loin** : `occurred_at` s'affiche entre guillemets. C'est une **chaîne de caractères**, pas une date, parce que `mongoimport` recopie le texte du fichier sans interpréter son contenu. Le module M2 explique comment créer une vraie date, et le module M4 comment filtrer sur un type. Ce détail deviendra un piège classique : une date stockée en texte ne se compare pas comme une date.

## Étape 6 - Choisir MongoDB plutôt que SQL

**Objectif** : savoir dans quels cas un modèle document est adapté.

**Explication** : le tableau ci-dessous donne la correspondance de vocabulaire et l'arbitrage. Un document regroupe dans une seule entité ce qu'un modèle relationnel éclaterait en plusieurs tables reliées par des clés étrangères. Cette économie de jointures accélère la lecture d'un agrégat complet (un produit et ses attributs), au prix d'une moindre protection contre l'incohérence : rien n'empêche deux documents de se contredire si l'application ne surveille pas.

| Prisme | SQL | MongoDB |
|---|---|---|
| Conteneur de données | Table | Collection |
| Enregistrement | Ligne | Document |
| Colonnes | Colonnes | Champs |
| Lien entre entités | Clé étrangère et jointure | Sous-document ou référence par `_id` |
| Schéma | Imposé par la base | Souple, à faire respecter par l'application |

**Commande à copier-coller** :

```javascript
db.produits.find({}, { _id: 0, name: 1, category: 1 }).limit(5)
```

**Résultat attendu** : une lecture allégée du catalogue, réduite à trois champs.

```text
[
  { category: 'cafe', name: 'Altitude Brésil' },
  { category: 'casque-audio', name: 'Onde Pro' },
  { category: 'casque-audio', name: 'Onde Studio' },
  { category: 'appareil-photo', name: 'Horizon X100' },
  { category: 'sac-a-dos', name: 'Transit 24' }
]
```

**Pour aller plus loin** : le premier argument de `find` est le filtre, le second la projection. Ici le filtre est vide (`{}`), donc tous les documents passent, et la projection demande `name` et `category` en excluant `_id`. L'ordre affiché n'est pas garanti, il dépend de l'insertion. Choisir MongoDB se justifie quand la lecture se fait par agrégat et que la forme des données évolue vite ; rester en SQL se justifie quand les garanties transactionnelles et la contrainte de schéma priment. Les modules M8 à M10 approfondissent l'optimisation, les garanties et la distribution.

# M2 - Documents et types de données

JSON connaît peu de types : chaîne, nombre, booléen, null, tableau, objet. MongoDB stocke ses documents dans un format binaire dérivé, appelé **BSON** (Binary JSON), qui en ajoute d'autres : entiers de 32 et 64 bits, décimal exact, dates, identifiants, expressions régulières. Ce module les passe en revue en les insérant pour de vrai, dans une collection de travail `cours_types`.

> [!info] Une collection de travail
> Les modules M2 et M3 écrivent dans des collections dédiées (`cours_types`, `cours_produits`). Le catalogue `produits` et le journal `evenements` restent intacts : vous pourrez toujours vous y référer, et `sh scripts/load-data.sh` les remet à zéro.

## Étape 1 - Chaînes, booléens et nombres

**Objectif** : insérer un premier document maîtrisé et distinguer les types par leur écriture.

**Explication** : `insertOne` reçoit un document (entre accolades) et l'ajoute à la collection. Le shell répond par un accusé de réception contenant l'`_id` attribué. Ici, `name` est une chaîne (entre guillemets) et `active` un booléen (`true`, sans guillemets).

**Commande à copier-coller** :

```javascript
db.cours_types.drop(); db.cours_types.insertOne({ product_id: "T1", name: "Câble USB-C", active: true })
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : la commande commence par `drop()`, qui supprime la collection si elle existe. Cela rend l'étape rejouable à l'identique : c'est une bonne habitude pour tout exercice d'écriture. `insertOne` insère **un** document ; la variante pour plusieurs est vue au module M3.

**Piège classique : `true` n'est pas `1`**

Dans le shell, vous verrez souvent `1` là où on attendrait `true` : `{ name: 1 }` dans une projection, `{ ping: 1 }` dans une commande. On en déduit vite que MongoDB traite les deux pareil. C'est vrai pour ces *options* de commande, c'est faux pour les *données*.

Faites l'expérience. Le document `T1` a été inséré avec `active: true`. Cherchez-le avec un `1` :

```javascript
db.cours_types.find({ active: 1 }).toArray()
```

Résultat : `[]`. Rien. Recommencez avec `true` :

```javascript
db.cours_types.find({ active: true }).toArray()
```

Le document réapparaît. Pourquoi ? Parce que BSON distingue le **type** de la valeur : `true` est un booléen, `1` est un entier. Pour MongoDB, ce sont deux valeurs différentes, comme `"1"` (une chaîne) et `1` (un nombre) le seraient.

La règle à retenir : dans un **filtre ou un document**, écrivez la valeur avec le type exact que vous avez stocké. Le raccourci `1 = true` n'existe que dans la syntaxe des projections et des options, où il signifie simplement « activé ». Le module M4 donne l'outil pour vérifier le type d'un champ (`$type`).

## Étape 2 - Entiers 32 bits, entiers 64 bits

**Objectif** : savoir qu'un nombre entier n'a pas une seule taille en BSON.

**Explication** : par défaut, un entier écrit simplement (`12`) est un entier **32 bits**, dont le maximum est d'environ 2,1 milliards. Au-delà, il faut un entier **64 bits**, que le shell écrit `NumberLong`. Les deux se rendent différemment dans mongosh : `12` d'un côté, `Long('9000000000')` de l'autre.

**Commande à copier-coller** :

```javascript
db.cours_types.insertOne({ product_id: "T2", stock: NumberInt(12), vues: NumberLong("9000000000") })
```

**Résultat attendu** : l'accusé d'insertion, puis le document relu.

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : `NumberLong` attend une **chaîne** entre guillemets, pas un nombre : sans elle, le shell prévient que la précision peut être perdue avant même l'envoi à MongoDB. Le rendu `Long('9000000000')` confirme que la valeur a été stockée en 64 bits. Pour relire ce même document, `db.cours_types.findOne({ product_id: "T2" })` affiche `stock: 12` et `vues: Long('9000000000')`.

## Étape 3 - Nombres à virgule et montants exacts

**Objectif** : choisir le bon type pour un prix.

**Explication** : un `4.7` écrit tel quel est un **double** (virgule flottante binaire), parfait pour une note, inadapté à un montant. `Decimal128` encode une décimale **exacte**, et c'est le type à utiliser pour l'argent. Le catalogue du lab utilise d'ailleurs des doubles pour ses prix, ce qui est un choix acceptable pour l'exercice mais discutable en production.

**Commande à copier-coller** :

```javascript
db.cours_types.insertOne({ product_id: "T3", note: 4.7, prix: NumberDecimal("749.90") })
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : relisez le document avec `db.cours_types.findOne({ product_id: "T3" })`. Le shell affiche `note: 4.7` et `prix: Decimal128('749.90')`. La différence d'affichage est le seul indice visuel du type réel, et c'est déjà beaucoup : sur un calcul de facture, `0.1 + 0.2` en double ne vaut pas exactement `0.3`, alors qu'en `Decimal128` l'addition est exacte.

## Étape 4 - Dates : un vrai type, distinct d'une chaîne

**Objectif** : créer une date exploitable et repérer une date stockée en texte.

**Explication** : `new Date(...)` construit un objet date, que MongoDB stocke au format BSON et que mongosh rend `ISODate(...)`. Une chaîne qui ressemble à une date, elle, reste une chaîne : c'est le cas du champ `occurred_at` du journal, importé depuis un fichier texte.

**Commande à copier-coller** :

```javascript
db.cours_types.insertOne({ product_id: "T4", cree_le: new Date("2026-09-12T09:58:10Z") })
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : comparez maintenant les deux formes dans la base. Le document que vous venez d'écrire se relit `cree_le: ISODate('2026-09-12T09:58:10.000Z')`, tandis que le journal se relit `occurred_at: '2026-09-12T09:58:10Z'`. Le premier est une date, le second une chaîne. Un tri ou un filtre par plage de dates ne se comporte pas pareil sur les deux, et c'est l'une des erreurs les plus coûteuses quand on importe des données existantes : vérifiez toujours le type relu, jamais le type supposé.

## Étape 5 - Objets imbriqués et tableaux

**Objectif** : regrouper plusieurs informations liées dans un seul document.

**Explication** : un champ peut contenir un objet (`attributes`) ou un tableau (`tags`). C'est la réponse du modèle document aux tables annexes : les attributs restent collés au produit, dans la même lecture, sans jointure. Le tableau accepte des valeurs simples comme des sous-documents, ce que fait `media` dans le catalogue.

**Commande à copier-coller** :

```javascript
db.cours_types.insertOne({ product_id: "T5", attributes: { sensor: "APS-C", stabilization: true }, tags: ["photo", "sport"] })
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : relisez par `db.cours_types.findOne({ product_id: "T5" })` pour voir le rendu imbriqué. Les opérateurs de tableau (chercher dans un tableau, le compter, en extraire une tranche) sont traités au module M4, et l'opération qui « déplie » un tableau en plusieurs lignes l'est au module M6 avec `$unwind`.

## Étape 6 - ObjectId : l'identifiant généré

**Objectif** : observer la génération automatique de `_id`.

**Explication** : `insertOne` renvoie un compte rendu, et `insertedId` est accessible directement. C'est la valeur que MongoDB a inventée pour ce document, faute d'en avoir reçu une.

**Commande à copier-coller** :

```javascript
db.cours_types.insertOne({ product_id: "T6" }).insertedId
```

**Résultat attendu** :

```text
ObjectId('...')
```

**Pour aller plus loin** : la valeur change à chaque exécution, et c'est voulu. Un `ObjectId` mêle un horodatage, un identifiant de machine et un compteur : il est unique sans coordination centrale, ce qui le rend utilisable même sur plusieurs serveurs. Si vous préférez fournir votre propre `_id`, MongoDB l'accepte, mais il doit rester unique dans la collection.

## Étape 7 - null, champ absent, et pourquoi la différence compte

**Objectif** : distinguer une valeur nulle d'un champ qui n'existe pas.

**Explication** : `promo: null` déclare un champ dont la valeur est explicitement nulle ; le document `T8`, lui, n'a **pas** de champ `promo` du tout. Les deux se ressemblent à la lecture, et se comportent différemment à l'interrogation. Cette distinction est celle que JSON ne sait pas exprimer.

**Commande à copier-coller** :

```javascript
db.cours_types.drop(); db.cours_types.insertMany([ { product_id: "T7", promo: null }, { product_id: "T8" } ])
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedIds: { '0': ObjectId('...'), '1': ObjectId('...') } }
```

**Pour aller plus loin** : relisez les deux avec `db.cours_types.find({}, { _id: 0, product_id: 1, promo: 1 }).toArray()`. `T7` affiche `promo: null`, `T8` n'affiche aucune ligne `promo`. Un filtre `{ promo: null }` retrouve les deux ; un filtre `{ promo: { $exists: false } }` ne retrouve que `T8`. Le module M4 détaille `$exists`.

## Étape 8 - Les types que vous croiserez rarement

**Objectif** : savoir que BSON en contient d'autres, sans les confondre avec du JSON.

**Explication** : `MinKey` et `MaxKey` servent de bornes de comparaison ; une expression régulière peut être stockée comme valeur, pas seulement utilisée dans un filtre ; on croise aussi `Binary` (octets, images), `Timestamp` (horodatage interne de la réplication), `Undefined` (déprécié, distinct de `null`), `Symbol` (déprécié lui aussi) et le type `JavaScript` (du code stocké, à éviter). Les connaître évite de s'étonner devant une sortie du shell.

**Commande à copier-coller** :

```javascript
db.cours_types.insertOne({ product_id: "T9", motif: /^HORIZON/i, borne: MinKey() })
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : `db.cours_types.findOne({ product_id: "T9" })` affiche `motif: /^HORIZON/i` et `borne: MinKey()`. Le type exact d'un champ se vérifie avec l'opérateur `$type`, vu au module M4 : c'est lui qui tranche entre `int`, `long`, `double`, `string` et `date` quand l'affichage laisse un doute.

# M3 - Créer, lire, modifier, supprimer

Le CRUD (Create, Read, Update, Delete) est le socle de tout usage. Ce module travaille sur une collection dédiée `cours_produits`, copie partielle du catalogue, pour que les manipulations n'abîment pas les données de référence.

## Étape 1 - Insérer un document

**Objectif** : créer un document et lire l'accusé de réception de MongoDB.

**Explication** : `insertOne` prend un document et l'ajoute. Il ne remplace rien : deux insertions identiques créent deux documents distincts, car `_id` diffère. La réponse indique le nombre de documents reconnus (`acknowledged`) et l'identifiant attribué.

**Commande à copier-coller** :

```javascript
db.cours_produits.drop(); db.cours_produits.insertOne({ product_id: "P101", category: "appareil-photo", name: "Horizon X100", price: 749.0, active: true, attributes: { sensor: "APS-C", stabilization: true } })
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : `acknowledged: true` signifie que le serveur a bien écrit (ou pris en charge) le document. Un `acknowledged: false` n'arrive qu'avec des niveaux d'acquittement relâchés, traités au module M9. Le `drop()` en tête n'est pas obligatoire : il garantit un état de départ propre.

## Étape 2 - Insérer plusieurs documents d'un coup

**Objectif** : écrire un lot de documents en une seule opération.

**Explication** : `insertMany` reçoit un **tableau** de documents (des accolades, dans des crochets). Une seule opération réseau, une seule validation, un seul accusé de réception. C'est la forme à utiliser pour charger un jeu de données, plutôt que d'enchaîner les `insertOne`.

**Commande à copier-coller** :

```javascript
db.cours_produits.insertMany([
  { product_id: "P102", category: "appareil-photo", name: "Horizon Mini", price: 429.0, active: true, attributes: { sensor: "Micro 4/3", stabilization: false } },
  { product_id: "P103", category: "casque-audio", name: "Onde Pro", price: 219.0, active: true, attributes: { wireless: true } }
])
```

**Résultat attendu** :

```text
{
  acknowledged: true,
  insertedIds: { '0': ObjectId('...'), '1': ObjectId('...') }
}
```

**Pour aller plus loin** : par défaut, `insertMany` s'arrête à la première erreur mais insère les documents précédents (`ordered: true`). L'option `{ ordered: false }` continue malgré l'erreur et insère tout ce qui passe. Le choix compte lors d'un import en masse : ordonné pour un jeu cohérent, non ordonné pour absorber des données imparfaites.

## Étape 3 - Lire : `find` et `findOne`

**Objectif** : distinguer une lecture unique d'une lecture multiple.

**Explication** : `find(filter)` renvoie un **curseur**, c'est-à-dire un pointeur sur un résultat qui se parcourt progressivement ; `.toArray()` le transforme en tableau JavaScript complet. `findOne(filter)` renvoie directement le premier document trouvé, ou `null`. Le filtre vide `{}` accepte tous les documents.

**Commande à copier-coller** :

```javascript
db.cours_produits.find().toArray()
```

**Résultat attendu** (extrait, les trois documents suivent) :

```text
[
  {
    _id: ObjectId('...'),
    product_id: 'P101',
    category: 'appareil-photo',
    name: 'Horizon X100',
    price: 749,
    active: true,
    attributes: { sensor: 'APS-C', stabilization: true }
  },
  ...
]
```

**Pour aller plus loin** : `db.cours_produits.findOne({ product_id: "P103" })` renvoie le seul document `Onde Pro`, sans crochets. Retenez la différence de nature : `find` rend un curseur (parcourable, paresseux), `findOne` rend un document. C'est aussi pourquoi `find` s'utilise dans le shell sans `.toArray()`, la console déroulant le curseur pour l'affichage. Dans un script ou une application, ce déroulé automatique n'existe pas : `find()` donne un curseur, qu'on parcourt document par document avec `hasNext()` et `next()` (détaillés à l'étape 13), ou qu'on matérialise d'un coup avec `.toArray()`. Ce dernier charge tous les documents en mémoire côté client : sur une grande collection, on le fait précéder d'un `.limit()`. Et les modificateurs `.sort()`, `.limit()`, `.skip()` se chaînent sur le curseur, donc avant `.toArray()`, jamais après.

## Étape 4 - Compter sans rapatrier les documents

**Objectif** : obtenir un nombre sans transférer le contenu.

**Explication** : `countDocuments()` reçoit un filtre optionnel et compte les documents qui le satisfont. Le comptage est fait par le serveur : le document ne remonte jamais au client, ce qui change tout sur une collection volumineuse.

**Commande à copier-coller** :

```javascript
db.cours_produits.countDocuments()
```

**Résultat attendu** :

```text
3
```

**Pour aller plus loin** : ne confondez pas `countDocuments({ ... })`, qui compte en appliquant un filtre, et `estimatedDocumentCount()`, qui lit une estimation dans les métadonnées et ignore le filtre. La première est exacte et coûteuse, la seconde est instantanée et approximative.

## Étape 5 - Modifier un champ : `updateOne` et `$set`

**Objectif** : changer la valeur d'un champ sur un document ciblé.

**Explication** : `updateOne(filtre, modification)` modifie **le premier** document qui correspond. La modification s'exprime avec des opérateurs : `$set` définit la valeur d'un champ, existant ou non. Sans l'opérateur `$`, la commande attend un document complet de remplacement, et c'est là qu'on écrase des données par accident.

**Commande à copier-coller** :

```javascript
db.cours_produits.updateOne({ product_id: "P103" }, { $set: { price: 229.0 } })
```

**Résultat attendu** :

```text
{ acknowledged: true, matchedCount: 1, modifiedCount: 1, upsertedCount: 0 }
```

**Pour aller plus loin** : `matchedCount` compte les documents trouvés par le filtre, `modifiedCount` ceux réellement changés. Les deux diffèrent quand la nouvelle valeur est identique à l'ancienne : MongoDB ne réécrit pas un document inchangé. Lire ces deux nombres est le premier réflexe de débogage d'une mise à jour qui « ne fait rien ».

## Étape 6 - Modifier plusieurs documents : `updateMany`

**Objectif** : appliquer la même modification à tout un sous-ensemble.

**Explication** : `updateMany` fonctionne comme `updateOne` mais sur **tous** les documents filtrés. C'est l'opération à manier avec attention : le filtre décide de l'ampleur de l'écriture.

**Commande à copier-coller** :

```javascript
db.cours_produits.updateMany({ category: "appareil-photo" }, { $set: { active: false } })
```

**Résultat attendu** :

```text
{ acknowledged: true, matchedCount: 2, modifiedCount: 2, upsertedCount: 0 }
```

**Pour aller plus loin** : vérifiez le résultat par `db.cours_produits.find({ category: "appareil-photo" }, { _id: 0, name: 1, active: 1 }).toArray()`, qui doit montrer `Horizon X100` et `Horizon Mini` en `active: false`. Le réflexe de sécurité avant tout `updateMany` : lancer d'abord la requête `find` **avec le même filtre**, et compter ce qu'on s'apprête à changer.

## Étape 7 - Incrémenter et retirer un champ

**Objectif** : modifier un nombre par rapport à sa valeur, et supprimer un champ.

**Explication** : `$inc` ajoute une valeur au champ, sans avoir à le relire d'abord, ce qui évite les conflits en écriture concurrente. `$unset` retire le champ du document. Ce sont deux opérateurs parmi la vingtaine du module `update` : `$mul`, `$min`, `$max`, `$rename`, `$push` et `$addToSet` suivent la même logique.

**Commande à copier-coller** :

```javascript
db.cours_produits.updateOne({ product_id: "P103" }, { $inc: { price: 1.0 } })
```

**Résultat attendu** :

```text
{ acknowledged: true, matchedCount: 1, modifiedCount: 1, upsertedCount: 0 }
```

**Pour aller plus loin** : `$inc` se vérifie par `db.cours_produits.findOne({ product_id: "P103" }).price`, qui doit afficher `230`. Le retrait d'un champ s'écrit `db.cours_produits.updateOne({ product_id: "P102" }, { $unset: { active: "" } })` : la valeur passée à `$unset` est ignorée, on met conventionnellement une chaîne vide. Après cette commande, le document `P102` n'a plus de champ `active`, il n'a pas `active: null`.

## Étape 8 - Insérer si absent : l'upsert

**Objectif** : faire d'une mise à jour une insertion conditionnelle.

**Explication** : avec `{ upsert: true }`, si aucun document ne correspond au filtre, MongoDB en crée un en combinant le filtre et la modification. C'est le geste classique de synchronisation : « mets à jour, ou crée ».

**Commande à copier-coller** :

```javascript
db.cours_produits.updateOne({ product_id: "P104" }, { $set: { name: "Onde Studio", category: "casque-audio", price: 159.0 } }, { upsert: true })
```

**Résultat attendu** :

```text
{ acknowledged: true, matchedCount: 0, modifiedCount: 0, upsertedCount: 1, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : `matchedCount: 0` et `upsertedCount: 1` sont la signature de l'insertion. Rejouez exactement la même commande : vous obtiendrez cette fois `matchedCount: 1`, `upsertedCount: 0`, car le document existe désormais. L'upsert est idempotent, c'est précisément ce qui le rend utile dans un script rejouable.

## Étape 9 - Modifier et récupérer en une fois : `findOneAndUpdate`

**Objectif** : obtenir le document après modification, sans seconde requête.

**Explication** : `findOneAndUpdate` modifie un document **et le renvoie**. Par défaut il renvoie l'état **avant** modification ; `{ returnDocument: "after" }` demande l'état après. Cette atomicité évite un aller-retour, et surtout la fenêtre pendant laquelle un autre client aurait pu modifier le document entre les deux.

**Commande à copier-coller** :

```javascript
db.cours_produits.findOneAndUpdate({ product_id: "P104" }, { $set: { active: true } }, { returnDocument: "after" })
```

**Résultat attendu** :

```text
{
  _id: ObjectId('...'),
  product_id: 'P104',
  category: 'casque-audio',
  name: 'Onde Studio',
  price: 159,
  active: true
}
```

**Pour aller plus loin** : les variantes `findOneAndReplace` et `findOneAndDelete` suivent le même principe. Retenez le triptyque : l'opération `update` ne renvoie qu'un compte rendu, l'opération `findOneAndUpdate` renvoie le document, l'opération `aggregate` avec `$merge` (module M6) traite des lots.

## Étape 10 - Remplacer un document entier : `replaceOne`

**Objectif** : substituer un document complet à un autre.

**Explication** : `replaceOne(filtre, document)` remplace tout le contenu sauf `_id`. C'est l'opération à réserver aux cas où la nouvelle version est complète : un champ non mentionné dans le remplacement disparaît.

**Commande à copier-coller** :

```javascript
db.cours_produits.replaceOne({ product_id: "P102" }, { product_id: "P102", category: "appareil-photo", name: "Horizon Mini", price: 449.0, active: true })
```

**Résultat attendu** :

```text
{ acknowledged: true, matchedCount: 1, modifiedCount: 1, upsertedCount: 0 }
```

**Pour aller plus loin** : vérifiez que `db.cours_produits.findOne({ product_id: "P102" })` ne contient plus le sous-objet `attributes`. Il a disparu, parce que le document de remplacement ne le mentionnait pas. C'est la différence décisive avec `$set`, qui aurait laissé `attributes` intact. Par défaut, `replaceOne` ne fait rien si aucun document ne correspond.

## Étape 11 - Supprimer un document

**Objectif** : retirer un document ciblé.

**Explication** : `deleteOne(filtre)` supprime **le premier** document correspondant. Comme pour les mises à jour, c'est le filtre qui décide, et le compte rendu, le seul garde-fou.

**Commande à copier-coller** :

```javascript
db.cours_produits.deleteOne({ product_id: "P104" })
```

**Résultat attendu** :

```text
{ acknowledged: true, deletedCount: 1 }
```

**Pour aller plus loin** : `deletedCount: 0` est un résultat parfaitement normal, pas une erreur : le filtre n'a rien trouvé. La suppression d'une collection entière se fait par `drop()`, et celle d'une base par `db.dropDatabase()`. Ces deux-là ne rendent aucun compte détaillé : elles effacent tout, immédiatement.

## Étape 12 - Grouper plusieurs écritures : `bulkWrite`

**Objectif** : exécuter un lot d'opérations hétérogènes en un seul appel.

**Explication** : `bulkWrite` reçoit un tableau où chaque entrée porte son opération : `insertOne`, `updateOne`, `deleteOne`, `replaceOne`. Utile quand une synchronisation mêle créations, modifications et suppressions dans le même traitement, avec un seul aller-retour réseau.

**Commande à copier-coller** :

```javascript
db.cours_produits.bulkWrite([
  { insertOne: { document: { product_id: "P105", category: "sac-a-dos", name: "Transit 24", price: 89.0 } } },
  { updateOne: { filter: { product_id: "P101" }, update: { $set: { price: 799.0 } } } }
])
```

**Résultat attendu** : un compte rendu ventilé par type d'opération.

```text
{
  acknowledged: true,
  insertedCount: 1,
  matchedCount: 1,
  modifiedCount: 1,
  deletedCount: 0,
  upsertedCount: 0
}
```

**Pour aller plus loin** : `bulkWrite` accepte aussi `{ ordered: false }`, comme `insertMany`. Le comptage peut alors se poursuivre après une erreur, et la réponse gagne un tableau d'erreurs. C'est l'outil des imports et des synchronisations, pas des écritures unitaires d'une application.

## Étape 13 - Parcourir un curseur

**Objectif** : lire un résultat sans tout charger en mémoire.

**Explication** : `find` renvoie un curseur. On le parcourt avec `hasNext()` (reste-t-il un document ?) et `next()` (suivant). Le serveur rapatrie les documents par lots, ce qui permet de traiter un résultat énorme avec une mémoire constante. `limit(n)` borne le nombre de documents, `sort(...)` en fixe l'ordre.

**Commande à copier-coller** :

```javascript
let curseur = db.cours_produits.find().sort({ price: -1 }).limit(2); curseur.hasNext()
```

**Résultat attendu** :

```text
true
```

**Pour aller plus loin** : `curseur.next()` renvoie alors le premier document, `{ product_id: 'P101', ..., price: 799 }`, puis un second appel renvoie le suivant. En mongosh, un curseur non consommé s'affiche de lui-même, ce qui masque ce mécanisme en usage interactif : il redevient visible dès qu'on écrit un script ou une application.

## Étape 14 - Supprimer en lot

**Objectif** : nettoyer la collection de travail et constater l'ampleur d'un `deleteMany`.

**Explication** : `deleteMany(filtre)` supprime **tous** les documents correspondants. Le compte rendu est le seul retour : MongoDB ne demande pas de confirmation, et il n'y a pas de corbeille.

**Commande à copier-coller** :

```javascript
db.cours_produits.deleteMany({ category: "appareil-photo" })
```

**Résultat attendu** :

```text
{ acknowledged: true, deletedCount: 2 }
```

**Pour aller plus loin** : un `deleteMany({})` avec un filtre vide supprime **toute** la collection, document par document. C'est la différence avec `drop()`, qui détruit d'un coup la collection, ses documents et ses index. En environnement de production, la suppression d'un document est souvent logique plutôt que physique : on ajoute un champ `deleted_at` et les requêtes le filtrent. Le document reste, l'utilisateur ne le voit plus.

# M4 - Interroger avec les opérateurs

Un filtre MongoDB est un document où l'on place, à la place d'une valeur exacte, un **opérateur** : `{ price: { $gt: 400 } }` se lit « prix supérieur à 400 ». Ce module parcourt les familles d'opérateurs dont on se sert tous les jours. Sauf mention contraire, les requêtes portent sur le catalogue réel, qui compte 8 produits.

## Étape 1 - Égalité et différence : `$eq` et `$ne`

**Objectif** : écrire un filtre d'égalité explicite, et son contraire.

**Explication** : `{ category: "cafe" }` est déjà une égalité, implicite. `$eq` dit la même chose en toutes lettres, ce qui devient utile à l'intérieur d'une expression composée. `$ne` sélectionne tout ce qui **diffère** de la valeur.

**Commande à copier-coller** :

```javascript
db.produits.countDocuments({ category: "cafe" })
```

**Résultat attendu** :

```text
2
```

**Pour aller plus loin** : `db.produits.countDocuments({ category: { $ne: "cafe" } })` renvoie `6`, soit les 8 produits moins les 2 cafés. Attention à `$ne` sur un champ optionnel : un document qui n'a pas le champ compte comme différent, donc il est inclus.

## Étape 2 - Comparaisons : `$gt`, `$gte`, `$lt`, `$lte`

**Objectif** : filtrer une plage de valeurs.

**Explication** : `$gt` (strictement supérieur), `$gte` (supérieur ou égal), `$lt` (strictement inférieur), `$lte` (inférieur ou égal). Sur un champ numérique, la comparaison est numérique ; sur une chaîne, elle est lexicographique ; sur une date, chronologique, à condition que le champ soit bien de type date (voir M2, étape 4).

**Commande à copier-coller** :

```javascript
db.produits.find({ price: { $gt: 400 } }, { _id: 0, name: 1, price: 1 }).toArray()
```

**Résultat attendu** :

```text
[
  { name: 'Horizon X100', price: 749 },
  { name: 'Horizon Mini', price: 429 }
]
```

**Pour aller plus loin** : `$gte: 500` ne renvoie que `Horizon X100` (`749`), et `$lt: 20` renvoie les deux cafés (`10.9` et `12.5`). Les quatre opérateurs se combinent dans un même objet pour exprimer un intervalle : `{ price: { $gte: 100, $lt: 500 } }`.

## Étape 3 - Appartenance à une liste : `$in` et `$nin`

**Objectif** : remplacer une longue suite de `ou` par une liste.

**Explication** : `$in` sélectionne les documents dont la valeur figure dans un tableau donné. C'est une écriture directe de « ou » : `{ category: { $in: ["cafe", "sac-a-dos"] } }` veut dire « catégorie parmi café ou sac-à-dos ». `$nin` fait l'inverse.

**Commande à copier-coller** :

```javascript
db.produits.find({ category: { $in: ["cafe", "sac-a-dos"] } }, { _id: 0, name: 1, category: 1 }).toArray()
```

**Résultat attendu** : les 4 produits concernés.

```text
[
  { category: 'sac-a-dos', name: 'Transit 24' },
  { category: 'cafe', name: 'Altitude Brésil' },
  { category: 'sac-a-dos', name: 'Transit 16' },
  { category: 'cafe', name: 'Altitude Éthiopie' }
]
```

**Pour aller plus loin** : `db.produits.countDocuments({ category: { $nin: ["cafe", "sac-a-dos"] } })` renvoie `4`. Sur un champ de type tableau, `$in` réussit si **au moins un** élément du tableau correspond : la même écriture sert donc aussi à tester l'appartenance d'un élément.

## Étape 4 - Combiner : `$and` et `$or`

**Objectif** : enchaîner plusieurs conditions.

**Explication** : deux conditions sur des champs différents dans le même objet sont implicitement un « et » : `{ category: "appareil-photo", price: { $lt: 500 } }`. `$and` l'explicite, ce qui devient nécessaire quand la même expression doit apparaître deux fois. `$or`, lui, est un vrai choix : au moins une branche doit correspondre.

**Commande à copier-coller** :

```javascript
db.produits.find({ $or: [ { category: "cafe" }, { price: { $gt: 700 } } ] }, { _id: 0, name: 1, category: 1, price: 1 }).toArray()
```

**Résultat attendu** :

```text
[
  { category: 'cafe', name: 'Altitude Brésil', price: 10.9 },
  { category: 'cafe', name: 'Altitude Éthiopie', price: 12.5 },
  { category: 'appareil-photo', name: 'Horizon X100', price: 749 }
]
```

**Pour aller plus loin** : `$and` et `$or` reçoivent un **tableau** d'expressions. Le `$and` explicite sert surtout aux cas où le même champ porte deux contraintes incompatibles dans un objet : `{ $and: [ { price: { $gt: 100 } }, { price: { $lt: 500 } } ] }`.

## Étape 5 - Négation : `$not` et `$nor`

**Objectif** : inverser une condition, sur un champ ou sur un ensemble.

**Explication** : `$not` s'applique **à l'intérieur d'un champ** et nie l'opérateur qui suit : `{ price: { $not: { $gt: 200 } } }` veut dire « prix non supérieur à 200 », c'est-à-dire inférieur ou égal, **y compris les documents sans champ `price`**. `$nor` est le « ni » global : aucune des branches ne doit correspondre.

**Commande à copier-coller** :

```javascript
db.produits.find({ price: { $not: { $gt: 200 } } }, { _id: 0, name: 1, price: 1 }).toArray()
```

**Résultat attendu** : les 5 produits dont le prix n'excède pas 200.

```text
[
  { name: 'Altitude Brésil', price: 10.9 },
  { name: 'Onde Studio', price: 159 },
  { name: 'Transit 24', price: 89 },
  { name: 'Transit 16', price: 69 },
  { name: 'Altitude Éthiopie', price: 12.5 }
]
```

**Pour aller plus loin** : `$nor` en action, `db.produits.find({ $nor: [ { category: "cafe" }, { price: { $gt: 500 } } ] }, ...)` renvoie les 5 produits qui ne sont ni des cafés ni au-dessus de 500. La différence entre `$not` et `$nor` tient au niveau où l'on se place : `$not` nie un champ, `$nor` nie un ensemble de conditions.

## Étape 6 - Présence d'un champ : `$exists`

**Objectif** : distinguer « le champ vaut null » de « le champ n'existe pas ».

**Explication** : `$exists: true` retient les documents où le champ est présent, quelle que soit sa valeur, null comprise. `$exists: false` retient ceux où il est absent. Dans le catalogue, seul le produit `P102` porte le champ hérité `legacy_label`.

**Commande à copier-coller** :

```javascript
db.produits.find({ legacy_label: { $exists: true } }, { _id: 0, name: 1, legacy_label: 1 }).toArray()
```

**Résultat attendu** :

```text
[ { name: 'Horizon Mini', legacy_label: 'compact' } ]
```

**Pour aller plus loin** : le contraste avec `{ legacy_label: null }` est instructif. Ce dernier sélectionne à la fois `P102` (valeur non nulle, donc non retenu ici) et tous les documents **sans** le champ : une requête sur `null` attrape aussi les absents, pas seulement les nuls explicites.

## Étape 7 - Vérifier le type : `$type`

**Objectif** : filtrer sur le type BSON réel d'un champ.

**Explication** : `$type` compare le type de stockage, pas la valeur affichée. C'est l'outil de vérification du module M2 : les prix du catalogue, importés depuis un fichier JSON avec des décimales, sont des `double`, et aucun n'est un entier.

**Commande à copier-coller** :

```javascript
db.produits.countDocuments({ price: { $type: "double" } })
```

**Résultat attendu** :

```text
8
```

**Pour aller plus loin** : `db.produits.countDocuments({ price: { $type: "int" } })` renvoie `0`, ce qui prouve que les prix sont bien des doubles. Les noms de type acceptés incluent `string`, `int`, `long`, `double`, `decimal`, `bool`, `date`, `object`, `array`, `null`, `objectId`. C'est le juge de paix quand l'affichage laisse planer un doute. C'est aussi l'outil qui règle le piège `true`/`1` du module M2 : `{ active: { $type: "bool" } }` ne retrouve que les booléens, `{ active: { $type: "int" } }` que les entiers. Si une collection mélange les deux (import mal typé, application qui a changé), c'est ainsi qu'on le découvre avant de corriger.

## Étape 8 - Motifs de texte : `$regex`

**Objectif** : filtrer une chaîne sur un motif.

**Explication** : `$regex` applique une expression régulière à une chaîne. `^Horizon` ancre le motif au début, donc ne retient que les noms qui commencent par `Horizon`. Sans ancre, le motif cherche n'importe où dans la chaîne.

**Commande à copier-coller** :

```javascript
db.produits.find({ name: { $regex: "^Horizon" } }, { _id: 0, name: 1 }).toArray()
```

**Résultat attendu** :

```text
[ { name: 'Horizon X100' }, { name: 'Horizon Mini' } ]
```

**Pour aller plus loin** : l'insensibilité à la casse s'obtient par `{ $regex: "^horizon", $options: "i" }`. Un mot entier se cherche par `\b`, par exemple `{ $regex: "\\bmini\\b", $options: "i" }`. MongoDB dispose aussi d'un opérateur `$text` et d'index texte, plus adaptés à une vraie recherche plein texte (module M7) : `$regex` reste l'outil du motif précis, pas du moteur de recherche.

## Étape 9 - Tableaux : `$all` et `$size`

**Objectif** : interroger un champ qui contient un tableau.

**Explication** : `$size` exige une taille exacte. `$all` exige que le tableau contienne **tous** les éléments listés. Dans le catalogue, chaque produit porte un tableau `media` d'un seul élément.

**Commande à copier-coller** :

```javascript
db.produits.countDocuments({ media: { $size: 1 } })
```

**Résultat attendu** :

```text
8
```

**Pour aller plus loin** : `db.produits.countDocuments({ category: { $all: ["cafe"] } })` renvoie `2`, car `category` est une chaîne et `$all` la traite comme un tableau à un élément. Sur un vrai tableau, par exemple `tags`, `$all: ["photo", "sport"]` exigerait les deux valeurs, dans n'importe quel ordre.

## Étape 10 - Tableaux de documents : `$elemMatch`

**Objectif** : faire porter plusieurs conditions sur **un même** élément de tableau.

**Explication** : quand un tableau contient des sous-documents, écrire deux conditions côte à côte peut être satisfait par deux éléments différents. `$elemMatch` impose que les conditions portent sur le **même élément**. C'est la garantie dont on a besoin dès qu'un tableau porte des objets.

**Commande à copier-coller** :

```javascript
db.produits.find({ media: { $elemMatch: { kind: "image" } } }, { _id: 0, name: 1 }).toArray()
```

**Résultat attendu** : **le total affiché par `.toArray().length` est `8`** ; les documents contiennent tous au moins un média de type image.

```text
[
  { name: 'Transit 24' },
  { name: 'Altitude Brésil' },
  { name: 'Transit 16' },
  { name: 'Altitude Éthiopie' },
  { name: 'Onde Studio' },
  { name: 'Horizon X100' },
  { name: 'Horizon Mini' },
  { name: 'Onde Pro' }
]
```

**Pour aller plus loin** : l'ordre n'est pas garanti, seule la présence des 8 produits compte. La différence avec une requête sans `$elemMatch` apparaît sur un tableau multi-champs : `{ "media.kind": "image", "media.path": "x" }` peut être satisfait par deux éléments distincts, alors que `$elemMatch` exige un seul élément portant les deux champs.

## Étape 11 - Extraire une tranche : `$slice`

**Objectif** : ne remonter qu'une partie d'un tableau.

**Explication** : `$slice` est un opérateur de **projection**, pas de filtre : il ne trie pas les documents, il coupe le tableau dans le document renvoyé. Sa place est donc dans le second argument de `find`. `$slice: 1` garde le premier élément ; `$slice: -2` garde les deux derniers.

**Commande à copier-coller** :

```javascript
db.produits.find({ category: "appareil-photo" }, { _id: 0, name: 1, media: { $slice: 1 } }).toArray()
```

**Résultat attendu** :

```text
[
  { name: 'Horizon X100', media: [ { kind: 'image', path: 'media/P101-front.jpg' } ] },
  { name: 'Horizon Mini', media: [ { kind: 'image', path: 'media/P102-front.jpg' } ] }
]
```

**Pour aller plus loin** : `$slice` sert aussi en agrégation (module M6), où il a la même sémantique. Sur une projection, il est souvent associé à un filtre sur la taille du tableau : le filtre `$size` décide **du document**, `$slice` décide **de ce qu'on en montre**.

## Étape 12 - Champs imbriqués : la notation pointée

**Objectif** : filtrer sur un champ situé dans un sous-document.

**Explication** : on accède à un champ imbriqué par un chemin séparé de points, entre guillemets car le nom contient un caractère spécial : `"attributes.color"`. La notation fonctionne aussi en projection, et jusque dans les index.

**Commande à copier-coller** :

```javascript
db.produits.find({ "attributes.color": "noir" }, { _id: 0, name: 1, "attributes.color": 1 }).toArray()
```

**Résultat attendu** : les 4 produits de couleur noire.

```text
[
  { name: 'Transit 16', attributes: { color: 'noir' } },
  { name: 'Onde Studio', attributes: { color: 'noir' } },
  { name: 'Horizon X100', attributes: { color: 'noir' } },
  { name: 'Onde Pro', attributes: { color: 'noir' } }
]
```

**Pour aller plus loin** : l'ordre des documents n'est pas garanti. Un filtre `{ attributes: { color: "noir" } }` aurait un sens tout différent : MongoDB chercherait un sous-document **exactement égal** à `{ color: "noir" }`, avec les mêmes champs dans le même ordre. Sur un sous-document, une égalité est une égalité stricte, jamais une correspondance partielle.

## Étape 13 - Choisir les champs renvoyés : la projection

**Objectif** : ne faire remonter que les champs utiles.

**Explication** : le second argument de `find` est la projection. On **inclut** en mettant `1`, on **exclut** en mettant `0`. Les deux modes ne se mélangent pas, à une exception près : `_id`, qui peut toujours être exclu explicitement par `_id: 0`. Une projection allégée réduit le trafic réseau et la mémoire consommée.

**Commande à copier-coller** :

```javascript
db.produits.find({ category: "cafe" }, { _id: 0, name: 1, price: 1 }).toArray()
```

**Résultat attendu** :

```text
[
  { name: 'Altitude Brésil', price: 10.9 },
  { name: 'Altitude Éthiopie', price: 12.5 }
]
```

**Pour aller plus loin** : en mode exclusion, `db.produits.find({ product_id: "P101" }, { attributes: 0, media: 0 }).toArray()` renvoie tout le reste du document, `_id` compris. Retenez la règle : on inclut, ou on exclut, jamais les deux, sauf `_id` qui reste un cas à part.

# M5 - Trier, limiter, paginer

Jusqu'ici, l'ordre des documents n'était jamais garanti, et le cours le signalait à chaque fois. Ce module supprime cette incertitude : il fixe l'ordre, borne le nombre de documents, et construit une pagination.

## Étape 1 - Fixer l'ordre : `sort`

**Objectif** : imposer un ordre de restitution prévisible.

**Explication** : `sort({ champ: 1 })` trie par ordre croissant, `-1` par ordre décroissant. Un tri rend le résultat déterministe, ce qui est la condition de toute comparaison fiable d'une exécution à l'autre. On peut trier sur plusieurs champs : le second départage les égalités du premier.

**Commande à copier-coller** :

```javascript
db.produits.find({}, { _id: 0, name: 1, price: 1 }).sort({ price: 1 }).toArray()
```

**Résultat attendu** : les 8 produits, du moins cher au plus cher.

```text
[
  { name: 'Altitude Brésil', price: 10.9 },
  { name: 'Altitude Éthiopie', price: 12.5 },
  { name: 'Transit 16', price: 69 },
  { name: 'Transit 24', price: 89 },
  { name: 'Onde Studio', price: 159 },
  { name: 'Onde Pro', price: 219 },
  { name: 'Horizon Mini', price: 429 },
  { name: 'Horizon X100', price: 749 }
]
```

**Pour aller plus loin** : `sort` s'applique **avant** `skip` et `limit` dans la chaîne de traitement, quelle que soit leur ordre d'écriture dans le code. Un tri sur un champ non indexé oblige le serveur à trier en mémoire, et échoue au-delà d'une certaine taille de résultat : le module M7 montre comment un index règle ce problème.

## Étape 2 - Borner le résultat : `limit`

**Objectif** : ne demander que les N premiers documents.

**Explication** : `limit(n)` arrête la lecture après `n` documents. Sans tri explicite, « les N premiers » n'a pas de sens stable : `limit` se combine presque toujours avec `sort`.

**Commande à copier-coller** :

```javascript
db.produits.find({}, { _id: 0, name: 1, price: 1 }).sort({ price: -1 }).limit(3).toArray()
```

**Résultat attendu** : les 3 produits les plus chers.

```text
[
  { name: 'Horizon X100', price: 749 },
  { name: 'Horizon Mini', price: 429 },
  { name: 'Onde Pro', price: 219 }
]
```

**Pour aller plus loin** : `limit` n'est pas qu'une commodité d'affichage. Sur une requête destinée à savoir « existe-t-il au moins un document ? », `limit(1)` évite de parcourir tout le résultat. Le shell applique d'ailleurs une limite implicite à l'affichage, ce qui peut masquer une collection plus grande qu'il n'y paraît.

## Étape 3 - Ignorer les premiers documents : `skip`

**Objectif** : sauter un nombre de documents avant de lire.

**Explication** : `skip(n)` écarte les `n` premiers documents du résultat trié. Combiné à `limit`, il permet de parcourir un résultat par pages : `limit` est la taille de page, `skip` le nombre de documents déjà vus.

**Commande à copier-coller** :

```javascript
db.produits.find({}, { _id: 0, name: 1, price: 1 }).sort({ price: -1 }).skip(2).limit(2).toArray()
```

**Résultat attendu** : les 3e et 4e produits les plus chers.

```text
[
  { name: 'Onde Pro', price: 219 },
  { name: 'Onde Studio', price: 159 }
]
```

**Pour aller plus loin** : `skip` coûte cher sur de grands résultats, car le serveur parcourt et jette les documents écartés. Pour une pagination à grande échelle, on préfère le **curseur** : trier par un champ unique et filtrer `{ champ: { $gt: dernière_valeur_vue } }` plutôt que compter les documents sautés.

## Étape 4 - Une pagination complète

**Objectif** : assembler tri, `limit` et `skip` en pages reproductibles.

**Explication** : une pagination stable exige un **tri sur un champ unique et ordonné**, ici `product_id`. Sans cette garantie, un document peut apparaître sur deux pages ou disparaître entre deux appels. La page 1 est `limit(3)`, la page 2 est `skip(3).limit(3)`, et ainsi de suite.

**Commande à copier-coller** :

```javascript
db.produits.find({}, { _id: 0, name: 1 }).sort({ product_id: 1 }).limit(3).toArray()
```

**Résultat attendu** : page 1, les trois premiers identifiants.

```text
[
  { name: 'Horizon X100' },
  { name: 'Horizon Mini' },
  { name: 'Onde Pro' }
]
```

**Pour aller plus loin** : `db.produits.find({}, { _id: 0, name: 1 }).sort({ product_id: 1 }).skip(3).limit(3).toArray()` donne la page 2 : `Onde Studio`, `Transit 24`, `Transit 16`. Le tri par `product_id` est ici arbitraire mais **stable** : c'est la stabilité qui compte, pas le champ. Sur une collection dont les identifiants métier peuvent être modifiés, on trie plutôt par `_id`.

# M6 - Agréger les données

Une agrégation est un **pipeline** : un tableau d'étapes, exécutées dans l'ordre, où la sortie de chacune devient l'entrée de la suivante. C'est l'outil des calculs, des regroupements et des jointures. Il remplace à lui seul le `GROUP BY`, les jointures et une bonne partie des traitements applicatifs.

## Étape 1 - Un pipeline minimal : `$match` et `$count`

**Objectif** : lire la structure d'une agrégation.

**Explication** : `aggregate([...])` reçoit un tableau. Chaque élément est un objet à **une seule clé**, le nom de l'étape. `$match` filtre, comme le premier argument de `find`. `$count` remplace le flux par un unique document portant le nombre. Le journal compte 16 événements, dont 8 sur le canal `web`.

**Commande à copier-coller** :

```javascript
db.evenements.aggregate([ { $match: { channel: "web" } }, { $count: "total_web" } ]).toArray()
```

**Résultat attendu** :

```text
[ { total_web: 8 } ]
```

**Pour aller plus loin** : `$count` est en réalité un raccourci de `$group` plus `$project`. Retenez la forme : le document qui sort de chaque étape n'a plus rien à voir avec celui qui y entre, et c'est justement l'intérêt. Une agrégation ne modifie jamais les données : c'est une lecture transformée.

## Étape 2 - Fabriquer les champs de sortie : `$project`

**Objectif** : choisir et renommer les champs du résultat.

**Explication** : `$project` fonctionne comme la projection de `find`, avec une différence décisive : il sait **calculer**. Une expression `"$payload.quantity"` lit un champ du document d'entrée (le `$` initial signifie « la valeur de »), et la clé de gauche nomme le résultat. On peut donc renommer au passage.

**Commande à copier-coller** :

```javascript
db.evenements.aggregate([ { $match: { event_type: "purchase_completed" } }, { $project: { _id: 0, session_id: 1, montant: "$payload.quantity" } } ]).toArray()
```

**Résultat attendu** : les deux achats, avec le champ `payload.quantity` renommé en `montant`.

```text
[
  { session_id: 'S0185', montant: 1 },
  { session_id: 'S0186', montant: 1 }
]
```

**Pour aller plus loin** : dans un `$project`, `{ montant: 1 }` sélectionnerait le champ existant `montant`, alors que `{ montant: "$payload.quantity" }` calcule une valeur. La règle du `$` est générale en agrégation : il désigne le document d'entrée de l'étape courante, pas la base.

## Étape 3 - Regrouper et compter : `$group` et `$sum`

**Objectif** : compter des documents par catégorie, l'équivalent d'un `GROUP BY`.

**Explication** : `$group` reçoit une clé `_id`, qui est l'expression de regroupement, et des accumulateurs. `{ $sum: 1 }` compte les documents du groupe. Ici, on compte les événements par canal.

**Commande à copier-coller** :

```javascript
db.evenements.aggregate([ { $group: { _id: "$channel", total: { $sum: 1 } } }, { $sort: { total: -1 } } ]).toArray()
```

**Résultat attendu** :

```text
[
  { _id: 'web', total: 8 },
  { _id: 'mobile', total: 4 },
  { _id: 'tablet', total: 4 }
]
```

**Pour aller plus loin** : `{ $sum: "$payload.quantity" }` additionnerait les quantités au lieu de compter les documents — `$sum` accepte un nombre constant (compter) ou une expression (additionner). Le champ de sortie s'appelle `_id` par convention de l'étape `$group` : c'est la clé du groupe, et on la renomme ensuite par `$project` si nécessaire.

## Étape 4 - Autres accumulateurs : `$avg`, `$min`, `$max`

**Objectif** : calculer des statistiques par groupe.

**Explication** : à côté de `$sum`, `$group` connaît `$avg` (moyenne), `$min` et `$max`, `$first` et `$last`, `$push` (construire un tableau) et `$addToSet` (un tableau sans doublons). Tous prennent une expression en argument. Ici, le prix moyen par catégorie du catalogue.

**Commande à copier-coller** :

```javascript
db.produits.aggregate([ { $group: { _id: "$category", prix_moyen: { $avg: "$price" }, nb: { $sum: 1 } } }, { $sort: { prix_moyen: -1 } } ]).toArray()
```

**Résultat attendu** :

```text
[
  { _id: 'appareil-photo', prix_moyen: 589, nb: 2 },
  { _id: 'casque-audio', prix_moyen: 189, nb: 2 },
  { _id: 'sac-a-dos', prix_moyen: 79, nb: 2 },
  { _id: 'cafe', prix_moyen: 11.7, nb: 2 }
]
```

**Pour aller plus loin** : `$avg` ignore les documents où le champ est absent ou non numérique, et le résultat n'est pas arrondi. Sur des montants, préférez un calcul en `Decimal128` et un arrondi explicite par `$round` dans un `$project`. Cette distinction entre moyenne exacte et moyenne arrondie est un vrai sujet de facturation, pas un détail d'affichage.

## Étape 5 - Trier et tronquer dans le pipeline : `$sort` et `$limit`

**Objectif** : obtenir un classement, pas seulement un regroupement.

**Explication** : les étapes `$sort` et `$limit` de l'agrégation sont les équivalents de celles de `find`, mais appliquées au flux transformé. En les plaçant après un `$group`, on classe des groupes, ce que `find` ne sait pas faire. Le second critère `_id: 1` départage les égalités de façon déterministe.

**Commande à copier-coller** :

```javascript
db.evenements.aggregate([ { $group: { _id: "$event_type", total: { $sum: 1 } } }, { $sort: { total: -1, _id: 1 } }, { $limit: 3 } ]).toArray()
```

**Résultat attendu** : les trois types d'événements les plus fréquents.

```text
[
  { _id: 'product_viewed', total: 5 },
  { _id: 'cart_item_added', total: 4 },
  { _id: 'checkout_started', total: 3 }
]
```

**Pour aller plus loin** : l'ordre des étapes change le résultat, et c'est la propriété à retenir. `$limit` **avant** `$sort` ne renverrait que trois documents triés, pas les trois plus fréquents de l'ensemble. Une erreur d'ordre dans un pipeline produit un résultat plausible mais faux, sans lever d'erreur.

## Étape 6 - Déplier un tableau : `$unwind`

**Objectif** : transformer un document portant un tableau en autant de documents que d'éléments.

**Explication** : `$unwind: "$media"` remplace chaque document par un document par élément du tableau. C'est l'étape obligatoire pour regrouper ou compter sur des éléments de tableau, puisque `$group` raisonne sur des documents. Un document dont le tableau est vide disparaît, sauf option `preserveNullAndEmptyArrays`.

**Commande à copier-coller** :

```javascript
db.produits.aggregate([ { $sort: { product_id: 1 } }, { $unwind: "$media" }, { $project: { _id: 0, name: 1, "media.kind": 1 } }, { $limit: 3 } ]).toArray()
```

**Résultat attendu** : un document par média.

```text
[
  { name: 'Horizon X100', media: { kind: 'image' } },
  { name: 'Horizon Mini', media: { kind: 'image' } },
  { name: 'Onde Pro', media: { kind: 'image' } }
]
```

**Pour aller plus loin** : après `$unwind`, un `$group` peut compter les médias par type, ce qui serait impossible sans dépliage. `$unwind` peut aussi s'écrire avec un champ d'index (`includeArrayIndex`) pour connaître la position de chaque élément. Attention au volume : un document portant un tableau de mille éléments devient mille documents, à un moment où chaque étape suivante devra les traiter.

## Étape 7 - Joindre deux collections : `$lookup`

**Objectif** : enrichir un événement avec le nom du produit concerné.

**Explication** : `$lookup` réalise une jointure à gauche : pour chaque document d'entrée, il va chercher dans une autre collection ceux dont le champ correspond, et place le résultat dans un tableau. `from` nomme la collection, `localField` le champ côté entrée, `foreignField` le champ côté cible, `as` le nom du champ de sortie.

**Commande à copier-coller** :

```javascript
db.evenements.aggregate([ { $match: { event_type: "purchase_completed" } }, { $lookup: { from: "produits", localField: "product_id", foreignField: "product_id", as: "produit" } }, { $project: { _id: 0, event_id: 1, "produit.name": 1 } } ]).toArray()
```

**Résultat attendu** :

```text
[
  { event_id: 'E000188', produit: [ { name: 'Horizon X100' } ] },
  { event_id: 'E000192', produit: [ { name: 'Transit 24' } ] }
]
```

**Pour aller plus loin** : le résultat est toujours un **tableau**, même avec une seule correspondance, parce que rien ne garantit que `foreignField` soit unique côté cible. `$unwind` s'ajoute souvent après `$lookup` pour aplatir ce tableau. Une jointure coûte cher : dans un modèle document, on l'évite quand l'information peut vivre dans le document lui-même, et on la réserve aux cas où la donnée de référence est partagée.

## Étape 8 - Ajouter un champ calculé : `$addFields`

**Objectif** : enrichir un document sans en retirer aucun champ.

**Explication** : `$addFields` ajoute ou écrase des champs, en laissant tout le reste intact. C'est la différence avec `$project`, qui par défaut ne garde que ce qu'il nomme. Ici, on calcule un prix toutes taxes comprises à partir du prix hors taxes.

**Commande à copier-coller** :

```javascript
db.produits.aggregate([ { $match: { category: "cafe" } }, { $sort: { product_id: 1 } }, { $addFields: { prix_ttc: { $multiply: ["$price", 1.2] } } }, { $project: { _id: 0, name: 1, prix_ttc: 1 } } ]).toArray()
```

**Résultat attendu** :

```text
[
  { name: 'Altitude Éthiopie', prix_ttc: 15 },
  { name: 'Altitude Brésil', prix_ttc: 13.08 }
]
```

**Pour aller plus loin** : `$mul` n'existe pas en agrégation, on emploie `$multiply`, qui prend un **tableau** d'opérandes. Le calcul a été fait en double, d'où le `13.08` et non une valeur exacte. Les autres algorithmes utiles : `$set` est un alias moderne de `$addFields`, `$unset` retire un champ, et `$merge` écrit le résultat dans une collection — c'est la porte de sortie d'un pipeline, utiles pour matérialiser un tableau de bord.

# M7 - Indexer et mesurer

Un index est une structure de tri annexe qui évite au serveur de parcourir toute une collection pour trouver quelques documents. Sans index, MongoDB **balaye** la collection ; avec, il va droit au but. Ce module crée les principaux types d'index, puis **mesure** leur effet avec `explain`, car un index qu'on n'a pas mesuré est un index qu'on suppose.

## Étape 1 - Partir d'un état connu

**Objectif** : voir l'index qui existe toujours, et supprimer les autres.

**Explication** : toute collection possède un index sur `_id`, créé automatiquement. `getIndexes()` les liste. Pour que vos résultats soient comparables à ceux du cours, `dropIndexes()` retire tous les index **sauf** celui de `_id`, ce qui remet la collection dans son état d'origine.

**Commande à copier-coller** :

```javascript
db.produits.dropIndexes(); db.produits.getIndexes()
```

**Résultat attendu** :

```text
[
  { v: 2, key: { _id: 1 }, name: '_id_' }
]
```

**Pour aller plus loin** : l'index sur `_id` est le seul dont vous ne pouvez pas vous passer : il garantit l'unicité de l'identifiant. S'il n'en reste qu'un, c'est celui-là. Sur une collection volumineuse, `dropIndexes()` peut être coûteux ; sur ce lab, c'est instantané.

## Étape 2 - Créer un index sur un champ

**Objectif** : accélérer les filtres portant sur un champ unique.

**Explication** : `createIndex({ champ: 1 })` crée un index trié croissant ; `-1` le crée décroissant, ce qui a une importance pour les tris mais pas pour les égalités. L'index sur `category` servira à toute requête dont le filtre commence par ce champ.

**Commande à copier-coller** :

```javascript
db.produits.createIndex({ category: 1 }, { name: "idx_category" })
```

**Résultat attendu** :

```text
idx_category
```

**Pour aller plus loin** : `createIndex` renvoie le **nom** de l'index, celui qu'on pourra citer dans `dropIndex`. Sans option `name`, MongoDB en fabrique un à partir des champs. Un index sur une chaîne à faible cardinalité (peu de valeurs distinctes, ici 4 catégories pour 8 documents) apporte peu : il devient intéressant quand les valeurs sont nombreuses et le filtre sélectif.

## Étape 3 - Mesurer sans index : la lecture complète

**Objectif** : constater ce que fait MongoDB quand aucun index ne peut l'aider.

**Explication** : `explain("executionStats")` exécute la requête et rend, à côté du résultat, des statistiques. Le champ `executionStages.stage` nomme la stratégie retenue. `COLLSCAN` signifie « parcours de la collection entière » : chaque document est lu, même ceux qui ne correspondent pas. `totalDocsExamined` compte les documents réellement lus.

**Commande à copier-coller** :

```javascript
db.produits.find({ price: { $gt: 400 } }).explain("executionStats").executionStats
```

**Résultat attendu** (extrait, les champs utiles) :

```text
{
  stage: 'COLLSCAN',
  nReturned: 2,
  docsExamined: 8,
  keysExamined: 0
}
```

**Pour aller plus loin** : 8 documents lus pour 2 documents utiles : le ratio est mauvais, et il empire à mesure que la collection grandit. Sur ce lab, la différence de temps est nulle tant les données sont petites ; c'est la **stratégie** qui est le vrai signal, pas la durée en millisecondes. Aucun index n'existe sur `price`, donc le serveur n'a pas le choix.

## Étape 4 - Mesurer avec un index composé : la lecture ciblée

**Objectif** : créer un index à deux champs et vérifier que la stratégie change.

**Explication** : un index **composé** couvre plusieurs champs, dans un ordre précis. `{ category: 1, price: -1 }` sert les requêtes qui filtrent sur `category`, puis sur `price` à l'intérieur. L'ordre des champs dans l'index compte, et un index composé peut aussi servir de préfixe : il répond aux requêtes sur `category` seul.

**Commande à copier-coller** :

```javascript
db.produits.createIndex({ category: 1, price: -1 }, { name: "idx_category_price" })
```

**Résultat attendu** :

```text
idx_category_price
```

**Pour aller plus loin** : relancez maintenant `explain` sur une requête utilisant les deux champs et comparez. La commande `db.produits.find({ category: "appareil-photo", price: { $gt: 400 } }).explain("executionStats").executionStats` donne `stage: 'FETCH'` avec un `inputStage: { stage: 'IXSCAN', indexName: 'idx_category_price' }`, `docsExamined: 2`, `keysExamined: 2`. Le nombre de documents lus passe de 8 à 2 : le serveur a trouvé les bons documents **par l'index**, sans les deviner.

## Étape 5 - Chercher dans du texte : l'index `text`

**Objectif** : mettre en place une recherche par mots.

**Explication** : un index `text` découpe le contenu en mots et permet de chercher avec `$text`, opérateur distinct de `$regex`. La recherche porte sur des mots, pas sur des motifs, et le score de pertinence est calculé par le serveur. Une collection ne peut avoir qu'**un seul** index texte.

**Commande à copier-coller** :

```javascript
db.produits.createIndex({ name: "text" }, { name: "idx_name_text" })
```

**Résultat attendu** :

```text
idx_name_text
```

**Pour aller plus loin** : la recherche s'écrit `db.produits.find({ $text: { $search: "Horizon" } }, { _id: 0, name: 1, score: { $meta: "textScore" } }).sort({ score: { $meta: "textScore" } }).toArray()`, et renvoie les deux produits `Horizon`, chacun avec `score: 0.75`. Sur un vrai besoin de recherche (tolérance aux fautes, langues, facettes, synonymes), on préfère un moteur dédié comme **Atlas Search**, traité au module M13 : l'index texte de MongoDB rend service, il n'est pas un moteur de recherche complet.

## Étape 6 - Index géospatial

**Objectif** : interroger des points par proximité.

**Explication** : un index `2dsphere` interprète un champ GeoJSON de type `Point` et permet des requêtes comme « dans un rayon de X mètres ». Le champ doit contenir un objet `{ type: "Point", coordinates: [longitude, latitude] }`, dans cet ordre : longitude d'abord.

**Commande à copier-coller** :

```javascript
db.cours_geo.drop(); db.cours_geo.insertMany([ { name: "Entrepôt Lyon", location: { type: "Point", coordinates: [4.8357, 45.7640] } }, { name: "Entrepôt Paris", location: { type: "Point", coordinates: [2.3522, 48.8566] } } ]); db.cours_geo.createIndex({ location: "2dsphere" }, { name: "idx_geo" })
```

**Résultat attendu** :

```text
idx_geo
```

**Pour aller plus loin** : la requête de proximité s'écrit `db.cours_geo.find({ location: { $near: { $geometry: { type: "Point", coordinates: [4.84, 45.76] }, $maxDistance: 50000 } } }, { _id: 0, name: 1 }).toArray()`, et renvoie `[ { name: 'Entrepôt Lyon' } ]` : seul l'entrepôt lyonnais tombe dans les 50 kilomètres. `$near` exige un index géospatial, sans quoi la requête échoue. `$maxDistance` s'exprime en mètres sur une sphère.

## Étape 7 - Expiration automatique : l'index TTL

**Objectif** : faire supprimer des documents par le temps, sans tâche applicative.

**Explication** : un index à `expireAfterSeconds` fait supprimer les documents dont la date de référence dépasse le délai. `expireAfterSeconds: 0` signifie « à partir de la date indiquée », ce qui laisse décider document par document. C'est l'outil des données temporaires : jetons de session, caches, paniers abandonnés.

**Commande à copier-coller** :

```javascript
db.cours_ttl.drop(); db.cours_ttl.insertOne({ code: "TEMP-1", expires_at: new Date(Date.now() - 3600 * 1000) }); db.cours_ttl.createIndex({ expires_at: 1 }, { expireAfterSeconds: 0, name: "idx_ttl" }); db.cours_ttl.getIndexes()
```

**Résultat attendu** :

```text
[
  { v: 2, key: { _id: 1 }, name: '_id_' },
  { v: 2, key: { expires_at: 1 }, name: 'idx_ttl', expireAfterSeconds: 0 }
]
```

**Pour aller plus loin** : la suppression n'est **pas immédiate**. Un processus de fond passe environ toutes les minutes : `db.cours_ttl.countDocuments()` peut afficher `1` juste après la création de l'index, puis `0` une minute plus tard. Inspecter `getIndexes()` prouve la mise en place sans attendre. Un index TTL ne fonctionne que sur un champ de type **date** : sur une chaîne, il ne se passe rien.

## Étape 8 - Supprimer un index

**Objectif** : revenir à l'état initial et comprendre le coût d'un index.

**Explication** : `dropIndex("nom")` supprime un index précis, `dropIndexes()` les supprime tous sauf celui de `_id`. Un index n'est pas gratuit : il occupe de l'espace et ralentit chaque écriture, puisque MongoDB doit le mettre à jour en même temps que le document.

**Commande à copier-coller** :

```javascript
db.produits.dropIndexes(); db.produits.getIndexes()
```

**Résultat attendu** :

```text
[
  { v: 2, key: { _id: 1 }, name: '_id_' }
]
```

**Pour aller plus loin** : la règle d'arbitrage est simple, mais elle se mesure. Créez un index pour une requête **lente et fréquente** ; ne le créez pas par principe sur tous les champs. `explain` est le juge : il montre la stratégie (`COLLSCAN` ou `IXSCAN`) et le nombre de documents lus (`totalDocsExamined`). Un index utile fait baisser ce dernier chiffre ; un index inutile le laisse identique tout en coûtant à l'écriture. Le module M8 approfondit cette méthode avec les index partiels, couvrants et le profil de requêtes.

# M8 - Optimiser une requête

Un index créé n'est pas un index utile. Ce module mesure, puis affine : index partiel, index couvrant, plan forcé, et les outils qui révèlent les requêtes lentes. La règle est constante : on ne suppose pas qu'une requête est rapide, on le lit dans `explain`.

## Étape 1 - Index partiel : n'indexer qu'une partie des documents

**Objectif** : réduire la taille d'un index sans perdre l'accès rapide sur les documents utiles.

**Explication** : `partialFilterExpression` limite l'index aux documents qui satisfont une condition. Ici, on n'indexe le prix que des produits actifs. L'index est plus petit, coûte moins cher à l'écriture, et sert les requêtes qui filtrent aussi sur `active: true`. Il ne sert **pas** une requête sans cette condition, qui retombe en lecture complète.

**Commande à copier-coller** :

```javascript
db.produits.dropIndexes(); db.produits.createIndex({ price: 1 }, { name: "idx_price_actif", partialFilterExpression: { active: true } })
```

**Résultat attendu** :

```text
idx_price_actif
```

**Pour aller plus loin** : la comparaison des deux plans est le vrai enseignement.

```javascript
db.produits.find({ price: { $gt: 400 }, active: true }).explain("executionStats").executionStats
```

donne `stage: 'FETCH'` sur `idx_price_actif` avec `docsExamined: 2`, alors que la même requête sans `active: true` donne `stage: 'COLLSCAN'` avec `docsExamined: 8`. L'index partiel est invisible à la requête qui ne porte pas la condition : c'est le compromis à connaître.

## Étape 2 - Index couvrant : ne pas toucher les documents

**Objectif** : répondre à une requête uniquement depuis l'index.

**Explication** : un index est dit **couvrant** quand il contient tous les champs demandés. Le serveur lit alors l'index seul et n'ouvre aucun document. La projection doit exclure `_id` (qui n'est pas dans l'index) et ne demander que des champs indexés.

**Commande à copier-coller** :

```javascript
db.produits.createIndex({ category: 1, name: 1 }, { name: "idx_cat_name" })
```

**Résultat attendu** :

```text
idx_cat_name
```

**Pour aller plus loin** : la preuve est nette.

```javascript
db.produits.find({ category: "cafe" }, { _id: 0, category: 1, name: 1 }).explain("executionStats").executionStats
```

affiche `executionStages.stage: 'PROJECTION_COVERED'`, un `inputStage` `IXSCAN`, et surtout `totalDocsExamined: 0`. Zéro document ouvert pour deux documents rendus : c'est le meilleur résultat possible. Ajoutez un champ absent de l'index (par exemple `price`) et le plan redevient `FETCH` avec des documents lus.

## Étape 3 - Forcer un index : `hint`

**Objectif** : comparer deux plans en imposant le chemin d'accès.

**Explication** : le planificateur choisit seul l'index, et il se trompe parfois sur des collections à statistiques pauvres. `hint` impose un index. C'est un outil de diagnostic et d'arbitrage, rarement une solution permanente.

**Commande à copier-coller** :

```javascript
db.produits.find({ category: "cafe" }).hint({ category: 1, name: 1 }).explain("executionStats").executionStats
```

**Résultat attendu** (extrait) :

```text
{
  stage: 'FETCH',
  inputStage: 'IXSCAN',
  indexName: 'idx_cat_name',
  docsExamined: 2
}
```

**Pour aller plus loin** : un `hint` vers un index inexistant fait échouer la requête (`bad hint`), ce qui en fait aussi un test de présence d'index. En production, on le réserve aux cas documentés où le planificateur choisit mal, et on vérifie à chaque montée de version : un index qui aidait hier peut devenir inutile demain.

## Étape 4 - Les niveaux de détail d'`explain`

**Objectif** : choisir la verbosité du diagnostic.

**Explication** : `explain` sans argument donne `queryPlanner` (le plan retenu, sans exécution) ; `"executionStats"` exécute et ajoute les compteurs ; `"allPlansExecution"` exécute aussi les plans écartés, utile pour comprendre pourquoi le planificateur a tranché.

**Commande à copier-coller** :

```javascript
db.produits.find({ category: "cafe" }).explain("queryPlanner").queryPlanner.winningPlan.queryPlan.stage
```

**Résultat attendu** :

```text
'FETCH'
```

**Pour aller plus loin** : `queryPlanner` ne consomme rien et suffit à vérifier qu'un index est candidat. `executionStats` coûte une exécution réelle : ne le lancez pas sur une requête de production lourde. `allPlansExecution` multiplie ce coût par le nombre de plans essayés, et se réserve à l'atelier.

## Étape 5 - Profiler les requêtes lentes

**Objectif** : enregistrer ce que le serveur exécute réellement.

**Explication** : le profileur écrit dans la collection `system.profile` les opérations qui dépassent un seuil. Le niveau 1 n'enregistre que les lentes (`slowms`, 100 ms par défaut), le niveau 2 enregistre tout. Le niveau 2 se réserve à une session d'analyse courte : il ralentit le serveur.

**Commande à copier-coller** :

```javascript
db.setProfilingLevel(2)
```

**Résultat attendu** :

```text
{ was: 0, slowms: 100, sampleRate: 1, ok: 1 }
```

**Pour aller plus loin** : exécutez une requête, puis lisez le journal. Après `db.produits.find({ category: "cafe", price: { $gt: 5 } }).toArray()`, la commande

```javascript
db.system.profile.find({ ns: "formation_nosql.produits" }, { op: 1, "command.filter": 1, millis: 1, _id: 0 }).sort({ ts: -1 }).limit(1).toArray()
```

renvoie l'opération `query` avec son filtre et son temps. Terminez toujours par `db.setProfilingLevel(0)`. En production, on utilise plutôt le niveau 1, ou le profileur seulement sur une base d'analyse.

## Étape 6 - Surveiller en continu : `mongostat` et `mongotop`

**Objectif** : observer l'activité du serveur en temps réel.

**Explication** : `mongostat` affiche un tableau périodique des opérations par seconde (insertions, lectures, connexions, réseau). `mongotop` classe les collections par temps passé en lecture et en écriture. L'option `-n 1` limite à une ligne, ce qui rend la commande utilisable dans un cours.

**Commande à copier-coller** :

```
docker compose exec mongodb mongostat --quiet -n 1
```

**Résultat attendu** (extrait) :

```text
insert query update delete getmore command  vsize  res net_in net_out conn
    *0    *0     *0     *0       0     1|0  590M 191M   112b   73.8k    3
```

**Pour aller plus loin** : `mongotop -n 1` liste les collections par temps consommé, ce qui désigne la table chaude du moment. Ces deux outils répondent à « que se passe-t-il maintenant », quand `explain` répond à « pourquoi cette requête est lente ». Le module M12 revient sur la configuration du serveur.

## Étape 7 - Régler un paramètre à chaud

**Objectif** : modifier un réglage du serveur sans redémarrage, et mesurer l'effet côté moteur de stockage.

**Explication** : `setParameter` change certains réglages en mémoire. Tous ne sont pas modifiables à chaud : les paramètres de structure (mémoire allouée au moteur WiredTiger, activation de l'authentification, TLS) exigent un redémarrage et un fichier de configuration.

**Commande à copier-coller** :

```javascript
db.adminCommand({ setParameter: 1, logLevel: 1 })
```

**Résultat attendu** :

```text
{ was: 0, ok: 1 }
```

**Pour aller plus loin** : `db.adminCommand({ getParameter: 1, logLevel: 1 }).logLevel` relit la valeur, et `{ setParameter: 1, logLevel: 0 }` la rétablit. Pour voir la mémoire allouée au moteur de stockage, `db.serverStatus().wiredTiger.cache["maximum bytes configured"]` affiche la taille du cache, ici environ 3,6 Go sur cette machine. C'est un paramètre de démarrage, jamais modifiable à chaud.

# M9 - Transactions et garanties

Une transaction regroupe plusieurs écritures en une seule unité : soit toutes passent, soit aucune. MongoDB ne les accepte que sur un **replica set**, car la transaction s'appuie sur le journal de réplication. Ce module démarre donc un nœud replica set, puis manipule une transaction.

> [!info] Pourquoi un replica set
> Une transaction a besoin d'un journal des opérations pour être rejouée ou annulée. Un serveur isolé (le service `mongodb` du lab) n'en tient pas : la commande échouerait avec « Transaction numbers are only allowed on a replica set member or mongos ». Le lab fournit un nœud dédié, sous le profil `rs`, qui ne perturbe pas le serveur du reste du cours.

## Étape 1 - Démarrer et initialiser le nœud replica set

**Objectif** : obtenir un serveur capable d'exécuter des transactions.

**Explication** : le script démarre le service `mongodb-rs` et l'initialise comme replica set à un seul membre. Sur un nœud unique, l'élection est immédiate : il devient primaire.

**Commande à copier-coller** :

```
sh scripts/init-rs.sh
```

**Résultat attendu** :

```text
[ { name: '127.0.0.1:27017', state: 'PRIMARY' } ]
```

**Pour aller plus loin** : le script est idempotent, relancer ne casse rien. Puis ouvrez une session sur ce serveur, c'est celle qui sert pour tout le module.

```
docker compose exec mongodb-rs mongosh "mongodb://localhost:27017/boutique"
```

## Étape 2 - Lire l'état de la réplication

**Objectif** : vérifier la topologie avant d'écrire.

**Explication** : `rs.status()` décrit les membres, leur état et leur rôle. Sur un nœud, tout est simple, mais c'est exactement la commande qu'on lance pour diagnostiquer un cluster réel.

**Commande à copier-coller** :

```javascript
rs.status().members.map(m => ({ name: m.name, state: m.stateStr }))
```

**Résultat attendu** :

```text
[ { name: '127.0.0.1:27017', state: 'PRIMARY' } ]
```

**Pour aller plus loin** : `rs.conf()` donne la configuration déclarée, distincte de l'état observé. Un membre peut être déclaré mais indisponible : `rs.conf()` le liste, `rs.status()` dit s'il répond.

## Étape 3 - Une transaction qui valide

**Objectif** : déplacer une valeur entre deux documents, en une seule opération.

**Explication** : une session ouvre la transaction. Les opérations s'exécutent dans la session, pas dans la connexion principale, puis `commitTransaction()` valide l'ensemble. Le virement est l'exemple canonique : débiter sans créditer serait un vol, et deux écritures séparées n'offrent aucune garantie entre elles.

**Commande à copier-coller** :

```javascript
db.comptes.drop(); db.comptes.insertMany([ { _id: "A", solde: 1000 }, { _id: "B", solde: 500 } ])
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedIds: { '0': 'A', '1': 'B' } }
```

**Pour aller plus loin** : la transaction elle-même se colle d'un bloc.

```javascript
const session = db.getMongo().startSession();
session.startTransaction();
session.getDatabase("boutique").comptes.updateOne({ _id: "A" }, { $inc: { solde: -100 } });
session.getDatabase("boutique").comptes.updateOne({ _id: "B" }, { $inc: { solde: 100 } });
session.commitTransaction();
```

`db.comptes.find().sort({ _id: 1 }).toArray()` donne alors `A: 900` et `B: 600`. Aucun état intermédiaire n'a été visible de l'extérieur : la lecture ne voit jamais 1000 et 500 à moitié modifiés.

## Étape 4 - Une transaction qui annule

**Objectif** : vérifier qu'une transaction abandonnée ne laisse aucune trace.

**Explication** : `abortTransaction()` annule toutes les écritures de la session. C'est le retour arrière automatique sur erreur : en cas d'échec d'une des étapes, l'application annule et rien n'est écrit.

**Commande à copier-coller** :

```javascript
const session = db.getMongo().startSession();
session.startTransaction();
session.getDatabase("boutique").comptes.updateOne({ _id: "A" }, { $inc: { solde: -9999 } });
session.abortTransaction();
```

**Résultat attendu** : après la commande, `db.comptes.find().sort({ _id: 1 }).toArray()` affiche toujours `A: 900` et `B: 600`. Le débit de 9999 n'a jamais existé.

**Pour aller plus loin** : la transaction a une durée de vie limitée (`transactionLifetimeLimitSeconds`, 60 secondes par défaut). Au-delà, le serveur l'annule. Une transaction ne doit contenir que des opérations courtes : garder une transaction ouverte pendant un appel réseau externe bloque des versions de documents et fait grossir le cache.

## Étape 5 - Acquittement et lecture : ce qui est garanti, et quand

**Objectif** : comprendre les deux réglages qui décident de la solidité d'une écriture.

**Explication** : `writeConcern` dit **combien de copies** doivent avoir écrit avant que le serveur réponde (`w: 1` une seule, `w: "majority"` la majorité des membres). `readConcern` dit **quelle fraîcheur** une lecture exige (`local` ce que ce nœud a, `majority` ce qui est confirmé par la majorité). Les deux se règlent par opération ou par défaut.

**Commande à copier-coller** :

```javascript
db.comptes.insertOne({ _id: "C", solde: 0 }, { writeConcern: { w: "majority", wtimeout: 5000 } })
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: 'C' }
```

**Pour aller plus loin** : sans replica set, `w: "majority"` retombe sur `w: 1`, et la garantie est vide : c'est le piège des environnements de test. Les pilotes activent par défaut `retryWrites`, qui rejoue automatiquement une écriture dont la réponse s'est perdue — utile, mais uniquement sur des opérations **idempotentes** : rejouer un `$inc` sans précaution compterait deux fois. Le module M10 montre ce qui se passe quand un membre disparaît.

# M10 - Distribuer

Deux mécanismes distincts, souvent confondus. La **réplication** copie la même donnée sur plusieurs serveurs pour survivre à une panne. Le **partitionnement** découpe une collection entre plusieurs serveurs pour absorber la charge. Le premier protège, le second répartit, et aucun ne remplace l'autre.

## Étape 1 - Lire le retard de réplication

**Objectif** : observer le journal qui rend la réplication possible.

**Explication** : le **oplog**, une collection de la base `local`, enregistre chaque écriture. Un membre secondaire le relit et rejoue les opérations pour se mettre à jour. `rs.printReplicationInfo()` résume la fenêtre couverte par cet oplog : combien de temps un secondaire peut rester en retard avant de ne plus pouvoir rattraper.

**Commande à copier-coller** :

```javascript
rs.printReplicationInfo()
```

**Résultat attendu** (extrait, les dates dépendent du moment) :

```text
oplog first event time
'Thu Sep 17 2026 17:02:24 GMT+0000 (Coordinated Universal Time)'
---
oplog last event time
'Thu Sep 17 2026 17:17:18 GMT+0000 (Coordinated Universal Time)'
```

**Pour aller plus loin** : `db.getSiblingDB("local").oplog.rs.countDocuments()` compte les entrées (631 sur ce serveur après quelques minutes d'usage), et `db.getSiblingDB("local").oplog.rs.stats().maxSize` donne sa taille maximale, ici environ 2,3 Go. Un oplog trop petit fait sortir un secondaire trop lent de l'historique : il doit alors se resynchroniser intégralement, ce qui coûte bien plus cher.

## Étape 2 - Démarrer le mini-cluster shardé

**Objectif** : obtenir un cluster fonctionnel : deux shards, un serveur de configuration, un routeur.

**Explication** : un cluster shardé a trois rôles. Les **shards** stockent les données (chacun est lui-même un replica set). Les **serveurs de configuration** gardent la carte des chunks. Le **mongos** est le routeur : c'est lui auquel l'application se connecte, et c'est lui qui décide quel shard interroger. Le script initialise l'ensemble dans le bon ordre.

**Commande à copier-coller** :

```
sh scripts/init-sharding.sh
```

**Résultat attendu** :

```text
[
  'shard1rs -> shard1rs/shard1:27017',
  'shard2rs -> shard2rs/shard2:27017'
]
```

**Pour aller plus loin** : cette étape est la plus lourde du cours (quatre conteneurs, plusieurs minutes au premier démarrage). Sur un poste à court de mémoire, elle peut être remplacée par la seule lecture des étapes suivantes, qui montrent les résultats obtenus ailleurs. `docker compose --profile cluster down` arrête et libère le cluster ; `-v` en plus efface ses données.

## Étape 3 - Sharder par plage, et constater que rien ne bouge

**Objectif** : comprendre qu'une clé de shard par plage ne répartit pas mécaniquement.

**Explication** : `sh.enableSharding` autorise le partitionnement sur une base, `sh.shardCollection` choisit la clé. Avec une clé par plage sur `category`, MongoDB découpe l'intervalle des catégories en chunks. Tant que les données sont peu nombreuses, un seul chunk suffit : tout reste sur un seul shard. La répartition est un effet du **volume**, pas de la commande.

**Commande à copier-coller** :

```javascript
sh.enableSharding("boutique"); sh.shardCollection("boutique.produits", { category: 1 })
```

**Résultat attendu** (extrait, MongoDB ajoute un horodatage de cluster non montré ici) :

```text
{ ok: 1 }
{ collectionsharded: 'boutique.produits', ok: 1 }
```

**Pour aller plus loin** : vérifiez par `db.produits.getShardDistribution()` après quelques insertions. Sur ce cluster, la collection montre `docs: 9, chunks: 1` sur `shard1rs` uniquement : le chunk unique n'a pas été découpé. C'est le comportement attendu, et l'erreur d'appréciation la plus fréquente sur le partitionnement.

## Étape 4 - Sharder par hachage, et voir la répartition

**Objectif** : obtenir une distribution équilibrée dès le départ.

**Explication** : une clé **hachée** (`{ _id: "hashed" }`) hache la valeur avant de la placer, ce qui disperse les documents uniformément. Le cluster pré-découpe alors des chunks sur chaque shard, sans attendre le volume. C'est le choix adapté à une clé d'identifiant sans ordre naturel.

**Commande à copier-coller** :

```javascript
sh.shardCollection("boutique.evenements", { _id: "hashed" })
```

**Résultat attendu** (extrait) :

```text
{ collectionsharded: 'boutique.evenements', ok: 1 }
```

**Pour aller plus loin** : insérez 200 documents (par exemple `Array.from({ length: 200 }, (_, i) => ({ event_id: "E" + i }))`), puis `db.evenements.getShardDistribution()` montre `docs: 100` sur `shard1rs` et `docs: 100` sur `shard2rs`, 2 chunks chacun. La répartition est immédiate et équilibrée, ce que la clé par plage n'avait pas donné.

## Étape 5 - Choisir une clé de shard : ce qui ne se rattrape pas

**Objectif** : savoir pourquoi la clé de shard est une décision structurante.

**Explication** : une clé par plage concentre les écritures sur le dernier chunk si les valeurs montent (un horodatage, un identifiant croissant) : c'est un **point chaud**, et un seul shard absorbe tout le trafic. Une clé hachée répartit les écritures mais interdit les requêtes par plage efficaces, car l'ordre est détruit. Une clé composée cherche un compromis. Le choix se fait **avant** le premier document, et le changer demande de réécrire toute la collection.

**Commande à copier-coller** :

```javascript
db.getSiblingDB("config").collections.find({}, { _id: 1, key: 1 }).toArray()
```

**Résultat attendu** : les collections partitionnées et leur clé (`config.system.sessions` est une collection interne, présente elle aussi).

```text
[
  { _id: 'config.system.sessions', key: { _id: 1 } },
  { _id: 'boutique.produits', key: { category: 1 } },
  { _id: 'boutique.evenements', key: { _id: 'hashed' } }
]
```

**Pour aller plus loin** : trois conséquences à retenir. Une requête sans la clé de shard est diffusée à tous les shards (`scatter-gather`) et coûte le prix du plus lent. Chaque shard est un replica set : la réplication et le partitionnement se cumulent. Enfin, `mongos` ne stocke rien : on peut en lancer plusieurs pour répartir les connexions, et aucun ne devient un point de panne unique. Sur un vrai projet, le partitionnement s'ajoute quand un seul serveur ne suffit plus ; il ne se pose pas au démarrage.

# M11 - Sécuriser

Par défaut, le serveur du lab n'exige aucun identifiant : quiconque atteint le port `27017` peut tout lire et tout écrire. Ce module active les quatre couches qui protègent une base : **authentification** (qui es-tu), **autorisation** (as-tu le droit), **chiffrement du transport** (TLS) et **chiffrement des données** (au repos ou côté client), puis la **piste d'audit** (qui a fait quoi). Les trois premières et le chiffrement côté client sont exécutables ici ; le reste dépend de l'offre ou de l'infrastructure, et est présenté comme tel.

## Étape 1 - Démarrer un serveur en authentification

**Objectif** : obtenir un serveur qui refuse les connexions anonymes.

**Explication** : l'option `--auth` active le contrôle d'accès. Sans aucun utilisateur déclaré, mongod autorise une seule opération depuis la machine locale : créer le premier compte, dit administrateur. C'est l'« exception localhost », et elle se referme dès que ce compte existe.

**Commande à copier-coller** :

```
sh scripts/init-auth.sh
```

**Résultat attendu** :

```text
administrateur créé
```

**Pour aller plus loin** : le script est idempotent, mais comprendre la mécanique compte : l'exception localhost ne permet **que** `createUser` sur la base `admin` — pas de lecture, pas de `getUsers`. C'est pourquoi la création est tentée directement, sans vérification préalable. Le serveur en authentification est un service distinct du reste du cours : il démarre sur son propre volume, vide au départ.

## Étape 2 - Constater le refus sans identifiants

**Objectif** : vérifier que l'authentification est réellement appliquée.

**Explication** : sur le serveur authentifié, une opération sans identifiants est rejetée avec le code `Unauthorized`. La commande `ping` reste, elle, autorisée sans droits : c'est elle qui sert aux contrôles de santé des orchestrateurs.

**Commande à copier-coller** :

```
docker compose exec mongodb-auth mongosh "mongodb://localhost:27017/formation_nosql" --eval "db.produits.countDocuments()"
```

**Résultat attendu** :

```text
MongoServerError: Command aggregate failed: Unauthorized: not authorized on formation_nosql to execute command { aggregate: "produits", ... }
```

**Pour aller plus loin** : le message complet donne `code: 13, codeName: 'Unauthorized'`. Une application qui reçoit ce code a un problème de droits, pas de connexion : le diagnostic est différent, et la confusion coûte du temps. Le serveur, lui, répond très bien — il refuse l'opération.

## Étape 3 - Se connecter avec l'administrateur

**Objectif** : authentifier une session et observer l'identité reconnue.

**Explication** : la chaîne de connexion porte l'utilisateur, le mot de passe et la base qui contient les comptes (`authSource=admin`). L'utilisateur `admin` a le rôle `root`, donc tous les droits.

**Commande à copier-coller** :

```
docker compose exec mongodb-auth mongosh "mongodb://admin:Change3Moi!@localhost:27017/formation_nosql?authSource=admin" --eval "printjson(db.produits.insertOne({ product_id: 'P999', name: 'Produit de controle', price: 1 }))"
```

**Résultat attendu** :

```text
{ acknowledged: true, insertedId: ObjectId('...') }
```

**Pour aller plus loin** : `db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers` affiche `[ { user: 'admin', db: 'admin' } ]` : c'est l'identité que le serveur applique réellement à cette session. Le mot de passe en clair dans la commande est un choix de démonstration locale : en production, il vient d'un secret injecté par l'environnement, jamais du code ni de l'historique du shell.

## Étape 4 - Un compte à droits limités

**Objectif** : appliquer le principe du moindre privilège.

**Explication** : un rôle intégré comme `readWrite` sur **une seule base** suffit à la plupart des applications. L'utilisateur lit et écrit ses collections, et rien de plus : les autres bases, l'administration et les commandes de serveur lui restent fermées.

**Commande à copier-coller** :

```
docker compose exec mongodb-auth mongosh "mongodb://admin:Change3Moi!@localhost:27017/admin?authSource=admin" --eval "db.createUser({ user: 'lecteur_nosql', pwd: 'Lecture1Seule', roles: [ { role: 'readWrite', db: 'formation_nosql' } ] })"
```

**Résultat attendu** :

```text
{ ok: 1 }
```

**Pour aller plus loin** : deux vérifications montrent le périmètre. Avec ce compte, `db.produits.countDocuments()` renvoie `1` (le document de contrôle) : la lecture passe. Mais une écriture dans `admin`, par exemple

```javascript
db.getSiblingDB("admin").demain.insertOne({ x: 1 })
```

échoue avec `Unauthorized : not authorized on admin to execute command { insert: "demain" ... }`. Le compte ne peut écrire que là où son rôle le dit. C'est exactement la garantie à vérifier avant de livrer une application.

## Étape 5 - Chiffrer le transport avec TLS

**Objectif** : rendre le chiffrement obligatoire sur le réseau.

**Explication** : `--tlsMode requireTLS` refuse toute connexion en clair. Le lab fournit une image qui génère un certificat auto-signé à sa construction. Depuis MongoDB 7, servir en TLS exige aussi de déclarer une chaîne de confiance (`--tlsCAFile`) : un certificat seul ne suffit plus.

**Commande à copier-coller** :

```
docker compose --profile tls up -d --build mongodb-tls
```

**Résultat attendu** : le conteneur atteint l'état `healthy`, puis la connexion chiffrée répond.

```text
{ ping: 1 }
```

**Pour aller plus loin** : la connexion se fait par `docker compose exec mongodb-tls mongosh --tls --tlsAllowInvalidCertificates --eval "db.adminCommand({ ping: 1 })"`. L'option `--tlsAllowInvalidCertificates` n'est là que parce que le certificat est auto-signé : un client qui ne connaît pas l'autorité de certification rejette le certificat, à raison. En production, le certificat vient d'une autorité reconnue et cette option disparaît. Une connexion **sans** TLS sur ce serveur échoue avec `MongoServerSelectionError: connection closed` : le serveur ferme avant même de répondre.

## Étape 6 - Kerberos, LDAP et certificats clients : quand l'infrastructure décide

**Objectif** : situer les authentifications d'entreprise sans les confondre avec un mot de passe applicatif.

**Explication** : trois mécanismes se rencontrent en organisation. **Kerberos** (`GSSAPI`) authentifie l'utilisateur d'un annuaire Active Directory, sans mot de passe stocké dans l'application. **LDAP** délègue la vérification à un annuaire, avec un serveur mandataire dédié. Le **certificat client x509** authentifie une machine ou un service par un certificat, souvent sans mot de passe du tout. Dans les trois cas, MongoDB ne détient pas les identités : il interroge une autorité qui les connaît.

**Commande à copier-coller** :

```javascript
db.adminCommand({ getParameter: 1, authenticationMechanisms: 1 }).authenticationMechanisms
```

**Résultat attendu** : les mécanismes compilés dans ce serveur.

```text
[ 'MONGODB-X509', 'SCRAM-SHA-1', 'SCRAM-SHA-256' ]
```

**Pour plus de détail** : `SCRAM-SHA-256` est le mécanisme par mot de passe utilisé aux étapes 1 à 4. `MONGODB-X509` est la brique du certificat client, activable ici avec les bons certificats. **Kerberos et LDAP, eux, n'apparaissent pas** : ils exigent le serveur en édition Enterprise, un annuaire Kerberos ou un serveur LDAP, et des certificats d'infrastructure. Aucune de ces briques n'existe dans un conteneur isolé : la manipulation n'est donc pas faisable dans ce lab, et le cours ne la simule pas.

## Étape 7 - Chiffrement au repos et Queryable Encryption

**Objectif** : distinguer deux protections que le serveur seul ne peut pas démontrer.

**Explication** : le **chiffrement au repos** protège les fichiers de données si le disque est volé : c'est le moteur de stockage qui déchiffre en lisant. Il dépend d'un module de gestion de clés (KMIP) ou d'un fichier de clé, et relève de l'édition Enterprise. La **Queryable Encryption** chiffre certains champs tout en permettant de les interroger par égalité, sans les déchiffrer côté serveur ; elle exige Atlas ou Enterprise. Ces deux protections se configurent au déploiement, pas dans le shell.

**Commande à copier-coller** : aucune commande locale ne peut l'activer ou la vérifier dans ce conteneur. La documentation officielle décrit la configuration.

```text
https://www.mongodb.com/docs/manual/core/security-encryption-at-rest/
https://www.mongodb.com/docs/manual/core/queryable-encryption/
```

**Résultat attendu** : pas de sortie. L'objectif de l'étape est de savoir **pourquoi** elle n'est pas exécutable ici : ces fonctions ne sont pas compilées dans l'image Community, et leur activation dépend d'un service de clés externe.

**Pour aller plus loin** : la distinction à retenir est le **moment** du chiffrement. Au repos, le serveur voit le clair et le disque est protégé. Côté client (étape 8), le serveur ne voit jamais le clair. Queryable Encryption rapproche les deux : le serveur manipule des données chiffrées tout en répondant à des requêtes d'égalité.

## Étape 8 - Chiffrer côté client, avec un pilote

**Objectif** : chiffrer un champ avant même qu'il atteigne le serveur.

**Explication** : en chiffrement côté client **explicite**, l'application appelle `encrypt` et `decrypt`. Le serveur ne reçoit que des octets. La clé maîtresse ne quitte jamais le client : en production elle vit dans un service de clés (KMS), ici un fichier local pour la démonstration. Le chiffrement **automatique**, où le pilote applique un schéma sans appel explicite, exige Enterprise ou Atlas.

**Commande à copier-coller** :

```
docker compose --profile driver run --rm driver /lab/demos/csfle-demo.py
```

**Résultat attendu** :

```text
Type stocké dans la base : Binary | longueur : 98 octets
Valeur telle que la voit le serveur : 019a27b54ff5944a42bba722e82cb58fbb028630a7ba4eb6 ...
Déchiffré par le client : 06 00 00 00 02
```

**Pour aller plus loin** : le script est dans `demos/csfle-demo.py`. Il montre l'aller-retour complet : création d'une clé de données, chiffrement d'un numéro de téléphone, écriture, relecture, déchiffrement. La longueur stockée (98 octets) est le signe que la valeur est bien chiffrée : un numéro en clair tiendrait en quinze caractères. Le serveur, lui, ne pourrait pas relire la valeur sans la clé. C'est la protection la plus forte du module, et la seule qui reste efficace même si le serveur entier est compromis.

## Étape 9 - La piste d'audit

**Objectif** : savoir qui a fait quoi, et pourquoi cette trace n'est pas native partout.

**Explication** : l'**audit** enregistre les actions sensibles : connexions, exécution de commandes, création ou suppression d'utilisateurs, modification de rôles. MongoDB sait l'écrire vers un fichier, `syslog`, la console, ou vers Atlas. C'est une fonction d'édition **Enterprise** (et d'Atlas) : elle n'est pas compilée dans l'image Community, et un filtre `--auditFilter` ne peut donc pas être activé ici.

**Commande à copier-coller** : aucune commande locale ne peut activer l'audit dans ce conteneur. Les options et le format sont décrits dans la documentation officielle.

```text
https://www.mongodb.com/docs/manual/core/auditing/
https://www.mongodb.com/docs/atlas/database-auditing/
```

**Résultat attendu** : pas de sortie. L'étape répond à « où regarder », pas à « quelle commande lancer » : l'audit se configure au démarrage du serveur, comme l'authentification et TLS.

**Pour aller plus loin** : sans audit natif, une base Community laisse tout de même des traces, à condition de les activer. Le **profileur** vu au module M8 enregistre les opérations qui ont dépassé un seuil, y compris leur auteur. Les **journaux du serveur** gardent les connexions, les échecs d'authentification et les changements de configuration ; `db.adminCommand({ getLog: "global" })` en montre les dernières lignes. Et `db.runCommand({ connectionStatus: 1 })` dit, pour une session donnée, l'identité reconnue. Ce n'est pas de l'audit au sens strict — rien n'est signé ni infalsifiable — mais c'est ce qui permet de reconstituer une action. En environnement réglementé, cette insuffisance suffit à justifier Enterprise ou Atlas.

# M12 - Sauvegarder et exploiter

Sauvegarder n'est pas copier la base : une sauvegarde MongoDB se fait à chaud, avec des outils dédiés, et se restaure en le vérifiant. Ce module sauvegarde, casse, restaure, puis examine la configuration du serveur.

## Étape 1 - Sauvegarder une collection

**Objectif** : produire une sauvegarde à chaud d'une collection.

**Explication** : `mongodump` lit le serveur en service et écrit un fichier BSON par collection, plus un fichier de métadonnées qui décrit les index. Aucun arrêt du serveur n'est nécessaire.

**Commande à copier-coller** :

```
docker compose exec mongodb mongodump --db=formation_nosql --collection=evenements --out=/tmp/sauvegarde
```

**Résultat attendu** :

```text
writing `formation_nosql.evenements` to `/tmp/sauvegarde/formation_nosql/evenements.bson`
done dumping `formation_nosql.evenements` (16 documents)
```

**Pour aller plus loin** : le fichier écrit est binaire (`.bson`), accompagné de `evenements.metadata.json`. L'option `--gzip` compresse la sortie, et `--archive` produit un fichier unique au lieu d'une arborescence. Retenez le pair d'outils : `mongodump` pour sauvegarder, `mongorestore` pour restaurer ; `mongoexport` et `mongoimport`, eux, échangent du JSON lisible, pour l'échange de données, pas pour une sauvegarde fidèle.

## Étape 2 - Restaurer et vérifier

**Objectif** : restaurer une sauvegarde et prouver que les données sont revenues.

**Explication** : `mongorestore` relit l'arborescence produite par `mongodump`. `--drop` supprime la collection existante avant de restaurer, ce qui évite les doublons. `--nsInclude` cible précisément la collection à réintroduire.

**Commande à copier-coller** : d'abord constater la perte, en supprimant les événements du canal `web`.

```javascript
db.evenements.deleteMany({ channel: "web" })
```

**Résultat attendu** :

```text
{ acknowledged: true, deletedCount: 8 }
```

**Pour aller plus loin** : restaurez, puis comptez.

```
docker compose exec mongodb mongorestore --drop --nsInclude="formation_nosql.evenements" /tmp/sauvegarde
```

donne `16 document(s) restored successfully. 0 document(s) failed to restore.`, et `db.evenements.countDocuments()` retrouve `16`. **Une sauvegarde qu'on n'a jamais restaurée n'est pas une sauvegarde** : c'est l'objet même de cette étape. En production, on restaure à blanc régulièrement, sur un serveur séparé, en chronométrant l'opération : c'est ce temps qui décide si le plan de reprise est crédible.

## Étape 3 - Sauvegarder toute la base en une archive

**Objectif** : produire un artefact unique, déplaçable.

**Explication** : l'option `--archive` remplace l'arborescence par un flux unique, qu'on peut écrire sur un disque, envoyer à un stockage d'objets ou piper vers une compression. C'est la forme adaptée à une sauvegarde planifiée.

**Commande à copier-coller** :

```
docker compose exec mongodb mongodump --db=formation_nosql --archive=/tmp/formation_nosql.archive --gzip
```

**Résultat attendu** : la commande se termine sans erreur et écrit `/tmp/formation_nosql.archive`. La restauration équivalente est `mongorestore --gzip --archive=/tmp/formation_nosql.archive --drop`.

**Pour aller plus loin** : les sauvegardes cohérentes d'un **cluster** ou d'un replica set ne se font pas base par base : on consulte l'heure de l'oplog avant et après la sauvegarde (`--oplog`) pour pouvoir restaurer une tranche cohérente. Sur Atlas, c'est le service qui gère les sauvegardes continues. Le principe reste le même : on sauvegarde, puis on **teste** la restauration.

## Étape 4 - Comprendre la configuration du serveur

**Objectif** : relier le comportement du serveur à ses options de démarrage.

**Explication** : un serveur MongoDB se configure par un fichier (`/etc/mongod.conf`) ou par des options de ligne de commande. Dans ce lab, c'est le `compose.yaml` qui les porte. `getCmdLineOpts` montre celles réellement appliquées.

**Commande à copier-coller** :

```javascript
db.adminCommand({ getCmdLineOpts: 1 }).argv
```

**Résultat attendu** :

```text
[ 'mongod', '--bind_ip_all' ]
```

**Pour aller plus loin** : ouvrez `compose.yaml` et repérez les options de chaque service : `--replSet rs0` pour le nœud replica set, `--auth` pour le serveur authentifié, `--tlsMode requireTLS` pour le serveur TLS. Ces réglages ne sont **pas** modifiables à chaud : changer l'authentification ou TLS demande de redémarrer le processus. C'est la frontière entre les deux familles de réglages : `setParameter` pour ce qui vit en mémoire, le fichier de configuration pour le reste. La taille du cache WiredTiger, vue au module M8, appartient à la seconde.

# M13 - L'écosystème

MongoDB ne vit pas seul : des pilotes le relient aux langages, des outils l'exploitent, d'autres moteurs traitent ses données et le cloud l'opère. Ce module exécute ce qui est exécutable dans le lab, et situe le reste.

## Étape 1 - Un pilote en action : pymongo

**Objectif** : constater qu'une application parle à MongoDB par un pilote.

**Explication** : un pilote est la bibliothèque qui ouvre le pool de connexions, encode les documents en BSON, exécute les opérations et décode les réponses. `mongosh` est lui-même bâti sur un pilote. Ici, un conteneur Python muni de `pymongo` se connecte au serveur par son nom de service Compose.

**Commande à copier-coller** :

```
docker compose --profile driver run --rm driver
```

**Résultat attendu** :

```text
Version du serveur : 7.0.40
produits   : 8
evenements : 16
Aller-retour : {'origine': 'pymongo', 'ok': True}
Canaux : [{'_id': 'web', 'total': 8}, {'_id': 'tablet', 'total': 4}, {'_id': 'mobile', 'total': 4}]
```

**Pour aller plus loin** : le script `demos/driver-demo.py` fait un aller-retour complet (écriture, lecture, suppression) et rejoue une agrégation du module M6 côté pilote. Le résultat de l'agrégation est identique à celui obtenu dans le shell : c'est le **même serveur**, la même base, les mêmes documents. Un pilote ne change pas la sémantique, il change seulement le langage de celui qui parle.

## Étape 2 - Les outils du développeur

**Objectif** : savoir quel outil employer selon le besoin.

**Explication** : l'image du lab embarque toute la suite en ligne de commande. `mongosh` interroge, `mongoimport` et `mongoexport` échangent du JSON, `mongodump` et `mongorestore` sauvegardent, `mongostat` et `mongotop` surveillent, `mongofiles` manipule GridFS. **Compass**, l'interface graphique, n'est pas dans le conteneur : c'est une application de bureau, optionnelle.

**Commande à copier-coller** :

```
docker compose exec mongodb sh -lc 'ls /usr/bin | grep -E "^mongo" | sort'
```

**Résultat attendu** :

```text
mongod
mongodump
mongoexport
mongofiles
mongoimport
mongorestore
mongos
mongosh
mongostat
mongotop
```

**Pour aller plus loin** : `mongod` est le serveur et `mongos` le routeur ; les autres sont les clients. Compass se télécharge séparément et se connecte au même port local `27017` : il ne remplace pas le shell, il le complète pour l'exploration visuelle d'un schéma ou d'un index. Le choix entre outils suit le besoin : interrogations ponctuelles au shell, imports en masse par `mongoimport`, exploration d'un jeu de données par Compass.

## Étape 3 - Spark : traiter un lot hors de la base

**Objectif** : situer un moteur de traitement distribué à côté de la base.

**Explication** : MongoDB stocke et interroge ; Spark **transforme** de gros volumes, en répartissant le calcul sur plusieurs machines. Le lab fournit une démonstration qui lit le journal d'événements, nettoie les numéros de téléphone en format français et agrège par produit. Spark lit ici un fichier JSONL, pas la base : la démonstration porte sur le traitement, pas sur la connexion.

**Commande à copier-coller** :

```
docker compose --profile bigdata run --rm spark
```

**Résultat attendu** (fin de sortie) :

```text
+----------+------------------+-------+-----+
|product_id|event_type        |channel|count|
+----------+------------------+-------+-----+
|P101      |purchase_completed|web    |1    |
...
+----------+------------------+-------+-----+

Téléphones normalisés : 2 ; téléphones rejetés : 1
```

**Pour aller plus loin** : le script `demos/spark-demo.py` montre un point clé des moteurs de traitement : un DataFrame **décrit** un calcul, il ne l'exécute qu'à l'appel d'une action comme `show`. Cette paresse permet à Spark d'optimiser le plan avant de le lancer. Le « téléphone rejeté » est la valeur `invalide` du journal : le nettoyage l'écarte, exactement comme le ferait un pipeline de qualité de données.

## Étape 4 - Kafka et Elasticsearch : brancher la base sur un flux

**Objectif** : savoir à quoi servent ces deux voisins fréquents de MongoDB.

**Explication** : **Kafka** transporte des événements en flux continu entre applications. Le connecteur MongoDB y publie les changements de la base, via le flux `change stream`, ce qui permet à un autre système de réagir sans interroger la base en boucle. **Elasticsearch** indexe des documents pour la recherche plein texte et l'analyse : on y projette une copie des données de MongoDB, car MongoDB excelle à stocker et Elasticsearch à chercher. Dans les deux cas, la base n'est pas remplacée : elle est **reliée**.

**Commande à copier-coller** : ces deux moteurs ne sont pas dans le lab, aucune commande ne peut les démarrer ici.

```text
https://www.mongodb.com/docs/kafka-connector/current/
https://www.elastic.co/guide/en/logstash/current/plugins-outputs-mongodb.html
```

**Résultat attendu** : pas de sortie. L'étape situe ces outils, elle ne les exécute pas. Aucun conteneur Kafka ou Elasticsearch n'est fourni : les ajouter dépasserait le cadre du cours et le dimensionnement d'un poste stagiaire.

**Pour aller plus loin** : la question à se poser devant ces outils est toujours la même : **qui détient la donnée de référence ?** Si MongoDB la détient et qu'Elasticsearch n'en garde qu'un index dérivé, l'index se reconstruit à tout moment. Si les deux prétendent la détenir, les deux divergeront. Le `change stream` — un flux des modifications lu par le pilote, comme un journal — est souvent le bon mécanisme de synchronisation.

## Étape 5 - Atlas et Atlas Search : la base opérée

**Objectif** : comprendre ce qu'un service managé prend en charge, et ce qui reste à l'équipe.

**Explication** : **Atlas** est le service MongoDB opéré par l'éditeur : il gère l'installation, la réplication, les sauvegardes, la supervision et les montées de version. L'équipe ne gère plus que la modélisation, les index, la sécurité des accès et la facture. **Atlas Search** ajoute un moteur de recherche Lucene au-dessus des collections, avec tolérance aux fautes, synonymes et facettes — ce que l'index `text` du module M7 ne sait pas faire.

**Commande à copier-coller** : Atlas s'utilise depuis une interface et une chaîne de connexion, pas depuis ce lab. La création d'un cluster gratuit se fait dans l'interface.

```text
https://www.mongodb.com/docs/atlas/getting-started/
https://www.mongodb.com/docs/atlas/atlas-search/
```

**Résultat attendu** : pas de sortie locale. L'étape décrit la frontière entre ce qu'on opère et ce qu'on délègue.

**Pour aller plus loin** : le critère de décision tient en une phrase : un service managé échange du travail d'exploitation contre de l'argent et une dépendance. Il devient évident quand personne dans l'équipe ne veut porter les sauvegardes, la supervision et les montées de version. La chaîne de connexion Atlas remplace celle du lab, tout le reste du cours — requêtes, index, agrégations — s'applique sans changement.

## Reprendre ou rejouer

Les modules se relisent indépendamment. Si une manipulation a modifié les données du fil rouge, `sh scripts/load-data.sh` les remet dans leur état d'origine : 8 produits et 16 événements. Les services optionnels (replica set, cluster shardé, authentification, TLS) se démarrent et s'arrêtent par profil, sans toucher au serveur principal : `docker compose --profile rs down` en est l'exemple.

Le fil conducteur du parcours est une méthode, pas une liste de commandes : observer avant de conclure, mesurer avant d'optimiser, vérifier avant de se fier. C'est elle qui se transpose à une base de production.
