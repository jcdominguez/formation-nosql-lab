import argparse

from pyspark.sql import SparkSession, functions as F


parser = argparse.ArgumentParser()
parser.add_argument("--pause", action="store_true")
args = parser.parse_args()


def pause(message):
    if args.pause:
        input(f"\n{message} Appuyer sur Entrée pour continuer. ")


spark = (
    SparkSession.builder.appName("formation-nosql-spark")
    .master("local[2]")
    .getOrCreate()
)
spark.sparkContext.setLogLevel("ERROR")

print("\n=== 1. Charger et contrôler ===")
events = spark.read.json("/lab/data/evenements.jsonl")
events.printSchema()
events.select(
    "event_id", "event_type", "client_id", "product_id", "channel"
).orderBy("occurred_at").show(5, truncate=False)
pause("Repérer le schéma inféré et les champs absents selon les événements.")

print("\n=== 2. Préparer le nettoyage des téléphones ===")
phones = (
    events.filter(F.col("event_type") == "checkout_started")
    .withColumn("phone_raw", F.col("payload.phone"))
    .withColumn("digits", F.regexp_replace("phone_raw", r"\D", ""))
    .withColumn(
        "phone_normalized",
        F.when(
            F.col("digits").rlike(r"^0[67][0-9]{8}$"),
            F.concat(F.lit("+33"), F.substring("digits", 2, 9)),
        )
        .when(
            F.col("digits").rlike(r"^33[67][0-9]{8}$"),
            F.concat(F.lit("+"), F.col("digits")),
        )
        .otherwise(F.lit(None).cast("string")),
    )
)
phones.select("event_id", "phone_raw", "phone_normalized").orderBy(
    "event_id"
).show(truncate=False)
pause("Faire identifier les deux valeurs normalisées et la valeur rejetée.")

print("\n=== 3. Décrire le calcul avant l'action ===")
indicators = (
    events.groupBy("product_id", "event_type", "channel")
    .count()
    .orderBy("product_id", "event_type", "channel")
)
indicators.explain(mode="formatted")
pause("Le DataFrame décrit un plan ; show déclenchera le calcul.")

print("\n=== 4. Déclencher et afficher l'agrégation ===")
indicators.show(50, truncate=False)

valid_phone_count = phones.filter(F.col("phone_normalized").isNotNull()).count()
invalid_phone_count = phones.filter(F.col("phone_normalized").isNull()).count()
print(
    f"Téléphones normalisés : {valid_phone_count} ; téléphones rejetés : {invalid_phone_count}"
)

spark.stop()
