import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:mine_flow/app/presentation/pages/app_shell.dart';
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
    id: 'u-1', email: 'supervisor@example.com', role: 'supervisor', name: 'John Doe Administrator Long Name', siteId: 's-1',
  );
  @override Future<void> signOut() async {}
  @override Future<UserEntity> signInWithEmailAndPassword({required String email, required String password}) async => throw UnimplementedError();
  @override Future<UserEntity> updateProfile({required String id, required String name}) async => throw UnimplementedError();
  @override Future<UserEntity> createUser({required String email, required String password, required String role, required String fullName, String? siteId, String? phone, String? nationalId, String? birthdate, String? gender, String? emergencyContactName, String? emergencyContactPhone}) async => throw UnimplementedError();
  @override Future<List<UserEntity>> getSiteRoster({String? siteId}) async => const [];
  @override Stream<UserEntity?> get onAuthStateChanges => const Stream.empty();
}

GoRouter _buildShellRouter({Widget? child}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, _) => child ?? const SizedBox(key: ValueKey('dashboard')))]),
          StatefulShellBranch(routes: [GoRoute(path: '/tools', builder: (_, _) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/operations', builder: (_, _) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/teams', builder: (_, _) => const SizedBox())]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, _) => const SizedBox())]),
        ],
      ),
    ],
  );
}

Widget _wrapShell({required Size size, double textScale = 1.0, Widget? child}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(repository: _FakeSettingsRepo())),
      BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: _FakeAuthRepo())..initialize()),
    ],
    child: FTheme(
      data: FTheme.neutral.light.touch,
      child: MaterialApp.router(
        routerConfig: _buildShellRouter(child: child),
        locale: const Locale('id'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id'), Locale('en')],
        builder: (context, routerChild) => MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: routerChild!,
        ),
      ),
    ),
  );
}

void main() {
  group('Text Scaling and Layout Resilience Audit', () {
    final viewports = [
      {'name': 'Desktop Wide (1280x800)', 'size': const Size(1280, 800)},
      {'name': 'Desktop Standard (1024x768)', 'size': const Size(1024, 768)},
      {'name': 'Desktop Breakpoint Boundary (800x768)', 'size': const Size(800, 768)},
      {'name': 'Mobile Breakpoint Boundary (799x768)', 'size': const Size(799, 768)},
      {'name': 'Android Pixel_6a (412x915)', 'size': const Size(412, 915)},
    ];

    for (final vp in viewports) {
      final vpName = vp['name'] as String;
      final size = vp['size'] as Size;

      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('AppShell at $vpName with scale ${scale}x', (tester) async {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(_wrapShell(size: size, textScale: scale));
          await tester.pumpAndSettle();

          final exception = tester.takeException();
          if (exception != null) {
            print('OVERFLOW/EXCEPTION at $vpName, scale ${scale}x: $exception');
          }
          expect(exception, isNull, reason: 'Layout must not overflow or throw at $vpName, scale ${scale}x');
        });
      }
    }

    testWidgets('AppResponsiveSheet at scale 2.0x on Mobile (412x915)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: FTheme(
            data: FTheme.neutral.light.touch,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(412, 915),
                textScaler: TextScaler.linear(2.0),
              ),
              child: Scaffold(
                body: AppResponsiveSheet(
                  routeIdentity: 'scale-test',
                  title: 'Judul Panjang Sekali Untuk Menguji Text Scaling Ekstrem',
                  subtitle: 'Subjudul konteks formulir yang sangat detail dan deskriptif',
                  mode: AppResponsiveSheetMode.form,
                  body: Column(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FTextField(hint: 'Field $i'),
                        ),
                    ],
                  ),
                  footer: Row(
                    children: [
                      Expanded(child: FButton(variant: FButtonVariant.outline, onPress: () {}, child: const Text('Batal'))),
                      const SizedBox(width: 8),
                      Expanded(child: FButton(onPress: () {}, child: const Text('Simpan Perubahan'))),
                    ],
                  ),
                  onDismissApproved: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final exception = tester.takeException();
      expect(exception, isNull);
    });
  });
}
