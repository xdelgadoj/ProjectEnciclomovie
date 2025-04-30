abstract class NotificationRepository {
  Future<void> initialize(void Function() onNotificationReceived);
}
