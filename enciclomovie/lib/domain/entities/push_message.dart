class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sentDate;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final bool isRead;

  PushMessage({
    required this.messageId,
    required this.title,
    required this.body,
    required this.sentDate,
    required this.data,
    this.imageUrl,
    this.isRead = false,
  });

  PushMessage copyWith({
    bool? isRead,
  }) {
    return PushMessage(
      messageId: messageId,
      title: title,
      body: body,
      sentDate: sentDate,
      data: data,
      imageUrl: imageUrl,
      isRead: isRead ?? this.isRead,
    );
  }
}
