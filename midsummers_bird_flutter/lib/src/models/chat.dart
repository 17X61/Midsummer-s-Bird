class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant' | 'system'
  final String content; // markdown
  final DateTime createdAt;
  final List<String> images; // base64 or paths

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.images = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'images': images,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        role: (json['role'] as String?) ?? 'user',
        content: (json['content'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? DateTime.now(),
        images: ((json['images'] as List?) ?? const []).cast<String>().toList(),
      );
}

class ChatSession {
  final String id;
  final String title;
  final String? characterId;
  final String? presetId;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  const ChatSession({
    required this.id,
    required this.title,
    this.characterId,
    this.presetId,
    required this.messages,
    required this.createdAt,
  });

  ChatSession copyWith({
    String? id,
    String? title,
    String? characterId,
    String? presetId,
    List<ChatMessage>? messages,
    DateTime? createdAt,
  }) => ChatSession(
        id: id ?? this.id,
        title: title ?? this.title,
        characterId: characterId ?? this.characterId,
        presetId: presetId ?? this.presetId,
        messages: messages ?? this.messages,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'characterId': characterId,
        'presetId': presetId,
        'messages': messages.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: (json['title'] as String?) ?? 'Chat',
        characterId: json['characterId'] as String?,
        presetId: json['presetId'] as String?,
        messages: ((json['messages'] as List?) ?? const [])
            .map((e) => ChatMessage.fromJson((e ?? const {}) as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      );
}
