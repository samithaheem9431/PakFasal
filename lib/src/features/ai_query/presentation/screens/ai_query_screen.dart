import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

class AiQueryScreen extends StatefulWidget {
  const AiQueryScreen({super.key});

  @override
  State<AiQueryScreen> createState() => _AiQueryScreenState();
}

class _AiQueryScreenState extends State<AiQueryScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isNotEmpty) return;
    final l10n = AppLocalizations.of(context);
    _messages.addAll([
      _ChatMessage(text: l10n.t('aiSampleQuestion'), isFarmer: true),
      _ChatMessage(text: l10n.t('aiSampleAnswer'), isFarmer: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PakFasalScaffold(
      title: l10n.t('askAi'),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (_, index) =>
                  _MessageBubble(message: _messages[index]),
            ),
          ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.t('listening')),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.t('typeMessage'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    setState(() => _isListening = !_isListening);
                  },
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: _onSend,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isFarmer: true));
      _messages.add(
        _ChatMessage(
          text: AppLocalizations.of(context).t('aiPendingResponse'),
          isFarmer: false,
        ),
      );
      _controller.clear();
    });
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final align = message.isFarmer
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final color = message.isFarmer
        ? Colors.green.shade600
        : Colors.grey.shade200;
    final textColor = message.isFarmer ? Colors.white : Colors.black87;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message.text, style: TextStyle(color: textColor)),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isFarmer});

  final String text;
  final bool isFarmer;
}
