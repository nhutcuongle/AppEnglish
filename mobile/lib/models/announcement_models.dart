class Announcement {
  final String id;
  final String title;
  final String content;
  final String senderId;
  final String senderName;
  final String? targetClassId; // null if school announcement
  final String type;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.senderId,
    required this.senderName,
    this.targetClassId,
    required this.type,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      targetClassId: json['targetClassId'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'targetClassId': targetClassId,
      'type': type,
    };
  }
}
