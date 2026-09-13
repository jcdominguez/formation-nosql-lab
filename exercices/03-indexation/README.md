# Exercice 03 - Observer et justifier un index

## Objectif

À la fin de l'exercice, savoir :

- observer le plan et les statistiques d'une requête ;
- distinguer `COLLSCAN` et `IXSCAN` ;
- construire un index composé à partir d'un filtre et d'un tri connus ;
- comparer le nombre de documents et de clés examinés ;
- expliquer le coût d'un index avant de décider de le conserver.

## Point de départ

Travailler dans la base `formation_nosql` avec le jeu de données préparé.

La recherche étudiée est :

```javascript
const filter = { category: "cafe", active: true }
const order = { price: 1 }

db.produits.find(
  filter,
  { _id: 0, product_id: 1, name: 1, price: 1 }
).sort(order)
```

## 1. Vérifier les index présents

Afficher les index de la collection `produits`.

Avant l'exercice, seul l'index `_id_` doit être présent. Si un autre index subsiste, prévenir le formateur avant de continuer.

## 2. Observer la requête avant indexation

Exécuter la requête avec `explain("executionStats")`.

Relever :

- les étapes du plan gagnant ;
- `nReturned` ;
- `totalKeysExamined` ;
- `totalDocsExamined`.

## 3. Proposer l'index

À partir du filtre et du tri, proposer l'ordre des champs d'un index composé.

Justifier chaque champ : égalité ou tri.

Créer ensuite l'index avec le nom `idx_category_active_price`.

## 4. Observer après indexation

Exécuter exactement le même `explain("executionStats")`.

Comparer les étapes et les trois compteurs avec le premier résultat. Vérifier aussi si une étape de tri séparée reste nécessaire.

## 5. Discuter le coût

Afficher la taille totale des index avec `totalIndexSize()`.

Répondre aux questions suivantes :

1. Cette requête est-elle assez fréquente pour justifier l'index ?
2. Quelles écritures devront aussi maintenir cet index ?
3. Quelles autres requêtes peuvent utiliser le préfixe de cet index ?
4. Quel signal conduirait à supprimer l'index ?

## 6. Nettoyer le lab

Supprimer `idx_category_active_price`, puis vérifier que seul `_id_` reste présent.
