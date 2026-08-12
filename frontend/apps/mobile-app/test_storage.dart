import 'dart:io';

void main() async {
  final dir = Directory('/storage/emulated/0/Download');
  if (!dir.existsSync()) {
    print("Download dir does not exist");
    return;
  }
  final file = File('${dir.path}/test_pauti.txt');
  await file.writeAsString("test content");
  print("Success writing to ${file.path}");
}
