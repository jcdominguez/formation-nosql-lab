"""Chiffrement côté client, explicite, avec le pilote pymongo.

Le principe : le champ est chiffré par l'application, avec une clé que le serveur
ne connaît pas. MongoDB stocke des octets qu'il est incapable de déchiffrer. Seul
un client qui possède la clé maîtresse peut relire la valeur en clair.

Ici la clé maîtresse est un fichier local, suffisant pour la démonstration. En
production, elle vit dans un service de gestion de clés (KMS), jamais dans le code.

Ce script montre le chiffrement *explicite* : c'est l'application qui appelle
`encrypt` et `decrypt`. Le chiffrement *automatique*, où le pilote s'en charge
d'après un schéma, exige MongoDB Enterprise ou Atlas.

Lancement, serveur MongoDB déjà démarré :

    docker compose --profile driver run --rm driver python3 /lab/demos/csfle-demo.py
"""

import os

from bson import Binary
from pymongo import MongoClient
from pymongo.encryption import ClientEncryption
from pymongo.encryption_options import AutoEncryptionOpts  # noqa: F401  (documenté pour l'automatique)

# Clé maîtresse locale : 96 octets aléatoires, régénérés à chaque exécution.
cle_maitresse = os.urandom(96)
kms = {"local": {"key": cle_maitresse}}

client = MongoClient("mongodb://mongodb:27017")
base = client["formation_nosql"]
trousseau = base["cles_chiffrement"]

chiffreur = ClientEncryption(
    kms,
    "formation_nosql.cles_chiffrement",
    client,
    base.get_collection("donnees_client").codec_options,
)

# Une clé de données, elle-même chiffrée par la clé maîtresse.
cle_donnees = chiffreur.create_data_key("local")

telephone = "06 00 00 00 02"
chiffre = chiffreur.encrypt(
    telephone,
    algorithm="AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic",
    key_id=cle_donnees,
)

base.donnees_client.insert_one({"client_id": "C205", "telephone": chiffre})
stocke = base.donnees_client.find_one({"client_id": "C205"})["telephone"]

print("Type stocké dans la base :", type(stocke).__name__, "| longueur :", len(stocke), "octets")
print("Valeur telle que la voit le serveur :", Binary(stocke).hex()[:48], "...")
print("Déchiffré par le client :", chiffreur.decrypt(stocke))

base.donnees_client.drop()
trousseau.drop()
client.close()
