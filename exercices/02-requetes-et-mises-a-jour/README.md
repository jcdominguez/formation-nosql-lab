# Exercice 02 - Requêtes et mises à jour

## Objectif

À la fin de l'exercice, savoir :

- filtrer des documents et des champs imbriqués ;
- choisir les champs retournés par une projection ;
- trier un résultat ;
- modifier un ou plusieurs documents avec un filtre précis ;
- contrôler le résultat annoncé par MongoDB puis relire les documents.

## Préparation

Charger le jeu de données préparé, puis ouvrir `mongosh` sur la base `formation_nosql` selon les instructions fournies par le formateur.

Avant de commencer, vérifier que la base contient 8 produits et 16 événements.

## Partie A - Lire sans modifier

### 1. Produits actifs à moins de 100 euros

Afficher uniquement les champs `product_id`, `name`, `category` et `price`, sans `_id`.

Trier le résultat par prix croissant, puis par `product_id` croissant.

Avant d'exécuter la requête, prédire le nombre de documents attendus.

### 2. Produits noirs

Rechercher les produits dont `attributes.color` vaut `noir`.

Afficher uniquement `product_id`, `name` et `category`, sans `_id`. Trier par catégorie, puis par `product_id`.

### 3. Passages en caisse

Dans la collection `evenements`, rechercher les événements dont `event_type` vaut `checkout_started`.

Afficher `event_id`, `occurred_at`, `session_id`, `product_id`, `channel` et `payload.phone`, sans `_id`. Trier par date croissante.

## Partie B - Modifier puis contrôler

### 4. Réactiver un produit

Le produit `P104` redevient actif et son prix baisse de 10 euros.

- utiliser `updateOne()` ;
- filtrer sur `product_id` et sur l'état inactif attendu ;
- utiliser `$set` et `$inc` dans la même écriture ;
- lire `matchedCount` et `modifiedCount` ;
- relire `P104` pour contrôler son état et son prix.

### 5. Marquer une campagne

Ajouter le champ `campaign: "decouverte"` à tous les produits de catégorie `cafe` avec `updateMany()` et `$set`.

Contrôler le nombre de documents trouvés et modifiés, puis relire les cafés.

### 6. Retirer un ancien champ

Retirer `legacy_label` du produit `P102` avec `updateOne()` et `$unset`.

Relire le produit en projetant `product_id`, `name` et `legacy_label` pour vérifier que le champ a disparu.

## Questions de débrief

1. Pourquoi contrôler à la fois le résultat de l'écriture et le document final ?
2. Que signifie `matchedCount: 1` avec `modifiedCount: 0` ?
3. Pourquoi le filtre de la réactivation inclut-il l'état `active: false` ?
4. Quelle différence de risque existe entre `updateOne()` et `updateMany()` ?
