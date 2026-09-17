"""Démonstration d'un pilote MongoDB, ici pymongo, depuis un conteneur.

Le pilote est le pont entre un langage de programmation et le serveur. C'est lui
qui ouvre le pool de connexions, encode les documents en BSON, exécute les
requêtes et décode les réponses. Un shell comme mongosh est lui-même bâti sur un
pilote.

Lancement, serveur MongoDB déjà démarré :

    docker compose --profile driver run --rm driver
"""

from pymongo import MongoClient

# Le nom d'hôte est le nom du service Compose, résolu par le réseau du projet.
client = MongoClient("mongodb://mongodb:27017/")
base = client["formation_nosql"]

print("Version du serveur :", client.server_info()["version"])
print("produits   :", base.produits.count_documents({}))
print("evenements :", base.evenements.count_documents({}))

# Aller-retour complet : écriture, lecture, suppression.
base.demo_driver.insert_one({"origine": "pymongo", "ok": True})
document = base.demo_driver.find_one({"origine": "pymongo"}, {"_id": 0})
print("Aller-retour :", document)
base.demo_driver.drop()

# Agrégation équivalente à celle du module M6, côté pilote.
canaux = list(
    base.evenements.aggregate(
        [
            {"$group": {"_id": "$channel", "total": {"$sum": 1}}},
            {"$sort": {"total": -1}},
        ]
    )
)
print("Canaux :", canaux)

client.close()
