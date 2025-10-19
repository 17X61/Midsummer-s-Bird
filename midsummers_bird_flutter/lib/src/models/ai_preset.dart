class AIPreset {
  final String id;
  final String name;
  final String? description;
  final double temperature;
  final double topP;
  final double presencePenalty;
  final double frequencyPenalty;
  final int maxTokens;

  const AIPreset({
    required this.id,
    required this.name,
    this.description,
    required this.temperature,
    required this.topP,
    required this.presencePenalty,
    required this.frequencyPenalty,
    required this.maxTokens,
  });

  AIPreset copyWith({
    String? id,
    String? name,
    String? description,
    double? temperature,
    double? topP,
    double? presencePenalty,
    double? frequencyPenalty,
    int? maxTokens,
  }) => AIPreset(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        temperature: temperature ?? this.temperature,
        topP: topP ?? this.topP,
        presencePenalty: presencePenalty ?? this.presencePenalty,
        frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
        maxTokens: maxTokens ?? this.maxTokens,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'temperature': temperature,
        'topP': topP,
        'presencePenalty': presencePenalty,
        'frequencyPenalty': frequencyPenalty,
        'maxTokens': maxTokens,
      };

  factory AIPreset.fromJson(Map<String, dynamic> json) => AIPreset(
        id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: (json['name'] as String?) ?? 'Preset',
        description: json['description'] as String?,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.8,
        topP: (json['topP'] as num?)?.toDouble() ?? 0.95,
        presencePenalty: (json['presencePenalty'] as num?)?.toDouble() ?? 0.0,
        frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble() ?? 0.0,
        maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 1024,
      );
}
