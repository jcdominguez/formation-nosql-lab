FROM mongodb/mongodb-community-server:7.0.40-ubuntu2204

# Certificat auto-signé, généré à la construction de l'image.
# Suffisant pour une démonstration locale de TLS, jamais pour la production.
# L'image s'exécute sous l'utilisateur mongodb : passer root le temps de créer
# le fichier, puis rendre la main.
USER root
RUN mkdir -p /etc/mongo-tls \
    && openssl req -x509 -newkey rsa:2048 -nodes \
         -keyout /etc/mongo-tls/mongo.key -out /etc/mongo-tls/mongo.crt \
         -days 3650 -subj "/CN=localhost" \
    && cat /etc/mongo-tls/mongo.crt /etc/mongo-tls/mongo.key > /etc/mongo-tls/mongo.pem \
    && chmod 600 /etc/mongo-tls/mongo.pem \
    && chown -R mongodb:mongodb /etc/mongo-tls
USER mongodb
