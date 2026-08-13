import 'package:dio/dio.dart';
void main() {
  final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api/v1'));
  print(dio.options.baseUrl);
  // Dio does NOT use Uri.resolve, it concatenates if not absolute.
  // Wait, let's see.
}
