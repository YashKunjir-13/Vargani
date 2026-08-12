import 'package:dio/dio.dart';
void main() {
  final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api/v1'));
  final req = RequestOptions(path: '/receipts/123/pdf', baseUrl: dio.options.baseUrl);
  print(req.uri.toString());
}
