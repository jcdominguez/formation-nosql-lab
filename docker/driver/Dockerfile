FROM mongodb/mongodb-community-server:7.0.40-ubuntu2204

# Pilote MongoDB pour Python, avec les bibliothèques de chiffrement côté client.
RUN pip install --no-cache-dir "pymongo[encryption]"

WORKDIR /lab
