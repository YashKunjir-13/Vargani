// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generates valid PDF bytes for Printing.layoutPdf without crashing Android PrintManager.
class PdfReceiptGenerator {
  static Future<Uint8List> generateReceiptPdf({
    required String receiptNumber,
    required String mandalName,
    required String donorName,
    required String amountText,
    required String dateText,
    required String typeLabel,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber800, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    mandalName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber900,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'OFFICIAL FESTIVAL DONATION RECEIPT',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.amber800),
                pw.SizedBox(height: 16),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Receipt No: $receiptNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $dateText', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 12),

                pw.Text('Donor Name: $donorName', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),

                pw.Text('Category: $typeLabel'),
                pw.SizedBox(height: 12),

                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.amber300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Amount Received:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(amountText, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                    ],
                  ),
                ),
                pw.Spacer(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Status: VERIFIED & CONFIRMED', style: pw.TextStyle(fontSize: 9, color: PdfColors.green700, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Pauti Pustak Digital Sign-off', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(width: 80, height: 1, color: PdfColors.grey800),
                        pw.SizedBox(height: 4),
                        pw.Text('Authorized Trustee', style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
