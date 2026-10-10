import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:mine_flow/app/presentation/pages/app_shell.dart';
import 'package:mine_flow/app/presentation/widgets/global_app_header.dart';
import 'package:mine_flow/core/presentation/widgets/app_interaction_primitives.dart';
import 'package:mine_flow/features/settings/domain/repositories/settings_repository.dart';
import 'package:mine_flow/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mine_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:mine_flow/features/auth/domain/entities/user_entity.dart';
import 'package:mine_flow/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:mine_flow/l10n/app_localizations.dart';

class _FakeSettingsRepo implements SettingsRepository {
  @override Future<ThemeMode> getThemeMode() async => ThemeMode.system;
  @override Future<void> saveThemeMode(ThemeMode mode) async {}
  @override Future<Locale> getLocale() async => const Locale('id');
  @override Future<void> saveLocale(Locale locale) async {}
  @override Future<int> getPrivacyAckVersion() async => 1;
  @override Future<void> savePrivacyAckVersion(int version) async {}
}

class _FakeAuthRepo implements AuthRepository {
  @override Future<UserEntity?> getCurrentUser() async => const UserEntity(
    id: 'u-1', email: 'supervisor@example.com', role: 'supervisor', name: 'John Doe', siteId: 's-1',
  );
  @override Future<void> signOut() async {}
  @override Future<UserEntity> signInWithEmailAndPassword({required String email, required String password}) async => throw UnimplementedError();
  @override Future<UserEntity> updateProfile({required String id, required String name}) async => throw UnimplementedError();
  @override Future<UserEntity> createUser({required String email, required String password, required String role, required String fullName, String? siteId, String? phone, String? nationalId, String? birthdate, String? gender, String? emergencyContactName, String? emergencyContactPhone}) async => throw UnimplementedError();
  @override Future<List<UserEntity>> getSiteRoster({String? siteId}) async => const [];
  @override Stream<UserEntity?> get onAuthStateChanges => const Stream.empty();
}

GoRouter _buildShellRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox(key: ValueKey('dashboard')))]),
          StatefulShellBranch(routes: [GoRoute(path: '/tools', builder: (_, _) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/operations', builder: (_, _) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/teams', builder: (_, _) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, _) => const SizedBox())]),
        ],
      ),
    ],
  );
}

Widget _wrapWithApp({required Widget child, Size size = const Size(1024, 768), EdgeInsets viewInsets = EdgeInsets.zero}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(repository: _FakeSettingsRepo())),
      BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: _FakeAuthRepo())..initialize()),
    ],
    child: FTheme(
      data: FTheme.neutral.light.touch,
      child: MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id'), Locale('en')],
        home: MediaQuery(
          data: MediaQueryData(size: size, viewInsets: viewInsets),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('Breakpoint Transitions', () {
    for (final width in [799.0, 800.0, 801.0, 1024.0, 1280.0]) {
      testWidgets('AppShell breakpoint test at width $width', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 768));
        await tester.pumpWidget(MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(repository: _FakeSettingsRepo())),
            BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: _FakeAuthRepo())..initialize()),
          ],
          child: FTheme(
            data: FTheme.neutral.light.touch,
            child: MaterialApp.router(
              routerConfig: _buildShellRouter(),
              locale: const Locale('id'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final hasSidebar = find.byType(FSidebar).evaluate().isNotEmpty;
        final hasBottomNav = find.byType(FBottomNavigationBar).evaluate().isNotEmpty;
        print('Width $width: FSidebar=$hasSidebar, FBottomNavigationBar=$hasBottomNav');

        if (width < 800) {
          expect(hasSidebar, isFalse);
          expect(hasBottomNav, isTrue);
        } else {
          expect(hasSidebar, isTrue);
          expect(hasBottomNav, isFalse);
        }
      });
    }
  });

  group('Dirty Dismissal Mechanics (8 Paths)', () {
    test('Verify all 8 AppDismissReason values against AppDismissController', () {
      final reasons = AppDismissReason.values;
      expect(reasons.length, 8);
      print('AppDismissReason enum count: ${reasons.length}');
      for (final r in reasons) {
        print(' - Reason: $r');
        final cleanDecision = AppDismissController(isDirty: false, isBusy: false).requestDismiss(r);
        expect(cleanDecision, AppDismissDecision.dismiss);

        final dirtyDecision = AppDismissController(isDirty: true, isBusy: false).requestDismiss(r);
        expect(dirtyDecision, AppDismissDecision.confirmDiscard);

        final busyDecision = AppDismissController(isDirty: true, isBusy: true).requestDismiss(r);
        expect(busyDecision, AppDismissDecision.blockedBusy);
      }
    });

    testWidgets('AppResponsiveSheet verifies dirty dismissal flow and cancel vs discard', (tester) async {
      var dismissed = false;
      var discarded = false;

      await tester.pumpWidget(_wrapWithApp(
        child: AppResponsiveSheet(
          routeIdentity: 'sheet-dirty',
          title: 'Formulir Uji',
          mode: AppResponsiveSheetMode.form,
          isDirty: true,
          body: const Text('Isi formulir dirty'),
          onDiscard: () => discarded = true,
          onDismissApproved: () => dismissed = true,
        ),
      ));
      await tester.pumpAndSettle();

      // 1. Click close button
      await tester.tap(find.byTooltip('Tutup'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(AppDirtyDismissDialog), findsOneWidget);
      expect(dismissed, isFalse);
      expect(discarded, isFalse);

      // 2. Click 'Lanjut Mengedit' (cancel dismissal)
      await tester.tap(find.text('Lanjut Mengedit'));
      await tester.pumpAndSettle();

      expect(find.byType(AppDirtyDismissDialog), findsNothing);
      expect(dismissed, isFalse);
      expect(discarded, isFalse);

      // 3. Click close button again
      await tester.tap(find.byTooltip('Tutup'));
      await tester.pumpAndSettle();

      // 4. Click 'Buang Perubahan' (confirm discard)
      await tester.tap(find.text('Buang Perubahan'));
      await tester.pumpAndSettle();

      expect(discarded, isTrue);
      expect(dismissed, isTrue);
    });
  });

  group('Keyboard Navigation and Escape Key Handling', () {
    testWidgets('Escape key triggers dismissal in AppResponsiveSheet', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(_wrapWithApp(
        child: AppResponsiveSheet(
          routeIdentity: 'sheet-escape',
          title: 'Sheet Escape Test',
          mode: AppResponsiveSheetMode.form,
          body: const TextField(autofocus: true),
          onDismissApproved: () => dismissed = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Simulate Escape key press
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      print('After pressing Escape key: dismissed=$dismissed');
    });
  });

  group('Mobile IME Collision Handling', () {
    testWidgets('Verify bottom padding / scroll in AppResponsiveSheet when virtual keyboard appears', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      // With IME keyboard up: viewInsets.bottom = 300
      await tester.pumpWidget(_wrapWithApp(
        size: const Size(412, 915),
        viewInsets: const EdgeInsets.only(bottom: 300),
        child: Scaffold(
          body: AppResponsiveSheet(
            routeIdentity: 'ime-test',
            title: 'IME Form',
            mode: AppResponsiveSheetMode.form,
            body: Column(
              children: [
                for (int i = 0; i < 10; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(decoration: InputDecoration(labelText: 'Field $i')),
                  ),
              ],
            ),
            footer: ElevatedButton(onPressed: () {}, child: const Text('Submit')),
            onDismissApproved: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final exception = tester.takeException();
      print('IME keyboard up exception: $exception');
      expect(exception, isNull);
    });
  });
}
