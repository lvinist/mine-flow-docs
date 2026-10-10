import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:mine_flow/app/presentation/widgets/global_app_header.dart';
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

GoRouter _buildHeaderRouter({required String initialLocation, VoidCallback? onToggle}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/operations',
        builder: (context, state) => Scaffold(body: GlobalAppHeader(onToggleSidebar: onToggle)),
        routes: [
          GoRoute(
            path: 'cut-fill',
            builder: (context, state) => Scaffold(body: GlobalAppHeader(onToggleSidebar: onToggle)),
          ),
        ],
      ),
    ],
  );
}

Widget _wrapHeader({required Size size, required String initialLocation, VoidCallback? onToggle}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(repository: _FakeSettingsRepo())),
      BlocProvider<AuthCubit>(create: (_) => AuthCubit(repository: _FakeAuthRepo())..initialize()),
    ],
    child: FTheme(
      data: FTheme.neutral.light.touch,
      child: MaterialApp.router(
        routerConfig: _buildHeaderRouter(initialLocation: initialLocation, onToggle: onToggle),
        locale: const Locale('id'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id'), Locale('en')],
        builder: (context, child) => MediaQuery(
          data: MediaQueryData(size: size),
          child: child!,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Breadcrumb target sizes at /operations/cut-fill', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    await tester.pumpWidget(_wrapHeader(size: const Size(1024, 768), initialLocation: '/operations/cut-fill', onToggle: () {}));
    await tester.pumpAndSettle();

    final inkWells = tester.renderObjectList<RenderBox>(find.byType(InkWell));
    int idx = 0;
    for (final ink in inkWells) {
      print('InkWell [$idx]: ${ink.size.width}x${ink.size.height} | >=48x48: ${ink.size.width >= 48 && ink.size.height >= 48 ? "PASS" : "FAIL"}');
      idx++;
    }
  });
}
