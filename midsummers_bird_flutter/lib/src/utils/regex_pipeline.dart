import 'package:collection/collection.dart';

import '../models/regex_rule.dart';

String applyRegexPipeline(List<RegexRule> rules, String text, RegexDirection dir) {
  final sorted = rules.where((r) => r.enabled && r.direction == dir).sorted((a, b) => a.order.compareTo(b.order));
  var out = text;
  for (final r in sorted) {
    try {
      out = out.replaceAll(RegExp(r.pattern, multiLine: true), r.replacement);
    } catch (_) {
      // ignore rule errors
    }
  }
  return out;
}
