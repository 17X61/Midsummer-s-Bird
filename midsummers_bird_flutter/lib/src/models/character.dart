class Character {
  final String id;
  final String name;
  final String persona;
  final String greeting;
  final List<String> greetings;
  final String? image; // base64 or path

  const Character({
    required this.id,
    required this.name,
    required this.persona,
    required this.greeting,
    required this.greetings,
    this.image,
  });

  Character copyWith({
    String? id,
    String? name,
    String? persona,
    String? greeting,
    List<String>? greetings,
    String? image,
  }) => Character(
        id: id ?? this.id,
        name: name ?? this.name,
        persona: persona ?? this.persona,
        greeting: greeting ?? this.greeting,
        greetings: greetings ?? this.greetings,
        image: image ?? this.image,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'persona': persona,
        'greeting': greeting,
        'greetings': greetings,
        'image': image,
      };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: (json['name'] as String?) ?? 'Character',
        persona: (json['persona'] as String?) ?? '',
        greeting: (json['greeting'] as String?) ?? '',
        greetings: ((json['greetings'] as List?) ?? const []).cast<String>().toList(),
        image: json['image'] as String?,
      );
}
