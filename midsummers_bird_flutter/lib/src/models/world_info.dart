class WorldInfoNode {
  final String id;
  final String title;
  final String content;
  final int depth;
  final int priority;
  final bool enabled;
  final List<String> triggers; // keywords
  final List<WorldInfoNode> children;

  const WorldInfoNode({
    required this.id,
    required this.title,
    required this.content,
    required this.depth,
    required this.priority,
    required this.enabled,
    required this.triggers,
    this.children = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'depth': depth,
        'priority': priority,
        'enabled': enabled,
        'triggers': triggers,
        'children': children.map((e) => e.toJson()).toList(),
      };

  factory WorldInfoNode.fromJson(Map<String, dynamic> json) => WorldInfoNode(
        id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: (json['title'] as String?) ?? 'Node',
        content: (json['content'] as String?) ?? '',
        depth: (json['depth'] as num?)?.toInt() ?? 0,
        priority: (json['priority'] as num?)?.toInt() ?? 0,
        enabled: (json['enabled'] as bool?) ?? true,
        triggers: ((json['triggers'] as List?) ?? const []).cast<String>().toList(),
        children: ((json['children'] as List?) ?? const [])
            .map((e) => WorldInfoNode.fromJson((e ?? const {}) as Map<String, dynamic>))
            .toList(),
      );
}
