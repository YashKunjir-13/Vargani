const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({ log: ['query', 'info', 'warn', 'error'] });

async function main() {
  const accountIds = ["531590ab-a210-4b5d-8dc5-fe4da607c1ea"];
  
  try {
    const collectionsAgg = await prisma.collectionRecord.aggregate({
      where: { contributorAccountId: { in: accountIds }, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });
    console.log("collectionsAgg:", collectionsAgg);
  } catch (err) {
    console.error("Error in aggregate:", err);
  }
}
main().finally(() => prisma.$disconnect());
