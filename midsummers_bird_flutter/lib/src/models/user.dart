class UserProfile {
  final String id;
  final String name;
  final String persona;
  final String language; // 'en' | 'zh' | ...
  final Map<String, dynamic> preferences;

  const UserProfile({
    required this.id,
    required this.name,
    required this.persona,
    required this.language,
    required this.preferences,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? persona,
    String? language,
    Map<String, dynamic>? preferences,
  }) => UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        persona: persona ?? this.persona,
        language: language ?? this.language,
        preferences: preferences ?? this.preferences,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'persona': persona,
        'language': language,
        'preferences': preferences,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: (json['name'] as String?) ?? 'User',
        persona: (json['persona'] as String?) ?? '',
        language: (json['language'] as String?) ?? 'en',
        preferences: (json['preferences'] as Map<String, dynamic>?) ?? const {},
      );
}
