import 'dart:convert';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models/api_config.dart';
import 'models/ai_preset.dart';
import 'models/character.dart';
import 'models/chat.dart';
import 'models/user.dart';
import 'models/world_info.dart';
import 'models/regex_rule.dart';
import 'services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;

  AppThemeSpec theme;
  bool isDark;
  Locale locale;

  ApiConfig api;
  final List<UserProfile> users;
  final List<Character> characters;
  final List<AIPreset> aiPresets;
  final List<WorldInfoNode> worldInfo;
  final List<RegexRule> regexRules;
  final List<ChatSession> sessions;

  AppState({
    required StorageService storage,
    required this.theme,
    required this.isDark,
    required this.locale,
    required this.api,
    required this.users,
    required this.characters,
    required this.aiPresets,
    required this.worldInfo,
    required this.regexRules,
    required this.sessions,
  }) : _storage = storage;

  static Future<AppState> bootstrap({required StorageService storage}) async {
    final bootstrap = await storage.loadOrBootstrap();

    return AppState(
      storage: storage,
      theme: bootstrap.theme,
      isDark: bootstrap.isDark,
      locale: bootstrap.locale,
      api: bootstrap.api,
      users: bootstrap.users,
      characters: bootstrap.characters,
      aiPresets: bootstrap.aiPresets,
      worldInfo: bootstrap.worldInfo,
      regexRules: bootstrap.regexRules,
      sessions: bootstrap.sessions,
    );
  }

  Future<void> save() async {
    await _storage.save(this);
  }

  // Theme
  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
    save();
  }

  void updateTheme(AppThemeSpec next) {
    theme = next;
    notifyListeners();
    save();
  }

  // Locale
  void setLocale(Locale l) {
    locale = l;
    notifyListeners();
    save();
  }

  // API
  void updateApi(ApiConfig next) {
    api = next;
    notifyListeners();
    save();
  }

  // Characters
  void upsertCharacter(Character c) {
    final i = characters.indexWhere((e) => e.id == c.id);
    if (i >= 0) {
      characters[i] = c;
    } else {
      characters.add(c);
    }
    notifyListeners();
    save();
  }

  void removeCharacter(String id) {
    characters.removeWhere((e) => e.id == id);
    notifyListeners();
    save();
  }

  // Presets
  void upsertPreset(AIPreset p) {
    final i = aiPresets.indexWhere((e) => e.id == p.id);
    if (i >= 0) {
      aiPresets[i] = p;
    } else {
      aiPresets.add(p);
    }
    notifyListeners();
    save();
  }

  // Regex Rules
  void upsertRegex(RegexRule r) {
    final i = regexRules.indexWhere((e) => e.id == r.id);
    if (i >= 0) {
      regexRules[i] = r;
    } else {
      regexRules.add(r);
    }
    notifyListeners();
    save();
  }

  // Sessions
  ChatSession createSession({String? id, String? characterId, String? presetId}) {
    final session = ChatSession(
      id: id ?? UniqueKey().toString(),
      title: 'New Chat',
      characterId: characterId,
      presetId: presetId,
      messages: [],
      createdAt: DateTime.now(),
    );
    sessions.insert(0, session);
    notifyListeners();
    save();
    return session;
  }

  void upsertSession(ChatSession s) {
    final i = sessions.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      sessions[i] = s;
    } else {
      sessions.add(s);
    }
    notifyListeners();
    save();
  }

  void removeSession(String id) {
    sessions.removeWhere((e) => e.id == id);
    notifyListeners();
    save();
  }
}

class BootstrapData {
  final AppThemeSpec theme;
  final bool isDark;
  final Locale locale;
  final ApiConfig api;
  final List<UserProfile> users;
  final List<Character> characters;
  final List<AIPreset> aiPresets;
  final List<WorldInfoNode> worldInfo;
  final List<RegexRule> regexRules;
  final List<ChatSession> sessions;

  const BootstrapData({
    required this.theme,
    required this.isDark,
    required this.locale,
    required this.api,
    required this.users,
    required this.characters,
    required this.aiPresets,
    required this.worldInfo,
    required this.regexRules,
    required this.sessions,
  });

  Map<String, dynamic> toJson() => {
        'theme': {
          'name': theme.name,
          'light': theme.light,
          'dark': theme.dark,
        },
        'isDark': isDark,
        'locale': locale.languageCode,
        'api': api.toJson(),
        'users': users.map((e) => e.toJson()).toList(),
        'characters': characters.map((e) => e.toJson()).toList(),
        'aiPresets': aiPresets.map((e) => e.toJson()).toList(),
        'worldInfo': worldInfo.map((e) => e.toJson()).toList(),
        'regexRules': regexRules.map((e) => e.toJson()).toList(),
        'sessions': sessions.map((e) => e.toJson()).toList(),
      };

  factory BootstrapData.fromJson(Map<String, dynamic> json) {
    AppThemeSpec theme;
    try {
      theme = AppThemeSpec.fromJson(json['theme'] as Map<String, dynamic>);
    } catch (_) {
      theme = AppThemeSpec.defaults();
    }
    return BootstrapData(
      theme: theme,
      isDark: json['isDark'] as bool? ?? false,
      locale: Locale((json['locale'] as String?) ?? 'en'),
      api: ApiConfig.fromJson(json['api'] as Map<String, dynamic>? ?? const {}),
      users: ((json['users'] as List?) ?? const [])
          .map((e) => UserProfile.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      characters: ((json['characters'] as List?) ?? const [])
          .map((e) => Character.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      aiPresets: ((json['aiPresets'] as List?) ?? const [])
          .map((e) => AIPreset.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      worldInfo: ((json['worldInfo'] as List?) ?? const [])
          .map((e) => WorldInfoNode.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      regexRules: ((json['regexRules'] as List?) ?? const [])
          .map((e) => RegexRule.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
      sessions: ((json['sessions'] as List?) ?? const [])
          .map((e) => ChatSession.fromJson((e ?? const {}) as Map<String, dynamic>))
          .toList(),
    );
  }
}
