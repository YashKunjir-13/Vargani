import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/core/session/session_state.dart';
import 'package:pauti_pustak_mobile/core/theme/app_theme.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

class DummyTestHttpAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    return Future.value(ResponseBody(
      Stream.value(
          Uint8List.fromList('{"statusCode": 200, "data": {}}'.codeUnits)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    ));
  }

  @override
  void close({bool force = false}) {}
}

/// Wraps a test widget with necessary providers, themes, and localizations.
Widget createTestableWidget({
  required Widget child,
  List<dynamic> overrides = const [],
  SessionState sessionState = SessionState.unauthenticated,
}) {
  final testDio = Dio()..httpClientAdapter = DummyTestHttpAdapter();

  return ProviderScope(
    overrides: [
      initialSessionStateProvider.overrideWithValue(sessionState),
      dioProvider.overrideWithValue(testDio),
      ...overrides,
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1080, 2400)),
        child: child,
      ),
    ),
  );
}
