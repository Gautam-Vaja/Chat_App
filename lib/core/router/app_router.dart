import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/main_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/user_screen/user_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String root = '/';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String user = '/user';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.root,
  routes: [
    GoRoute(
      path: AppRoutes.root,
      name: 'main',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.user,
      name: 'user',
      builder: (context, state) {
        final userName = state.extra is String ? state.extra as String : null;
        return UserScreen(userName: userName);
      },
    ),
  ],
);

