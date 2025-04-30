import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enciclomovie/domain/entities/push_message.dart';
import 'package:enciclomovie/presentation/blocs/notifications/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget {
  static const name = 'details-screen';

  final String pushMessageId;

  const DetailsScreen({super.key, required this.pushMessageId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<NotificationsBloc>();
    final PushMessage? message = bloc.getMessageById(pushMessageId);

    // ✅ Marcar como leída si aún no lo está
    if (message != null && !message.isRead) {
      context.read<NotificationsBloc>().add(MarkNotificationAsRead(message.messageId));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Notificación'),
      ),
      body: message != null
          ? _DetailsView(message: message)
          : const Center(
              child: Text(
                'Notificación no encontrada',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  final PushMessage message;

  const _DetailsView({required this.message});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                message.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              ),
            ),

          const SizedBox(height: 24),

          Text(
            message.title,
            style: textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Text(
            message.body,
            style: textStyles.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),

          const SizedBox(height: 24),

          const Divider(thickness: 1),

          const SizedBox(height: 16),

          Text(
            'Datos adicionales',
            style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          if (message.data!.isNotEmpty) ...message.data!.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.label_outline, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: textStyles.bodySmall?.copyWith(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          )
          else
            Center(
              child: Text(
                'Sin datos adicionales',
                style: textStyles.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
