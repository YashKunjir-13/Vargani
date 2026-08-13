const fs = require('fs');
let file = fs.readFileSync('frontend/apps/mobile-app/lib/features/receipts/screens/receipt_detail_screen.dart', 'utf8');

const importTarget = `import '../models/receipt.dart';`;
const importReplacement = `import '../models/receipt.dart';\
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';\
import 'package:pauti_pustak_mobile/shared/utils/pdf_download_utils.dart';`;

file = file.replace(importTarget, importReplacement);

const target = `              InkWell(
                onTap: () {
                  Printing.layoutPdf(
                    onLayout: (format) async {
                      return PdfReceiptGenerator.generateReceiptPdf(
                        receiptNumber: receipt.receiptNumber,
                        mandalName: receipt.mandalName,
                        donorName: receipt.donorName,
                        amountText: currency.format(receipt.amount),
                        dateText: dateFormat.format(receipt.issuedDate),
                        typeLabel: 'Festival Donation — Ganpati Utsav 2026',
                      );
                    },
                  );
                },`;

const replacement = `              InkWell(
                onTap: () async {
                  final dio = ref.read(dioProvider);
                  await PdfDownloadUtils.downloadReceiptPdf(
                    context, 
                    dio, 
                    receiptId, 
                    receipt.receiptNumber
                  );
                },`;

if (file.includes(target)) {
    file = file.replace(target, replacement);
    fs.writeFileSync('frontend/apps/mobile-app/lib/features/receipts/screens/receipt_detail_screen.dart', file);
    console.log('Patched receipt_detail_screen.dart successfully');
} else {
    console.log('Target string not found in receipt_detail_screen.dart');
}
