# Exercice 01 - Premiers documents MongoDB

## Objectif

À la fin de l'exercice, savoir :

- sélectionner une base de données ;
- insérer plusieurs documents dans une collection ;
- lire les documents sans afficher leur identifiant technique ;
- distinguer les champs communs des attributs propres à une catégorie.

## Contexte

Le catalogue contient des produits de catégories différentes. Tous partagent un identifiant, une catégorie et un nom, mais leurs caractéristiques métier varient.

## Étape 1 - Sélectionner la base

Dans `mongosh` :

```javascript
use formation_nosql_decouverte
```

## Étape 2 - Insérer les premiers produits

```javascript
db.produits.insertMany([
  {
    product_id: "P201",
    category: "appareil-photo",
    name: "Horizon X100",
    attributes: {
      sensor: "APS-C",
      stabilization: true
    }
  },
  {
    product_id: "P202",
    category: "sac-a-dos",
    name: "Transit 24",
    attributes: {
      capacity_liters: 24,
      waterproof: true
    }
  }
])
```

## Étape 3 - Lire les documents

Afficher les produits par ordre d'identifiant, sans le champ `_id` généré par MongoDB.

## Étape 4 - Ajouter un produit

Ajouter un produit `P203` de catégorie `cafe`. Choisir au moins deux attributs adaptés à cette catégorie, différents de ceux des deux premiers produits.

Afficher de nouveau toute la collection.

## Questions de débrief

1. Quels champs sont communs aux trois produits ?
2. Quels champs varient selon la catégorie ?
3. À quel moment la collection `produits` a-t-elle été créée ?
4. Cette flexibilité dispense-t-elle de définir des règles sur les documents ?
