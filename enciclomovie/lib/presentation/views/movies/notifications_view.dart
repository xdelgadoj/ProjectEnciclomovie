import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enciclomovie/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:go_router/go_router.dart';

enum NotificationFilter { all, unread }

class NotificationsView extends StatefulWidget {
  static const name = 'notifications-view';

  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  NotificationFilter _filter = NotificationFilter.all;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final status = context.select((NotificationsBloc bloc) => bloc.state.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notificaciones (${status.name})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Filtro con ícono y color dinámico
          PopupMenuButton<NotificationFilter>(
          tooltip: 'Filtrar notificaciones',
          icon: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
            final unreadCount = state.notifications.where((n) => !n.isRead).length;

            // Filtro activo con badge solo si estamos en "Todas"
            final showBadge = _filter == NotificationFilter.all && unreadCount > 0;

            return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                _filter == NotificationFilter.unread
                    ? Icons.filter_list
                    : Icons.filter_alt_outlined,
                color: _filter == NotificationFilter.unread
                    ? Colors.redAccent
                    : Colors.grey,
              ),
              if (showBadge)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ],
              );
            },
            ),

            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: NotificationFilter.all,
                checked: _filter == NotificationFilter.all,
                child: const Text('Todas'),
              ),
              CheckedPopupMenuItem(
                value: NotificationFilter.unread,
                checked: _filter == NotificationFilter.unread,
                child: const Text('No leídas'),
              ),
            ],
          ),

          IconButton(
            onPressed: () {
              context.read<NotificationsBloc>().requestPermission();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final allNotifications = state.notifications;
          final notifications = _filter == NotificationFilter.unread
              ? allNotifications.where((n) => !n.isRead).toList()
              : allNotifications;

          final hasUnread = allNotifications.any((n) => !n.isRead);
          final hasNotifications = allNotifications.isNotEmpty;

          if (!hasNotifications) {
            return const Center(
              child: Text(
                'No hay notificaciones',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasUnread)
                      _isProcessing
                          ? const SizedBox(
                              height: 36,
                              width: 36,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton.icon(
                              onPressed: () async {
                                setState(() => _isProcessing = true);
                                context
                                    .read<NotificationsBloc>()
                                    .add(MarkAllNotificationsRead());

                                await Future.delayed(const Duration(milliseconds: 300));
                                setState(() => _isProcessing = false);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Todas las notificaciones fueron marcadas como leídas.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.mark_email_read_outlined),
                              label: const Text('Marcar todas como leídas'),
                            ),
                    TextButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar todas'),
                                      content: const Text(
                                          '¿Estás seguro de que deseas eliminar todas las notificaciones?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (confirm) {
                                setState(() => _isProcessing = true);

                                for (final notification in allNotifications) {
                                  context.read<NotificationsBloc>().add(
                                      NotificationDeleted(notification.messageId));
                                }

                                await Future.delayed(const Duration(milliseconds: 400));
                                setState(() => _isProcessing = false);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Todas las notificaciones fueron eliminadas.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar todas'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    return Dismissible(
                      key: Key(notification.messageId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        context
                            .read<NotificationsBloc>()
                            .add(NotificationDeleted(notification.messageId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificación eliminada')),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (!notification.isRead) {
                            context
                                .read<NotificationsBloc>()
                                .add(MarkNotificationAsRead(notification.messageId));
                          }
                          Future.microtask(() {
                            context.push('/push-details/${notification.messageId}');
                          });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                          color: notification.isRead
                              ? Colors.white
                              : Colors.grey.shade100.withOpacity(0.95),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notification.imageUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      notification.imageUrl!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: notification.isRead
                                                    ? Colors.black87
                                                    : Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                          if (!notification.isRead)
                                            Container(
                                              width: 10,
                                              height: 10,
                                              margin: const EdgeInsets.only(left: 6),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.body,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatDate(notification.sentDate),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
