import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine_flow/app/presentation/pages/app_shell.dart';
import 'package:mine_flow/app/presentation/widgets/global_app_header.dart';
import 'package:mine_flow/features/settings/domain/repositories/settings_repository.dart';
import 'package:mine_flow/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mine_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:mine_flow/features/auth/domain/entities/user_entity.dart';
import 'package:mine_flow/features/auth/presentation/bloc/auth_cubit.dart';

class _FakeSettingsRepository implements SettingsRepository {
  @override Future<ThemeMode> getThemeMode() async => ThemeMode.system;
  @override Future<void> saveThemeMode(ThemeMode mode) async {}
  @override Future<Locale> getLocale() async => const Locale('id');
  @override Future<void> saveLocale(Locale locale) async {}
  @override Future<int> getPrivacyAckVersion() async => 0;
  @override Future<void> savePrivacyAckVersion(int version) async {}
}

class _FakeAuthRepository implements AuthRepository {
  @override Future<UserEntity?> getCurrentUser() async => const UserEntity(id: '1', email: 'test@example.com', role: 'supervisor', name: 'John Doe Administrator Long Name');
  @override Future<void> signOut() async {}
  @override Future<UserEntity> signInWithEmailAndPassword({required String email, required String password}) async => throw UnimplementedError();
  @override Future<UserEntity> updateProfile({required String id, required String name}) async => throw UnimplementedError();
  @override Future<UserEntity> createUser({required String email, required String password, required String role, required String fullName, String? siteId, String? phone, String? nationalId, String? birthdate, String? gender, String? emergencyContactName, String? emergencyContactPhone}) async => throw UnimplementedError();
  @override Future<List<UserEntity>> getSiteRoster({String? siteId}) async => const [];
  @override Stream<UserEntity?> get onAuthStateChanges => const Stream.empty();
}

GoRouter _buildTestRouter() {
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

Widget _wrapWithProviders(GoRouter router, {double textScale = 1.0}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(repository: _FakeSettingsRepository())),
      BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: _FakeAuthRepository())..init()),
    ],
    child: FTheme(
      data: FTheme.neutral.light.touch,
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
}

void main() {
  group('Breakpoint and Scaling Audit', () {
    for (final width in [799.0, 800.0, 801.0, 1024.0, 1280.0]) {
      testWidgets('Audit layout at width $width', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 768));
        await tester.pumpWidget(_wrapWithProviders(_buildTestRouter()));
        await tester.pumpAndSettle();

        final hasSidebar = find.byType(FSidebar).evaluate().isNotEmpty;
        final hasBottomNav = find.byType(FBottomNavigationBar).evaluate().isNotEmpty;
        final hasPanelLeftIcon = find.byIcon(Icons.panel_left, skipOffstage: false).evaluate().isNotEmpty;

        print('Width $width: sidebar=$hasSidebar, bottomNav=$hasBottomNav');
      });
    }

    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('Audit text scale $scale at 1024x768', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));
        await tester.pumpWidget(_wrapWithProviders(_buildTestRouter(), textScale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Audit text scale $scale at 412x915 (Android)', (tester) async {
        await tester.binding.setSurfaceSize(const Size(412, 915));
        await tester.pumpWidget(_wrapWithProviders(_buildTestRouter(), textScale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
