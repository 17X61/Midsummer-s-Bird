import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/chat.dart';

class ChatMessageTile extends StatelessWidget {
  final ChatMessage message;
  const ChatMessageTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Container(
            decoration: BoxDecoration(
              color: isUser ? theme.colorScheme.primary.withOpacity(0.10) : theme.cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: MarkdownBody(
              data: message.content.isEmpty ? '…' : message.content,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                a: TextStyle(color: theme.colorScheme.primary),
                p: theme.textTheme.bodyMedium!,
                code: TextStyle(
                  backgroundColor: theme.colorScheme.surface,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
