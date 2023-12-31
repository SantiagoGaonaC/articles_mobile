import 'package:articles_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:articles_flutter/features/auth/presentation/screens/check_auth_status_screen.dart';
import 'package:articles_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:articles_flutter/features/products/presentation/screens/products_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_router_notifier.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/check-auth-status',
    refreshListenable: goRouterNotifier,
    routes: [
      ///* Primera pantalla Default
      GoRoute(
        path: '/check-auth-status',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),

      ///* Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      ///* ProductsDriveScreen Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const ProductsScreen(),
      ),
    ],
    redirect: (context, state) {
      final isGoingTo = state.matchedLocation;

      final authStatus = goRouterNotifier.authStatus;

      if (isGoingTo == '/check-auth-status' &&
          authStatus == AuthStatus.checking) {
        return null;
      }

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo == '/login') return null;

        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' || isGoingTo == '/check-auth-status') {
          return '/';
        }
      }
      return null;
    },
  );
});
