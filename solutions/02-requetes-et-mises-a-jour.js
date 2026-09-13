const trainingDb = db.getSiblingDB("formation_nosql");

const productCount = trainingDb.produits.countDocuments();
const eventCount = trainingDb.evenements.countDocuments();

if (productCount !== 8 || eventCount !== 16) {
  throw new Error(
    `Jeu de données inattendu : ${productCount} produits et ${eventCount} événements. ` +
    "Exécuter scripts/load-data.sh avant la correction."
  );
}

// Rendre la correction rejouable après une première exécution.
trainingDb.produits.updateOne(
  { product_id: "P104" },
  { $set: { active: false, price: 159 } }
);
trainingDb.produits.updateMany(
  { category: "cafe" },
  { $unset: { campaign: "" } }
);
trainingDb.produits.updateOne(
  { product_id: "P102" },
  { $set: { legacy_label: "compact" } }
);

print("\n1. Produits actifs à moins de 100 euros");
trainingDb.produits
  .find(
    { active: true, price: { $lt: 100 } },
    { _id: 0, product_id: 1, name: 1, category: 1, price: 1 }
  )
  .sort({ price: 1, product_id: 1 })
  .forEach(document => printjson(document));

print("\n2. Produits noirs");
trainingDb.produits
  .find(
    { "attributes.color": "noir" },
    { _id: 0, product_id: 1, name: 1, category: 1 }
  )
  .sort({ category: 1, product_id: 1 })
  .forEach(document => printjson(document));

print("\n3. Passages en caisse");
trainingDb.evenements
  .find(
    { event_type: "checkout_started" },
    {
      _id: 0,
      event_id: 1,
      occurred_at: 1,
      session_id: 1,
      product_id: 1,
      channel: 1,
      "payload.phone": 1
    }
  )
  .sort({ occurred_at: 1 })
  .forEach(document => printjson(document));

print("\n4. Réactiver P104");
const reactivation = trainingDb.produits.updateOne(
  { product_id: "P104", active: false },
  { $set: { active: true }, $inc: { price: -10 } }
);
printjson({
  acknowledged: reactivation.acknowledged,
  matchedCount: reactivation.matchedCount,
  modifiedCount: reactivation.modifiedCount
});
printjson(
  trainingDb.produits.findOne(
    { product_id: "P104" },
    { _id: 0, product_id: 1, name: 1, active: 1, price: 1 }
  )
);

print("\n5. Marquer la campagne café");
const campaign = trainingDb.produits.updateMany(
  { category: "cafe" },
  { $set: { campaign: "decouverte" } }
);
printjson({
  acknowledged: campaign.acknowledged,
  matchedCount: campaign.matchedCount,
  modifiedCount: campaign.modifiedCount
});
trainingDb.produits
  .find(
    { category: "cafe" },
    { _id: 0, product_id: 1, name: 1, campaign: 1 }
  )
  .sort({ product_id: 1 })
  .forEach(document => printjson(document));

print("\n6. Retirer legacy_label de P102");
const cleanup = trainingDb.produits.updateOne(
  { product_id: "P102" },
  { $unset: { legacy_label: "" } }
);
printjson({
  acknowledged: cleanup.acknowledged,
  matchedCount: cleanup.matchedCount,
  modifiedCount: cleanup.modifiedCount
});
printjson(
  trainingDb.produits.findOne(
    { product_id: "P102" },
    { _id: 0, product_id: 1, name: 1, legacy_label: 1 }
  )
);
