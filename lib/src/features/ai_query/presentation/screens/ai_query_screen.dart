import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

class AiQueryScreen extends StatefulWidget {
  const AiQueryScreen({super.key});

  @override
  State<AiQueryScreen> createState() => _AiQueryScreenState();
}

class _AiQueryScreenState extends State<AiQueryScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _speechReady = false;
  bool _isListening = false;
  int? _speakingMessageIndex;

  // ── Green palette ────────────────────────────────────────────────────────
  static const _forestGreen  = Color(0xFF2E7D32);
  static const _emerald      = Color(0xFF43A047);
  static const _lightGreen   = Color(0xFFE8F5E9);
  static const _midGreen     = Color(0xFFC8E6C9);
  static const _surfaceGreen = Color(0xFFF1FBF2);
  static const _mintText     = Color(0xFF66BB6A);
  // ────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- UNCHANGED LOGIC ---
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context);
    _textController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage(text: l10n.t('aiPendingResponse'), isUser: false),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showHistoryPanel(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final history = [
          'Best fertilizer for wheat?',
          'Weather forecast for tomorrow',
          'How to control cotton bollworm?',
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.t('aiHistory'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _forestGreen,
                      ),
                    ),
                    // New chat pill button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _messages.clear());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _lightGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                size: 14, color: _forestGreen),
                            const SizedBox(width: 4),
                            Text(
                              l10n.t('aiNewChat'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: _midGreen),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: _lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: _forestGreen,
                        ),
                      ),
                      title: Text(
                        history[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _forestGreen,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.t('aiHistoryLoaded')),
                            backgroundColor: _forestGreen,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startListening(AppLocalizations l10n) async {
    if (_isListening) return;
    if (!_speechReady) {
      _speechReady = await _speechToText.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening') setState(() => _isListening = false);
        },
        onError: (SpeechRecognitionError error) {
          if (!mounted) return;
          setState(() => _isListening = false);
          if (!error.permanent) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.t('voiceInputStartFailed'))),
          );
        },
      );
    }
    if (!_speechReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('voiceInputUnavailable'))),
      );
      return;
    }
    setState(() => _isListening = true);
    final started = await _speechToText.listen(
      onResult: _onSpeechResult,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
    if (!started && mounted) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('voiceInputStartFailed'))),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    _textController.text = result.recognizedWords;
    _textController.selection =
        TextSelection.collapsed(offset: _textController.text.length);
  }

  Future<void> _toggleListening(AppLocalizations l10n) async {
    if (_isListening) {
      await _stopListening();
      return;
    }
    await _startListening(l10n);
  }

  Future<void> _configureTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _speakingMessageIndex = null);
    });
    _flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _speakingMessageIndex = null);
    });
    _flutterTts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _speakingMessageIndex = null);
    });
  }

  Future<void> _toggleSpeakMessage(int index, String text) async {
    final l10n = AppLocalizations.of(context);
    if (_speakingMessageIndex == index) {
      await _flutterTts.stop();
      if (!mounted) return;
      setState(() => _speakingMessageIndex = null);
      return;
    }
    final languageCode = Localizations.localeOf(context).languageCode;
    final ttsLocale = languageCode == 'ur' ? 'ur-PK' : 'en-US';
    final languageResult = await _flutterTts.setLanguage(ttsLocale);
    if (languageResult == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('voiceServiceUnavailable'))),
      );
      return;
    }
    await _flutterTts.stop();
    final speakResult = await _flutterTts.speak(text);
    if (speakResult == 1 && mounted) {
      setState(() => _speakingMessageIndex = index);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('voiceServiceUnavailable'))),
      );
    }
  }
  // -----------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PakFasalScaffold(
      title: l10n.t('askAi'),
      showBack: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: _forestGreen),
          tooltip: l10n.t('aiHistory'),
          onPressed: () => _showHistoryPanel(context, l10n),
        ),
      ],
      child: Container(
        color: _surfaceGreen,
        child: Column(
          children: [
            // ── Chat list / empty state ─────────────────────────────────
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _ChatBubble(
                    message: _messages[index],
                    l10n: l10n,
                    isSpeaking: _speakingMessageIndex == index,
                    onSpeak: _messages[index].isUser
                        ? null
                        : () => _toggleSpeakMessage(
                      index,
                      _messages[index].text,
                    ),
                  );
                },
              ),
            ),

            // ── Typing indicator ────────────────────────────────────────
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: _lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        size: 14,
                        color: _forestGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _TypingDots(),
                  ],
                ),
              ),

            // ── Input area ──────────────────────────────────────────────
            _buildInputArea(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bot icon in green circle
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: _lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 52,
                color: _forestGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.t('aiNoMessagesTitle'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _forestGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.t('aiNoMessagesSubtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _mintText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Suggestion chip — green themed
            GestureDetector(
              onTap: () => _handleSubmitted(l10n.t('aiSampleQuestion')),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _midGreen),
                  boxShadow: [
                    BoxShadow(
                      color: _forestGreen.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 16, color: _forestGreen),
                    const SizedBox(width: 6),
                    Text(
                      l10n.t('aiSampleQuestion'),
                      style: const TextStyle(
                        color: _forestGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _midGreen)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Text field ─────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _surfaceGreen,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _midGreen),
                ),
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleSubmitted,
                  style: const TextStyle(color: _forestGreen, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: l10n.t('typeMessage'),
                    hintStyle: TextStyle(
                      color: _mintText.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ── Mic button — red tint when listening ───────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isListening
                    ? const Color(0xFFFFEBEE)
                    : _lightGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isListening ? Colors.redAccent : _midGreen,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isListening
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded,
                  color: _isListening ? Colors.redAccent : _forestGreen,
                ),
                tooltip: _isListening
                    ? l10n.t('voiceListeningNow')
                    : l10n.t('voiceTapToSpeak'),
                onPressed: () => _toggleListening(l10n),
              ),
            ),
            const SizedBox(width: 8),

            // ── Send button ────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_emerald, _forestGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _forestGreen.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated typing dots ───────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          children: List.generate(3, (i) {
            final phase = (_controller.value - i * 0.2).clamp(0.0, 1.0);
            final opacity = (phase < 0.5
                ? phase * 2
                : (1 - phase) * 2);
            return Container(
              margin: const EdgeInsets.only(right: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF66BB6A).withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Chat message model — unchanged ─────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

// ── Chat bubble ────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.l10n,
    required this.isSpeaking,
    required this.onSpeak,
  });

  final _ChatMessage message;
  final AppLocalizations l10n;
  final bool isSpeaking;
  final VoidCallback? onSpeak;

  static const _forestGreen = Color(0xFF2E7D32);
  static const _emerald     = Color(0xFF43A047);
  static const _lightGreen  = Color(0xFFE8F5E9);
  static const _mintText    = Color(0xFF66BB6A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // ── Bot avatar ─────────────────────────────────────────────
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 10, top: 2),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: _lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: _forestGreen,
              ),
            ),

          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender label
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.isUser
                        ? l10n.t('aiYouLabel')
                        : l10n.t('aiAssistantLabel'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: message.isUser ? _forestGreen : _mintText,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    // User: green gradient · Bot: white with green border
                    gradient: message.isUser
                        ? const LinearGradient(
                      colors: [_emerald, _forestGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: message.isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message.isUser
                          ? const Radius.circular(18)
                          : Radius.zero,
                      bottomRight: message.isUser
                          ? Radius.zero
                          : const Radius.circular(18),
                    ),
                    border: message.isUser
                        ? null
                        : Border.all(color: const Color(0xFFE8F5E9)),
                    boxShadow: [
                      BoxShadow(
                        color: _forestGreen.withValues(
                            alpha: message.isUser ? 0.18 : 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : _forestGreen,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),

                // Speak button for bot messages
                if (!message.isUser && onSpeak != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: GestureDetector(
                      onTap: onSpeak,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSpeaking
                                ? Icons.stop_circle_outlined
                                : Icons.volume_up_rounded,
                            size: 15,
                            color: _mintText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.t('voice'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: _mintText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}