class NotificationResponse {
  final String message;
  final NotificationData notification;

  NotificationResponse({
    required this.message,
    required this.notification,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      message: json['message'] ?? '',
      notification: NotificationData.fromJson(json['notification'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'notification': notification.toJson(),
    };
  }
}

class NotificationData {
  final String text;
  final String updatedAt;

  NotificationData({
    required this.text,
    required this.updatedAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      text: json['text'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'updatedAt': updatedAt,
    };
  }
} 