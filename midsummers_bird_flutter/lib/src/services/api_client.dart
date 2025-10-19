import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/api_config.dart';
import '../models/chat.dart';
import '../models/ai_preset.dart';

class StreamChunk {
  final String delta;
  final bool done;
  const StreamChunk({required this.delta, required this.done});
}

class SimpleAPIClient {
  final ApiConfig config;
  const SimpleAPIClient(this.config);

  Future<(int status, String body)> testConnection() async {
    try {
      if (config.provider == 'openai-compat') {
        final url = Uri.parse('${config.baseUrl}/models');
        final resp = await http.get(url, headers: _headers()).timeout(Duration(milliseconds: config.timeoutMs));
        return (resp.statusCode, resp.body);
      }
      if (config.provider == 'gemini') {
        final url = Uri.parse('${config.baseUrl}/models');
        final resp = await http.get(url, headers: _headers()).timeout(Duration(milliseconds: config.timeoutMs));
        return (resp.statusCode, resp.body);
      }
    } catch (e) {
      return (599, e.toString());
    }
    return (400, 'Unsupported provider');
  }

  Future<Stream<StreamChunk>> streamChat({
    required List<ChatMessage> history,
    required AIPreset preset,
    String? system,
  }) async {
    if (config.provider == 'openai-compat') {
      return _openAIStream(history: history, preset: preset, system: system);
    } else if (config.provider == 'gemini') {
      return _geminiStream(history: history, preset: preset, system: system);
    }
    return Stream<StreamChunk>.value(const StreamChunk(delta: 'Unsupported provider', done: true));
  }

  Map<String, String> _headers({bool stream = false}) => {
        HttpHeaders.authorizationHeader: 'Bearer ${config.apiKey}',
        HttpHeaders.contentTypeHeader: 'application/json',
        if (stream) 'Accept': 'text/event-stream',
      };

  Future<Stream<StreamChunk>> _openAIStream({
    required List<ChatMessage> history,
    required AIPreset preset,
    String? system,
  }) async {
    final url = Uri.parse('${config.baseUrl}/chat/completions');
    final messages = [
      if (system != null && system.isNotEmpty) {'role': 'system', 'content': system},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
    ];
    final body = jsonEncode({
      'model': config.model,
      'messages': messages,
      'temperature': preset.temperature,
      'top_p': preset.topP,
      'presence_penalty': preset.presencePenalty,
      'frequency_penalty': preset.frequencyPenalty,
      'max_tokens': preset.maxTokens,
      'stream': true,
    });

    final request = http.Request('POST', url)
      ..headers.addAll(_headers(stream: true))
      ..body = body;

    final response = await request.send().timeout(Duration(milliseconds: config.timeoutMs));

    final controller = StreamController<StreamChunk>();
    response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line.startsWith('data:')) {
        final dataStr = line.substring(5).trim();
        if (dataStr == '[DONE]') {
          controller.add(const StreamChunk(delta: '', done: true));
          controller.close();
        } else {
          try {
            final jsonMap = jsonDecode(dataStr) as Map<String, dynamic>;
            final delta = (jsonMap['choices'] as List?)?.first?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) {
              controller.add(StreamChunk(delta: delta, done: false));
            }
          } catch (_) {}
        }
      }
    }, onDone: () {
      controller.add(const StreamChunk(delta: '', done: true));
      controller.close();
    }, onError: (err, st) {
      controller.add(StreamChunk(delta: '\n[error] $err', done: true));
      controller.close();
    });

    return controller.stream;
  }

  Future<Stream<StreamChunk>> _geminiStream({
    required List<ChatMessage> history,
    required AIPreset preset,
    String? system,
  }) async {
    // Minimal emulation: Gemini lacks SSE in the same manner; we fake a stream by chunking a single response.
    final url = Uri.parse('${config.baseUrl}/models/${config.model}:generateContent');

    final contents = [
      if (system != null && system.isNotEmpty) {
        'role': 'user',
        'parts': [
          {'text': system}
        ]
      },
      ...history.map((m) => {
            'role': m.role == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': m.content}
            ]
          })
    ];

    final body = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': preset.temperature,
        'topP': preset.topP,
        'maxOutputTokens': preset.maxTokens,
      }
    });

    final resp = await http
        .post(url, headers: _headers(), body: body)
        .timeout(Duration(milliseconds: config.timeoutMs));

    final controller = StreamController<StreamChunk>();
    try {
      final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
      final text = (((jsonMap['candidates'] as List?)?.first?['content']?['parts'] as List?)?.first?['text'] as String?) ?? '';
      // chunk into pseudo stream
      const chunk = 40;
      for (int i = 0; i < text.length; i += chunk) {
        final part = text.substring(i, i + chunk > text.length ? text.length : i + chunk);
        controller.add(StreamChunk(delta: part, done: false));
        await Future<void>.delayed(const Duration(milliseconds: 12));
      }
    } catch (e) {
      controller.add(StreamChunk(delta: '\n[error] $e', done: false));
    }
    controller.add(const StreamChunk(delta: '', done: true));
    await controller.close();

    return controller.stream;
  }
}
