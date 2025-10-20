import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/chat.dart';
import '../models/character.dart';
import '../models/ai_preset.dart';
import '../services/api_client.dart';
import 'side_sheet.dart';

class SidePanel extends StatelessWidget {
  final ChatSession? current;
  final void Function(ChatSession) onOpenSession;
  final VoidCallback onNewSession;
  const SidePanel({super.key, required this.current, required this.onOpenSession, required this.onNewSession});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('New chat'),
              leading: const Icon(Icons.add_comment_outlined),
              onTap: onNewSession,
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Sessions', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  for (final s in app.sessions)
                    ListTile(
                      selected: current?.id == s.id,
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(s.title.isEmpty ? 'Chat' : s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => onOpenSession(s),
                    ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Managers', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  ListTile(
                    leading: const Icon(Icons.api_outlined),
                    title: const Text('API Manager'),
                    onTap: () => showSideSheet(context, const _ApiManagerSheet()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.face_3_outlined),
                    title: const Text('Characters'),
                    onTap: () => showSideSheet(context, const _CharacterManagerSheet()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.tune_outlined),
                    title: const Text('AI Presets'),
                    onTap: () => showSideSheet(context, const _PresetManagerSheet()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.public_outlined),
                    title: const Text('World Info'),
                    onTap: () => showSideSheet(context, const _WorldInfoManagerSheet()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.rule_folder_outlined),
                    title: const Text('Regex Pipelines'),
                    onTap: () => showSideSheet(context, const _RegexManagerSheet()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Theme Editor'),
                    onTap: () => showSideSheet(context, const _ThemeManagerSheet()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Users & Preferences'),
                    onTap: () => showSideSheet(context, const _UserManagerSheet()),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.translate_outlined),
              title: const Text('中文 / English'),
              onTap: () {
                final app = context.read<AppState>();
                app.setLocale(app.locale.languageCode == 'en' ? const Locale('zh') : const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiManagerSheet extends StatelessWidget {
  const _ApiManagerSheet();
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final api = app.api;
    final provider = TextEditingController(text: api.provider);
    final baseUrl = TextEditingController(text: api.baseUrl);
    final model = TextEditingController(text: api.model);
    final key = TextEditingController(text: api.apiKey);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('API Manager', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(controller: provider, decoration: const InputDecoration(labelText: 'Provider (openai-compat | gemini)')),
          const SizedBox(height: 8),
          TextField(controller: baseUrl, decoration: const InputDecoration(labelText: 'Base URL')),
          const SizedBox(height: 8),
          TextField(controller: model, decoration: const InputDecoration(labelText: 'Model')),
          const SizedBox(height: 8),
          TextField(controller: key, decoration: const InputDecoration(labelText: 'API Key'), obscureText: true),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: () async {
                  app.updateApi(app.api.copyWith(provider: provider.text.trim(), baseUrl: baseUrl.text.trim(), model: model.text.trim(), apiKey: key.text.trim()));
                  final client = SimpleAPIClient(app.api);
                  final (status, body) = await client.testConnection();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Test: $status')));
                },
                child: const Text('Save & Test'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          )
        ],
      ),
    );
  }
}

class _CharacterManagerSheet extends StatelessWidget {
  const _CharacterManagerSheet();
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Characters', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: app.characters.length,
            itemBuilder: (context, index) {
              final c = app.characters[index];
              return ListTile(
                title: Text(c.name),
                subtitle: Text(c.persona, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, c)),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: () => _edit(context, null), icon: const Icon(Icons.add), label: const Text('Add')),
      ]),
    );
  }

  void _edit(BuildContext context, Character? c) {
    final name = TextEditingController(text: c?.name);
    final persona = TextEditingController(text: c?.persona);
    final greeting = TextEditingController(text: c?.greeting);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(c == null ? 'New character' : 'Edit character'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(controller: persona, maxLines: 3, decoration: const InputDecoration(labelText: 'Persona')),
              const SizedBox(height: 8),
              TextField(controller: greeting, maxLines: 3, decoration: const InputDecoration(labelText: 'Greeting')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final app = context.read<AppState>();
              final next = Character(
                id: c?.id ?? UniqueKey().toString(),
                name: name.text,
                persona: persona.text,
                greeting: greeting.text,
                greetings: c?.greetings ?? const [],
                image: c?.image,
              );
              app.upsertCharacter(next);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

class _PresetManagerSheet extends StatelessWidget {
  const _PresetManagerSheet();
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AI Presets', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: app.aiPresets.length,
            itemBuilder: (context, index) {
              final p = app.aiPresets[index];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(p.description ?? ''),
                trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, p)),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: () => _edit(context, null), icon: const Icon(Icons.add), label: const Text('Add')),
      ]),
    );
  }

  void _edit(BuildContext context, AIPreset? p) {
    final name = TextEditingController(text: p?.name);
    final temp = TextEditingController(text: (p?.temperature ?? 0.8).toString());
    final topp = TextEditingController(text: (p?.topP ?? 0.95).toString());
    final pres = TextEditingController(text: (p?.presencePenalty ?? 0.0).toString());
    final freq = TextEditingController(text: (p?.frequencyPenalty ?? 0.0).toString());
    final max = TextEditingController(text: (p?.maxTokens ?? 1024).toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p == null ? 'New preset' : 'Edit preset'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(controller: temp, decoration: const InputDecoration(labelText: 'Temperature')), 
              const SizedBox(height: 8),
              TextField(controller: topp, decoration: const InputDecoration(labelText: 'Top P')),
              const SizedBox(height: 8),
              TextField(controller: pres, decoration: const InputDecoration(labelText: 'Presence penalty')),
              const SizedBox(height: 8),
              TextField(controller: freq, decoration: const InputDecoration(labelText: 'Frequency penalty')),
              const SizedBox(height: 8),
              TextField(controller: max, decoration: const InputDecoration(labelText: 'Max tokens')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final app = context.read<AppState>();
              final next = AIPreset(
                id: p?.id ?? UniqueKey().toString(),
                name: name.text,
                description: '',
                temperature: double.tryParse(temp.text) ?? 0.8,
                topP: double.tryParse(topp.text) ?? 0.95,
                presencePenalty: double.tryParse(pres.text) ?? 0.0,
                frequencyPenalty: double.tryParse(freq.text) ?? 0.0,
                maxTokens: int.tryParse(max.text) ?? 1024,
              );
              app.upsertPreset(next);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

class _WorldInfoManagerSheet extends StatelessWidget {
  const _WorldInfoManagerSheet();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('World Info', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Expanded(child: Center(child: Text('Add and manage hierarchical world info.'))),
      ]),
    );
  }
}

class _RegexManagerSheet extends StatelessWidget {
  const _RegexManagerSheet();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Regex Pipelines', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Expanded(child: Center(child: Text('Create regex rules for input/output transformation.'))),
      ]),
    );
  }
}

class _ThemeManagerSheet extends StatelessWidget {
  const _ThemeManagerSheet();
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Theme Editor', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(children: [
          Text('Mode:'),
          const SizedBox(width: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Light')),
              ButtonSegment(value: true, label: Text('Dark')),
            ],
            selected: {app.isDark},
            onSelectionChanged: (v) => app.toggleTheme(),
          ),
        ]),
      ]),
    );
  }
}

class _UserManagerSheet extends StatelessWidget {
  const _UserManagerSheet();
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Users & Preferences', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...app.users.map((u) => ListTile(title: Text(u.name), subtitle: Text(u.persona))).toList(),
      ]),
    );
  }
}
