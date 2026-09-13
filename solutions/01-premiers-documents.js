const trainingDb = db.getSiblingDB("formation_nosql_decouverte");

trainingDb.produits.drop();

const insertion = trainingDb.produits.insertMany([
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
  },
  {
    product_id: "P203",
    category: "cafe",
    name: "Altitude Éthiopie",
    attributes: {
      format: "grains",
      weight_g: 250,
      roast: "clair"
    }
  }
]);

print(`Documents insérés : ${Object.keys(insertion.insertedIds).length}`);

trainingDb.produits
  .find({}, { _id: 0 })
  .sort({ product_id: 1 })
  .forEach(document => printjson(document));
