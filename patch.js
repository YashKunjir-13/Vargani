const fs = require('fs');
let file = fs.readFileSync('frontend/apps/mobile-app/lib/features/dashboard/presentation/widgets/action_sheets.dart', 'utf8');

const target = `              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Receipt $receiptNo PDF downloaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },`;

const replacement = `              onPressed: () {
                Navigator.pop(ctx);
                final dio = ProviderScope.containerOf(context).read(dioProvider);
                PdfDownloadUtils.downloadReceiptPdf(context, dio, receiptId, receiptNo);
              },`;

if (file.includes(target)) {
    file = file.replace(target, replacement);
    fs.writeFileSync('frontend/apps/mobile-app/lib/features/dashboard/presentation/widgets/action_sheets.dart', file);
    console.log('Patched action_sheets.dart successfully');
} else {
    console.log('Target string not found in action_sheets.dart');
}
