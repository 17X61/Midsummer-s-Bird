class ApiConfig {
  final String provider; // 'openai-compat' | 'gemini'
  final String baseUrl;
  final String apiKey;
  final String model;
  final int timeoutMs;

  const ApiConfig({
    required this.provider,
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    required this.timeoutMs,
  });

  ApiConfig copyWith({
    String? provider,
    String? baseUrl,
    String? apiKey,
    String? model,
    int? timeoutMs,
  }) => ApiConfig(
        provider: provider ?? this.provider,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        timeoutMs: timeoutMs ?? this.timeoutMs,
      );

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'baseUrl': baseUrl,
        'apiKey': apiKey.isNotEmpty ? '***' : '',
        'model': model,
        'timeoutMs': timeoutMs,
      };

  factory ApiConfig.fromJson(Map<String, dynamic> json) => ApiConfig(
        provider: (json['provider'] as String?)?.trim().isNotEmpty == true ? (json['provider'] as String) : 'openai-compat',
        baseUrl: (json['baseUrl'] as String?)?.trim().isNotEmpty == true ? (json['baseUrl'] as String) : 'https://api.openai.com/v1',
        apiKey: (json['apiKey'] as String?) ?? '',
        model: (json['model'] as String?) ?? 'gpt-4o-mini',
        timeoutMs: (json['timeoutMs'] as num?)?.toInt() ?? 60000,
      );
}
