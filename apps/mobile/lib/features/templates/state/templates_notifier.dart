import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';

import '../data/templates_remote_datasource.dart';
import '../models/receipt_template.dart';

final templatesRemoteDataSourceProvider = Provider<TemplatesRemoteDataSource>((ref) {
  return TemplatesRemoteDataSource(ref.watch(dioProvider));
});

class TemplatesNotifier extends Notifier<AsyncValue<List<ReceiptTemplate>>> {
  @override
  AsyncValue<List<ReceiptTemplate>> build() {
    loadTemplates();
    return const AsyncValue.loading();
  }

  Future<void> loadTemplates() async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(templatesRemoteDataSourceProvider);
      final templates = await dataSource.fetchTemplates();
      state = AsyncValue.data(templates);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ReceiptTemplate?> uploadAndActivateTemplate({
    required String filename,
    required List<int> bytes,
  }) async {
    try {
      final dataSource = ref.read(templatesRemoteDataSourceProvider);
      final uploaded = await dataSource.uploadTemplate(filename: filename, bytes: bytes);
      final activated = await dataSource.activateTemplate(uploaded.id);
      await loadTemplates();
      return activated;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateMarkerPosition(
    String templateId,
    String markerId,
    Offset newNormalizedPosition,
  ) async {
    final currentList = state.value ?? [];
    final template = currentList.firstWhere((t) => t.id == templateId, orElse: () => currentList.first);

    final updatedMarkers = [
      for (final m in template.markers)
        if (m.id == markerId) m.copyWith(position: newNormalizedPosition) else m
    ];

    try {
      final dataSource = ref.read(templatesRemoteDataSourceProvider);
      await dataSource.updateFieldMap(templateId: templateId, markers: updatedMarkers);
      await loadTemplates();
    } catch (_) {
      // Retain local optimistic state update if server patch throws fallback
    }
  }

  Future<bool> activateTemplate(String templateId) async {
    try {
      final dataSource = ref.read(templatesRemoteDataSourceProvider);
      await dataSource.activateTemplate(templateId);
      await loadTemplates();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final templatesProvider = NotifierProvider<TemplatesNotifier, AsyncValue<List<ReceiptTemplate>>>(
  TemplatesNotifier.new,
);

const defaultFallbackTemplate = ReceiptTemplate(
  id: 'tmpl-default',
  name: 'Standard Saffron Header Template',
  mandalName: 'Mandal Financial Trust',
  imageUrl: 'assets/images/template_saffron.png',
  isActive: true,
  detectionStatus: 'AUTO_DETECTED',
  markers: [],
);

final activeTemplateProvider = Provider<ReceiptTemplate>((ref) {
  final asyncState = ref.watch(templatesProvider);
  return asyncState.when(
    data: (templates) {
      if (templates.isEmpty) return defaultFallbackTemplate;
      return templates.firstWhere((t) => t.isActive, orElse: () => templates.first);
    },
    loading: () => defaultFallbackTemplate,
    error: (_, __) => defaultFallbackTemplate,
  );
});
