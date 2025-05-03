/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:enciclomovie/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:enciclomovie/presentation/providers/providers.dart';
import 'package:enciclomovie/presentation/widgets/widgets.dart';
import 'package:enciclomovie/presentation/views/views.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({
    super.key,
    required this.pageIndex,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late PageController pageController;
  late final StreamSubscription _blocSubscription;

  final viewRoutes = const <Widget>[
    HomeView(),
    PopularView(),
    FavoritesView(),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(keepPage: true);

    // Escucha cambios en NotificationsBloc y actualiza el contador de no leídas
    _blocSubscription = context.read<NotificationsBloc>().stream.listen((state) {
      final unreadCount = state.notifications.where((n) => !n.isRead).length;
      ref.read(notificationCountProvider.notifier).state = unreadCount;
    });
  }

  @override
  void dispose() {
    _blocSubscription.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (pageController.hasClients) {
      pageController.animateToPage(
        widget.pageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: CustomAppbar(
          onNotificationsTap: () {            
            context.push('/notifications');
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: viewRoutes,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: widget.pageIndex,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:enciclomovie/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:enciclomovie/presentation/providers/providers.dart';
import 'package:enciclomovie/presentation/widgets/widgets.dart';
import 'package:enciclomovie/presentation/views/views.dart';
import 'package:enciclomovie/presentation/providers/auth/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({
    super.key,
    required this.pageIndex,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late PageController pageController;
  late final StreamSubscription _blocSubscription;

  final viewRoutes = const <Widget>[
    HomeView(),
    PopularView(),
    FavoritesView(),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(keepPage: true);

    _blocSubscription = context.read<NotificationsBloc>().stream.listen((state) {
      final unreadCount = state.notifications.where((n) => !n.isRead).length;
      ref.read(notificationCountProvider.notifier).state = unreadCount;
    });
  }

  @override
  void dispose() {
    _blocSubscription.cancel();
    pageController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await ref.read(authControllerProvider.notifier).signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (pageController.hasClients) {
      pageController.animateToPage(
        widget.pageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: CustomAppbar(
          onNotificationsTap: () {
            context.push('/notifications');
          },
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: viewRoutes,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: widget.pageIndex,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
