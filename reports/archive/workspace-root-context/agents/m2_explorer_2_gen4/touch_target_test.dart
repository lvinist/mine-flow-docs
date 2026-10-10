import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mine_flow/core/presentation/widgets/app_interaction_primitives.dart';
import 'package:mine_flow/app/presentation/widgets/global_app_header.dart';
import 'package:mine_flow/l10n/app_localizations.dart';

Widget _wrap(Widget child, {Size size = const Size(412, 915)}) {
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
  group('Touch Target Geometry Audit (>=48x48dp)', () {
    testWidgets('Audit FButton variants size', (tester) async {
      await tester.pumpWidget(_wrap(
        Column(
          children: [
            FButton(
              onPress: () {},
              child: const Text('Primary Button'),
            ),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () {},
              child: const Text('Outline Button'),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () {},
              child: const Icon(LucideIcons.panelLeft, size: 18),
            ),
            FButton.icon(
              onPress: () {},
              child: const Icon(LucideIcons.plus),
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      final buttons = tester.renderObjectList<RenderBox>(find.byType(FButton));
      int idx = 0;
      final names = ['Primary', 'Outline', 'Ghost Icon', 'FButton.icon'];
      for (final b in buttons) {
        final size = b.size;
        print('FButton [${names[idx++]}]: size=${size.width}x${size.height} | >=48x48: ${size.width >= 48 && size.height >= 48 ? "PASS" : "FAIL"}');
      }
    });

    testWidgets('Audit FBottomNavigationBar and items', (tester) async {
      await tester.pumpWidget(_wrap(
        Scaffold(
          bottomNavigationBar: FBottomNavigationBar(
            index: 0,
            onChange: (_) {},
            children: const [
              FBottomNavigationBarItem(
                icon: Icon(LucideIcons.layoutDashboard),
                label: Text('Dashboard'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(LucideIcons.wrench),
                label: Text('Tools'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(LucideIcons.hardHat),
                label: Text('Operations'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(LucideIcons.users),
                label: Text('Teams'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(LucideIcons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
        ),
        size: const Size(412, 915),
      ));
      await tester.pumpAndSettle();

      final navBarBox = tester.renderObject<RenderBox>(find.byType(FBottomNavigationBar));
      print('FBottomNavigationBar size: ${navBarBox.size.width}x${navBarBox.size.height}');

      final items = tester.renderObjectList<RenderBox>(find.byType(FBottomNavigationBarItem));
      int idx = 0;
      for (final item in items) {
        final size = item.size;
        print('FBottomNavigationBarItem [$idx]: size=${size.width}x${size.height} | >=48x48: ${size.width >= 48 && size.height >= 48 ? "PASS" : "FAIL"}');
        idx++;
      }
    });

    testWidgets('Audit FSidebar and items', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          width: 256,
          height: 800,
          child: FSidebar(
            children: [
              FSidebarGroup(
                label: const Text('General'),
                children: [
                  FSidebarItem(
                    icon: const Icon(LucideIcons.layoutDashboard),
                    label: const Text('Dashboard'),
                    onPress: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        size: const Size(1024, 800),
      ));
      await tester.pumpAndSettle();

      final item = tester.renderObject<RenderBox>(find.byType(FSidebarItem));
      print('FSidebarItem size: ${item.size.width}x${item.size.height} | >=48x48: ${item.size.width >= 48 && item.size.height >= 48 ? "PASS" : "FAIL"}');
    });

    testWidgets('Audit AppAccessibleIconButton, AppStatusBadge, AppFilterPopover', (tester) async {
      await tester.pumpWidget(_wrap(
        Column(
          children: [
            AppAccessibleIconButton(
              tooltip: 'Tutup',
              icon: Icons.close,
              onPressed: () {},
            ),
            const AppStatusBadge(label: 'Aktif'),
            AppFilterPopover(
              onApply: () {},
              onReset: () {},
              onCancel: () {},
              child: const Text('Filter content'),
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      final iconBtn = tester.renderObject<RenderBox>(find.byType(AppAccessibleIconButton));
      print('AppAccessibleIconButton size: ${iconBtn.size.width}x${iconBtn.size.height} | >=48x48: ${iconBtn.size.width >= 48 && iconBtn.size.height >= 48 ? "PASS" : "FAIL"}');

      final badge = tester.renderObject<RenderBox>(find.byType(AppStatusBadge));
      print('AppStatusBadge size: ${badge.size.width}x${badge.size.height} | >=48x48: ${badge.size.width >= 48 && badge.size.height >= 48 ? "PASS" : "FAIL"}');

      final popoverBtns = tester.renderObjectList<RenderBox>(find.descendant(
        of: find.byType(AppFilterPopover),
        matching: find.bySubtype<ButtonStyleButton>(),
      ));
      for (final btn in popoverBtns) {
        print('Popover button: size=${btn.size.width}x${btn.size.height} | >=48x48: ${btn.size.width >= 48 && btn.size.height >= 48 ? "PASS" : "FAIL"}');
      }
    });
  });
}
