# Exercice 05 - Replica set à trois nœuds

Copie technique de la démonstration « Répliquer les données » du Guide participant, qui porte la procédure complète et les résultats attendus.

Indépendant du lab principal : ne partage ni port ni volume avec `compose.yaml`. Lancer depuis ce dossier.

```shell
docker compose -f compose.replica.yaml up -d
docker compose -f compose.replica.yaml exec rs1 mongosh --quiet --eval 'rs.initiate({ _id: "rs0", members: [ { _id: 0, host: "rs1:27017" }, { _id: 1, host: "rs2:27017" }, { _id: 2, host: "rs3:27017" } ] })'
docker compose -f compose.replica.yaml exec rs1 mongosh --quiet --eval 'rs.status().members.forEach(m => print(m.name + " : " + m.stateStr))'
```

Chaîne de connexion qui découvre le primaire, quel qu'il soit :

```text
mongodb://rs1:27017,rs2:27017,rs3:27017/formation_nosql?replicaSet=rs0
```

Démonter en effaçant les données :

```shell
docker compose -f compose.replica.yaml down --volumes
```
