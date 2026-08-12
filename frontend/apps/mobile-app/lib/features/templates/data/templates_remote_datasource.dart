import 'package:dio/dio.dart';
import '../models/receipt_template.dart';

class TemplatesRemoteDataSource {
  final Dio _dio;

  TemplatesRemoteDataSource(this._dio);

  Future<List<ReceiptTemplate>> fetchTemplates() async {
    final response = await _dio.get('/templates');
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map(
            (item) => ReceiptTemplate.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ReceiptTemplate> fetchTemplateById(String id) async {
    final response = await _dio.get('/templates/$id');
    return ReceiptTemplate.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ReceiptTemplate> uploadTemplate({
    required String filename,
    required List<int> bytes,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
    });

    final response = await _dio.post(
      '/templates/upload',
      data: formData,
    );

    return ReceiptTemplate.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ReceiptTemplate> updateFieldMap({
    required String templateId,
    required List<FieldMarker> markers,
  }) async {
    final fieldMapJson = markers.map((m) => m.toJson()).toList();
    final response = await _dio.patch(
      '/templates/$templateId/fieldmap',
      data: {
        'fieldMap': fieldMapJson,
      },
    );
    return ReceiptTemplate.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ReceiptTemplate> activateTemplate(String templateId) async {
    final response = await _dio.patch('/templates/$templateId/activate');
    return ReceiptTemplate.fromJson(Map<String, dynamic>.from(response.data));
  }
}
