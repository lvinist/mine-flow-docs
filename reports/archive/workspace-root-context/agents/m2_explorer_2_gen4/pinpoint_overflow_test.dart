import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:mine_flow/app/presentation/pages/app_shell.dart';
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

void main() {
  testWidgets('Pinpoint overflow at 1280x800', (tester) async {
    FlutterErrorDetails? errorDetails;
    FlutterError.onError = (details) {
      errorDetails = details;
    };

    final router = GoRouter(
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

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(repository: _FakeSettingsRepo())),
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: _FakeAuthRepo())..initialize()),
        ],
        child: FTheme(
          data: FTheme.neutral.light.touch,
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('id'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('id'), Locale('en')],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    if (errorDetails != null) {
      print('=== ERROR DETAILS ===');
      print(errorDetails!.summary);
      print('Context: ${errorDetails!.context}');
      print('Information:');
      for (final line in errorDetails!.informationCollector?.call() ?? []) {
        print(line);
      }
    }
  });
}
