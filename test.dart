void main() {
  var list = [
    {'collectedAt': DateTime.now()} // backend returns ISO strings, but just in case
  ];
  for (var r in list) {
    print(DateTime.tryParse(r['collectedAt'].toString()));
  }
}
