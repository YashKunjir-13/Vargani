import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_controller.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_preferences.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

class FakeLocalePreferences implements LocalePreferences {
  Locale _storedLocale = const Locale('en');

  @override
  Future<Locale> load() async => _storedLocale;

  @override
  Future<void> save(Locale locale) async {
    _storedLocale = locale;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization System Tests', () {
    test('LocaleController switches and updates global locale state', () async {
      final fakePrefs = FakeLocalePreferences();
      final container = ProviderContainer(
        overrides: [
          localePreferencesProvider.overrideWithValue(fakePrefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(localeControllerProvider), const Locale('en'));

      await container
          .read(localeControllerProvider.notifier)
          .selectLocale(const Locale('hi'));
      expect(container.read(localeControllerProvider), const Locale('hi'));
      expect(await fakePrefs.load(), const Locale('hi'));

      await container
          .read(localeControllerProvider.notifier)
          .selectLocale(const Locale('mr'));
      expect(container.read(localeControllerProvider), const Locale('mr'));
      expect(await fakePrefs.load(), const Locale('mr'));

      await container
          .read(localeControllerProvider.notifier)
          .selectLocale(const Locale('en'));
      expect(container.read(localeControllerProvider), const Locale('en'));
      expect(await fakePrefs.load(), const Locale('en'));
    });

    testWidgets('Instant app-wide localization update upon locale selection',
        (tester) async {
      final fakePrefs = FakeLocalePreferences();
      late BuildContext savedContext;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localePreferencesProvider.overrideWithValue(fakePrefs),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final locale = ref.watch(localeControllerProvider);
              return MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Builder(
                  builder: (ctx) {
                    savedContext = ctx;
                    return Scaffold(
                      body: Column(
                        children: [
                          Text(ctx.l10n.profile),
                          Text(ctx.l10n.goodMorning),
                          Text(ctx.l10n.homeTab),
                          Text(ctx.l10n.contributionsTab),
                          Text(ctx.l10n.billsTab),
                          Text(ctx.allRecords),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state: English
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Good Morning'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Contributions'), findsOneWidget);
      expect(find.text('Bills'), findsOneWidget);
      expect(find.text('All Records'), findsOneWidget);

      // Switch to Hindi
      final container = ProviderScope.containerOf(savedContext);
      await container
          .read(localeControllerProvider.notifier)
          .selectLocale(const Locale('hi'));
      await tester.pumpAndSettle();

      expect(find.text('प्रोफ़ाइल'), findsOneWidget);
      expect(find.text('सुप्रभात'), findsOneWidget);
      expect(find.text('मुख्य'), findsOneWidget);
      expect(find.text('योगदान'), findsOneWidget);
      expect(find.text('बिल'), findsOneWidget);
      expect(find.text('सभी रिकॉर्ड'), findsOneWidget);

      // Switch to Marathi
      await container
          .read(localeControllerProvider.notifier)
          .selectLocale(const Locale('mr'));
      await tester.pumpAndSettle();

      expect(find.text('प्रोफाईल'), findsOneWidget);
      expect(find.text('शुभ सकाळ'), findsOneWidget);
      expect(find.text('मुख्य'), findsOneWidget);
      expect(find.text('योगदान'), findsOneWidget);
      expect(find.text('बिले'), findsOneWidget);
      expect(find.text('सर्व नोंदी'), findsOneWidget);
    });
  });
}
