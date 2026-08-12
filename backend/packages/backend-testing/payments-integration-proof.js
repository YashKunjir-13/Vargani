"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("../../../packages/backend-database/src/generated/client");
async function main() {
    const prisma = new client_1.PrismaClient();
    try {
        console.log("=== Step 5 Proof: Postgres-backed Payment Collection Flow ===");
        const orgId = "10000000-0000-0000-0000-000000000001";
        const userId = "20000000-0000-0000-0000-000000000001";
        const festivalYear = 2026;
        await prisma.paymentAuditEvent.deleteMany({ where: { organizationId: orgId } });
        await prisma.payment.deleteMany({ where: { organizationId: orgId } });
        console.log("\n[1/3] Creating QR Payment Entry (Pending Match)...");
        const payment = await prisma.payment.create({
            data: {
                organizationId: orgId,
                festivalYear,
                donorNameSnapshot: "Suresh Deshmukh",
                addressSnapshot: "Flat 402, Shivajinagar, Pune",
                contactSnapshot: "9822098220",
                amount: 7500.00,
                paymentDateTime: new Date(),
                channel: client_1.PaymentChannel.QR_CODE,
                status: client_1.PaymentStatus.PENDING_MATCH,
                createdByUserId: userId,
            },
        });
        console.log("Created Payment row in Postgres:", {
            id: payment.id,
            donorNameSnapshot: payment.donorNameSnapshot,
            amount: payment.amount.toString(),
            channel: payment.channel,
            status: payment.status,
        });
        console.log("\n=== Direct Postgres Row Verification (Initial Pending Match) ===");
        const pendingRow = await prisma.payment.findUnique({ where: { id: payment.id } });
        console.log("Database status check:", pendingRow?.status);
        console.log("\n[2/3] Confirming Payment Match (Pending Match -> Confirmed -> Receipted)...");
        const confirmed = await prisma.payment.update({
            where: { id: payment.id },
            data: {
                status: client_1.PaymentStatus.CONFIRMED,
                matchedByUserId: userId,
                matchedAt: new Date(),
            },
        });
        await prisma.paymentAuditEvent.create({
            data: {
                organizationId: orgId,
                paymentId: confirmed.id,
                actionType: "manual_match_confirmed",
                performedByUserId: userId,
            },
        });
        const receipted = await prisma.payment.update({
            where: { id: confirmed.id },
            data: { status: client_1.PaymentStatus.RECEIPTED },
        });
        await prisma.paymentAuditEvent.create({
            data: {
                organizationId: orgId,
                paymentId: receipted.id,
                actionType: "receipt_generated",
                performedByUserId: userId,
            },
        });
        console.log("Payment status updated to:", receipted.status);
        console.log("\n[3/3] Auditing Audit Events...");
        const auditLogs = await prisma.paymentAuditEvent.findMany({
            where: { organizationId: orgId },
            orderBy: { createdAt: "asc" },
        });
        console.log("\n=== Complete Real Postgres Database State ===");
        const allPayments = await prisma.payment.findMany({
            where: { organizationId: orgId },
        });
        console.table(allPayments.map((p) => ({
            id: p.id,
            donorNameSnapshot: p.donorNameSnapshot,
            amount: p.amount.toString(),
            channel: p.channel,
            status: p.status,
            matchedByUserId: p.matchedByUserId,
        })));
        console.log("\n=== Audit Log Trail ===");
        console.table(auditLogs.map((a) => ({
            id: a.id,
            paymentId: a.paymentId,
            actionType: a.actionType,
            performedByUserId: a.performedByUserId,
            createdAt: a.createdAt,
        })));
    }
    finally {
        await prisma.$disconnect();
    }
}
main().catch((err) => {
    console.error("Proof script failed:", err);
    process.exit(1);
});
//# sourceMappingURL=payments-integration-proof.js.map