const { PrismaClient } = require('./packages/backend-database/node_modules/@prisma/client');

const prisma = new PrismaClient();

async function main() {
  console.log("=== Latest CollectionRecords ===");
  const latestCollections = await prisma.collectionRecord.findMany({
    orderBy: { createdAt: 'desc' },
    take: 3,
  });
  console.log(JSON.stringify(latestCollections, null, 2));

  console.log("\n=== Latest PaymentReceipts ===");
  const latestReceipts = await prisma.paymentReceipt.findMany({
    orderBy: { createdAt: 'desc' },
    take: 3
  });
  console.log(JSON.stringify(latestReceipts, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
