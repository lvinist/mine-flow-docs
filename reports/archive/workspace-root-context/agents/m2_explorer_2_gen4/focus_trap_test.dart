import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mine_flow/core/presentation/widgets/app_interaction_primitives.dart';
import 'package:mine_flow/l10n/app_localizations.dart';

Widget _wrapWithFocus(Widget child) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: FTheme(
      data: FTheme.neutral.light.touch,
      child: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  testWidgets('Test focus trapping in AppResponsiveSheet', (tester) async {
    final bgFocus = FocusNode(debugLabel: 'bgButton');
    final fieldFocus = FocusNode(debugLabel: 'sheetField');

    await tester.pumpWidget(_wrapWithFocus(
      Stack(
        children: [
          // Background content
          ElevatedButton(
            focusNode: bgFocus,
            onPressed: () {},
            child: const Text('Background Button'),
          ),
          // Foreground sheet
          AppResponsiveSheet(
            routeIdentity: 'sheet-focus',
            title: 'Sheet Focus',
            mode: AppResponsiveSheetMode.form,
            body: TextField(
              focusNode: fieldFocus,
              autofocus: true,
            ),
            footer: ElevatedButton(
              onPressed: () {},
              child: const Text('Footer Action'),
            ),
            onDismissApproved: () {},
          ),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(fieldFocus.hasFocus, isTrue);

    // Tab to next element
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // Tab again
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // Tab again
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    print('Is background focused? ${bgFocus.hasFocus}');
    expect(bgFocus.hasFocus, isFalse, reason: 'Focus should be trapped inside the modal sheet!');
  });
}
