enum RegexDirection { input, output }

class RegexRule {
  final String id;
  final RegexDirection direction;
  final String pattern;
  final String replacement;
  final int order;
  final bool enabled;

  const RegexRule({
    required this.id,
    required this.direction,
    required this.pattern,
    required this.replacement,
    required this.order,
    required this.enabled,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'direction': direction.name,
        'pattern': pattern,
        'replacement': replacement,
        'order': order,
        'enabled': enabled,
      };

  factory RegexRule.fromJson(Map<String, dynamic> json) => RegexRule(
        id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        direction: ((json['direction'] as String?) ?? 'input') == 'input' ? RegexDirection.input : RegexDirection.output,
        pattern: (json['pattern'] as String?) ?? '',
        replacement: (json['replacement'] as String?) ?? '',
        order: (json['order'] as num?)?.toInt() ?? 0,
        enabled: (json['enabled'] as bool?) ?? true,
      );
}
