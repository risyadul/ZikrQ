// lib/presentation/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:zikrq/presentation/pages/home/home_page.dart';
import 'package:zikrq/presentation/pages/settings/settings_page.dart';
import 'package:zikrq/presentation/pages/shell/main_shell.dart';
import 'package:zikrq/presentation/pages/statistics/statistics_page.dart';
import 'package:zikrq/presentation/pages/surah_detail/surah_detail_page.dart';
import 'package:zikrq/presentation/pages/surah_list/surah_list_page.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/surahs',
            builder: (context, state) => const SurahListPage(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatisticsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/surahs/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null || id < 1) {
            return const SurahListPage();
          }
          return SurahDetailPage(surahId: id);
        },
      ),
    ],
  );
}
