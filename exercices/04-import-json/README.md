# Exercice 04 - Importer un export SGBDR au format JSON

Copie technique de l'atelier « Importation de données des SGBDR au format JSON » du Guide participant, qui porte l'énoncé complet et le corrigé.

- `data/export-sgbdr/commandes.sql` : les trois tables relationnelles et la requête PostgreSQL d'export.
- `data/export-sgbdr/commandes.json` : le résultat de cette requête, un tableau JSON.

```shell
docker compose exec -T mongodb mongoimport --db=formation_nosql --collection=commandes --drop --jsonArray --file=/lab/data/export-sgbdr/commandes.json
```

Puis, dans `mongosh`, vérifier le type de `ordered_at` et le convertir :

```javascript
db.commandes.findOne().ordered_at instanceof Date
db.commandes.updateMany({}, [{ $set: { ordered_at: { $toDate: "$ordered_at" } } }])
```
