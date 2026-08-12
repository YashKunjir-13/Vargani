import 'dart:io';

void main() async {
  try {
    final file = File('/sdcard/Download/test_direct.pdf');
    await file.writeAsBytes([0x25, 0x50, 0x44, 0x46]);
    print("SUCCESS");
  } catch (e) {
    print("FAILED: $e");
  }
}
