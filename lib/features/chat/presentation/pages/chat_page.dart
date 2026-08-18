import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/service_locator.dart';
import '../../../ai_transform/domain/entities/transformation_result.dart';

/// A simple conversational chat with the AI (DeepSeek) that understands the
/// user's need through back-and-forth questions.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.module = TransformModule.fashion});

  final TransformModule module;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<({bool isUser, String text})> _messages =
      <({bool isUser, String text})>[];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add((isUser: true, text: text));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    try {
      final FunctionResponse response = await getIt<SupabaseClient>()
          .functions
          .invoke('chat-engine', body: <String, dynamic>{
            'module': widget.module.wire,
            'messages': _messages
                .map((m) => <String, String>{
                      'role': m.isUser ? 'user' : 'assistant',
                      'content': m.text,
                    })
                .toList(),
          });
      final Object? payload = response.data;
      final String reply = (payload is Map && payload['reply'] is String)
          ? payload['reply'] as String
          : 'Üzgünüm, bir hata oldu.';
      if (!mounted) return;
      setState(() => _messages.add((isUser: false, text: reply)));
    } catch (_) {
      if (!mounted) return;
      setState(() =>
          _messages.add((isUser: false, text: 'Bağlantı hatası, tekrar dene.')));
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbetle Anlat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final m = _messages[index];
                return Align(
                  alignment: m.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: m.isUser
                          ? const Color(0xFF10B981)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.isUser ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'İhtiyacını anlat…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
