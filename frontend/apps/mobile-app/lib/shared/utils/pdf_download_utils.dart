import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PdfDownloadUtils {
  static Future<void> downloadReceiptPdf(BuildContext context, Dio dio,
      String receiptId, String receiptNumber) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading receipt PDF from backend server...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final url = '/donor/receipts/$receiptId/pdf';
      print("==================================================");
      print("1. Call GET /api/v1/donor/receipts/:id/pdf");
      print("2. EXACT URL: ${dio.options.baseUrl}$url");
      print("   RECEIPT ID: $receiptId");
      print("==================================================");

      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status <= 500,
        ),
      );

      final contentType = response.headers.value('content-type') ?? 'unknown';
      final List<int> bytes = response.data is List<int> ? response.data : [];

      print("3. HTTP STATUS CODE: ${response.statusCode}");
      print("4. CONTENT-TYPE: $contentType");
      print("5. RESPONSE BYTE LENGTH: ${bytes.length}");

      if (response.statusCode != 200) {
        String errorMsg = 'Server returned status ${response.statusCode}';
        if (contentType.contains('application/json')) {
          try {
            final decoded = String.fromCharCodes(bytes);
            errorMsg = 'Backend Error: $decoded';
          } catch (_) {}
        }
        print("12. BACKEND ERROR: $errorMsg");
        throw Exception(errorMsg);
      }

      if (contentType != 'application/pdf') {
        throw Exception('Invalid content type: $contentType');
      }

      if (bytes.isEmpty) {
        throw Exception('Received empty file data');
      }

      final headerStr = bytes.length >= 4
          ? String.fromCharCodes(bytes.sublist(0, 4))
          : 'invalid';
      print("6. RESPONSE BYTES BEGIN WITH: $headerStr");
      if (headerStr != '%PDF') {
        throw Exception(
            'File does not appear to be a valid PDF. Header: $headerStr');
      }

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file =
          File('${directory.path}/Pauti_Pustak_Receipt_$receiptNumber.pdf');
      await file.writeAsBytes(bytes);

      final exists = file.existsSync();
      final length = exists ? file.lengthSync() : 0;

      print("7. SAVE DIR: ${directory.path}");
      print("8. FILENAME: Pauti_Pustak_Receipt_$receiptNumber.pdf");
      print("9. VERIFY: exists=$exists, length=$length > 0");
      print("10. EXACT FINAL PATH: ${file.path}");
      print("10. EXACT FILE SIZE: $length");
      print("11. VERIFICATION CHECKS PASSED");

      if (!exists || length == 0) {
        throw Exception('Verification failed: File was not written correctly.');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Receipt $receiptNumber PDF downloaded successfully to Downloads!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Download Error'),
            content: Text('Failed to download PDF: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
