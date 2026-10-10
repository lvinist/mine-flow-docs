import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mine_flow/core/presentation/widgets/app_interaction_primitives.dart';
import 'package:mine_flow/l10n/app_localizations.dart';

Widget _wrap(Widget child, {Size size = const Size(1024, 768)}) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('id'), Locale('en')],
    home: FTheme(
      data: FTheme.neutral.light.touch,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('Dialog and Sheet Interactive Targets', () {
    testWidgets('AppResponsiveSheet header close button and footer', (tester) async {
      await tester.pumpWidget(_wrap(
        AppResponsiveSheet(
          routeIdentity: 'test-sheet',
          title: 'Sheet Title',
          mode: AppResponsiveSheetMode.form,
          body: Column(
            children: [
              FTextField(
                hint: 'Input text...',
              ),
            ],
          ),
          footer: Row(
            children: [
              Expanded(
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: () {},
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FButton(
                  onPress: () {},
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
          onDismissApproved: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final closeBtn = tester.renderObject<RenderBox>(find.byType(AppAccessibleIconButton));
      print('AppResponsiveSheet close button: ${closeBtn.size.width}x${closeBtn.size.height} | >=48x48: ${closeBtn.size.width >= 48 && closeBtn.size.height >= 48 ? "PASS" : "FAIL"}');

      final field = tester.renderObject<RenderBox>(find.byType(FTextField));
      print('FTextField: ${field.size.width}x${field.size.height} | >=48x48: ${field.size.width >= 48 && field.size.height >= 48 ? "PASS" : "FAIL"}');

      final buttons = tester.renderObjectList<RenderBox>(find.descendant(of: find.byType(AppResponsiveSheet), matching: find.byType(FButton)));
      int idx = 0;
      for (final b in buttons) {
        print('Sheet footer FButton [$idx]: ${b.size.width}x${b.size.height} | >=48x48: ${b.size.width >= 48 && b.size.height >= 48 ? "PASS" : "FAIL"}');
        idx++;
      }
    });

    testWidgets('AppDirtyDismissDialog action buttons', (tester) async {
      await tester.pumpWidget(_wrap(const AppDirtyDismissDialog()));
      await tester.pumpAndSettle();

      final buttons = tester.renderObjectList<RenderBox>(find.descendant(of: find.byType(AlertDialog), matching: find.bySubtype<ButtonStyleButton>()));
      int idx = 0;
      final names = ['Continue Editing (TextButton)', 'Discard Changes (FilledButton)'];
      for (final b in buttons) {
        final name = idx < names.length ? names[idx] : 'Button $idx';
        print('AppDirtyDismissDialog $name: ${b.size.width}x${b.size.height} | >=48x48: ${b.size.width >= 48 && b.size.height >= 48 ? "PASS" : "FAIL"}');
        idx++;
      }
    });
  });
}
