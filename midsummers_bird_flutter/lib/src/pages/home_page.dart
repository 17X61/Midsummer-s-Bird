import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../app_state.dart';
import '../models/chat.dart';
import '../models/ai_preset.dart';
import '../models/world_info.dart';
import '../models/regex_rule.dart';
import '../services/api_client.dart';
import '../utils/regex_pipeline.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message_tile.dart';
import '../widgets/side_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatSession? current;
  final ScrollController _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    current = app.sessions.isNotEmpty ? app.sessions.first : app.createSession();
  }

  void _useSession(ChatSession s) {
    setState(() => current = s);
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || current == null || _sending) return;
    final app = context.read<AppState>();
    final session = current!;

    setState(() => _sending = true);

    // Apply input regex pipeline
    final inText = applyRegexPipeline(app.regexRules, text, RegexDirection.input);

    final userMsg = ChatMessage(id: UniqueKey().toString(), role: 'user', content: inText, createdAt: DateTime.now());
    final updated = session.copyWith(messages: [...session.messages, userMsg]);
    app.upsertSession(updated);

    // compose system + regex
    final system = _composeSystem(app);
    final preset = _resolvePreset(app, session);

    final client = SimpleAPIClient(app.api);
    final stream = await client.streamChat(history: updated.messages, preset: preset, system: system);

    String buffer = '';
    final assistantId = UniqueKey().toString();

    final placeholder = ChatMessage(id: assistantId, role: 'assistant', content: '', createdAt: DateTime.now());
    app.upsertSession(updated.copyWith(messages: [...updated.messages, placeholder]));

    final completer = Completer<void>();
    stream.listen((chunk) {
      if (!chunk.done) {
        buffer += chunk.delta;
        final out = applyRegexPipeline(app.regexRules, buffer, RegexDirection.output);
        _patchAssistant(assistantId, out);
      } else {
        completer.complete();
      }
    }, onError: (err) {
      buffer += '\n[error] $err';
      final out = applyRegexPipeline(app.regexRules, buffer, RegexDirection.output);
      _patchAssistant(assistantId, out);
      completer.complete();
    }, onDone: () {
      completer.complete();
    });

    await completer.future;

    setState(() => _sending = false);

    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted && _scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  void _patchAssistant(String id, String content) {
    final app = context.read<AppState>();
    final s = current!;
    final idx = s.messages.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    final msgs = [...s.messages];
    msgs[idx] = ChatMessage(id: id, role: 'assistant', content: content, createdAt: msgs[idx].createdAt);
    final patch = s.copyWith(messages: msgs);
    app.upsertSession(patch);
  }

  AIPreset _resolvePreset(AppState app, ChatSession s) {
    final p = app.aiPresets.where((e) => e.id == s.presetId).toList();
    return p.isNotEmpty ? p.first : (app.aiPresets.isNotEmpty ? app.aiPresets.first : const AIPreset(id: 'balanced', name: 'Balanced', temperature: 0.8, topP: 0.95, presencePenalty: 0.0, frequencyPenalty: 0.0, maxTokens: 1024));
  }

  String _composeSystem(AppState app) {
    // Compose persona + character + world info simplified.
    final user = app.users.firstOrNull;
    final character = app.characters.firstOrNull;
    final persona = user?.persona ?? '';
    final ch = character != null ? 'You are ${character.name}. ${character.persona}' : '';

    // Apply world info by triggers scanning last user message
    final lastUser = current?.messages.lastWhere((m) => m.role == 'user', orElse: () => ChatMessage(id: 'x', role: 'user', content: '', createdAt: DateTime.now()));
    final triggered = <String>[];
    if (lastUser != null) {
      for (final node in app.worldInfo) {
        _collectTriggers(node, lastUser.content.toLowerCase(), triggered);
      }
    }

    return [persona, ch, if (triggered.isNotEmpty) 'World Info: ${triggered.join("\n")}'].where((s) => s.trim().isNotEmpty).join('\n\n');
  }

  void _collectTriggers(WorldInfoNode node, String text, List<String> out) {
    if (node.enabled) {
      final match = node.triggers.any((t) => text.contains(t.toLowerCase()));
      if (match) out.add(node.content);
      for (final c in node.children) {
        _collectTriggers(c, text, out);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = current;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Midsummer's Bird"),
        actions: [
          IconButton(
            icon: Icon(app.isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
            onPressed: () => app.toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.translate_outlined),
            onPressed: () => app.setLocale(app.locale.languageCode == 'en' ? const Locale('zh') : const Locale('en')),
            tooltip: 'Switch language',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: SidePanel(
        current: s,
        onOpenSession: _useSession,
        onNewSession: () => _useSession(app.createSession()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: s?.messages.length ?? 0,
                itemBuilder: (context, index) {
                  final m = s!.messages[index];
                  return ChatMessageTile(message: m);
                },
              ),
            ),
            ChatInput(onSend: _send, busy: _sending),
          ],
        ),
      ),
    );
  }
}
