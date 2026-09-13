const trainingDb = db.getSiblingDB("formation_nosql");
const products = trainingDb.produits;
const indexName = "idx_category_active_price";

if (products.countDocuments() !== 8) {
  throw new Error(
    "Jeu de données inattendu. Exécuter scripts/load-data.sh avant la correction."
  );
}

if (products.getIndexes().some(index => index.name === indexName)) {
  products.dropIndex(indexName);
}

const filter = { category: "cafe", active: true };
const order = { price: 1 };

function collectStages(node, stages = []) {
  if (!node || typeof node !== "object") {
    return stages;
  }

  if (typeof node.stage === "string") {
    stages.push(node.stage);
  }

  for (const key of ["queryPlan", "inputStage", "outerStage", "innerStage"]) {
    collectStages(node[key], stages);
  }

  if (Array.isArray(node.inputStages)) {
    for (const inputStage of node.inputStages) {
      collectStages(inputStage, stages);
    }
  }

  return [...new Set(stages)];
}

function summarize(label, explanation) {
  print(`\n${label}`);
  printjson({
    stages: collectStages(explanation.queryPlanner.winningPlan),
    nReturned: explanation.executionStats.nReturned,
    totalKeysExamined: explanation.executionStats.totalKeysExamined,
    totalDocsExamined: explanation.executionStats.totalDocsExamined
  });
}

const sizeBefore = Number(products.totalIndexSize());
const before = products.find(filter).sort(order).explain("executionStats");
summarize("Avant indexation", before);

products.createIndex(
  { category: 1, active: 1, price: 1 },
  { name: indexName }
);

const sizeAfter = Number(products.totalIndexSize());
const after = products.find(filter).sort(order).explain("executionStats");
summarize("Après indexation", after);

print("\nCoût de stockage mesuré dans cet environnement");
printjson({
  sizeBefore,
  sizeAfter,
  addedBytes: sizeAfter - sizeBefore
});

print("\nIndex présents pendant l'observation");
printjson(products.getIndexes().map(index => index.name));

products.dropIndex(indexName);

print("\nNettoyage terminé");
printjson(products.getIndexes().map(index => index.name));
