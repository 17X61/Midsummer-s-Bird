import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../app_theme.dart';
import '../app_state.dart';
import '../models/api_config.dart';
import '../models/ai_preset.dart';
import '../models/character.dart';
import '../models/chat.dart';
import '../models/user.dart';
import '../models/world_info.dart';
import '../models/regex_rule.dart';

class StorageService {
  static const _fileName = 'app_state.json';

  Future<BootstrapData> loadOrBootstrap() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonMap = jsonDecode(content) as Map<String, dynamic>;
        final data = BootstrapData.fromJson(jsonMap);
        return data;
      }
    } catch (_) {}

    // bootstrap from assets default
    final themeText = await rootBundle.loadString('assets/presets/default_theme.json');
    final themeSpec = AppThemeSpec.fromString(themeText);

    final defaultText = await rootBundle.loadString('assets/presets/default_data.json');
    final jsonMap = jsonDecode(defaultText) as Map<String, dynamic>;

    return BootstrapData(
      theme: themeSpec,
      isDark: false,
      locale: const Locale('en'),
      api: ApiConfig.fromJson(jsonMap['api'] as Map<String, dynamic>),
      users: ((jsonMap['users'] as List?) ?? const [])
          .map((e) => UserProfile.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      characters: ((jsonMap['characters'] as List?) ?? const [])
          .map((e) => Character.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      aiPresets: ((jsonMap['aiPresets'] as List?) ?? const [])
          .map((e) => AIPreset.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      worldInfo: ((jsonMap['worldInfo'] as List?) ?? const [])
          .map((e) => WorldInfoNode.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      regexRules: ((jsonMap['regexRules'] as List?) ?? const [])
          .map((e) => RegexRule.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      sessions: ((jsonMap['sessions'] as List?) ?? const [])
          .map((e) => ChatSession.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> save(AppState state) async {
    final file = await _file();
    final data = BootstrapData(
      theme: state.theme,
      isDark: state.isDark,
      locale: state.locale,
      api: state.api,
      users: state.users,
      characters: state.characters,
      aiPresets: state.aiPresets,
      worldInfo: state.worldInfo,
      regexRules: state.regexRules,
      sessions: state.sessions,
    );
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$_fileName';
    return File(path);
  }
}
