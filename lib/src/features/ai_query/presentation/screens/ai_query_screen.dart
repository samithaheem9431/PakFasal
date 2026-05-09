import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

/// Theme-aware palette derived per build so the AI surface flips cleanly
/// between light and dark modes. We still lean on the green branding via
/// [ColorScheme.primary], but every supporting surface comes from the
/// active scheme.
class _AiPalette {
  _AiPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceHigh,
    required this.outline,
    required this.outlineSoft,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceFaded,
    required this.userBubbleGradient,
    required this.botBubbleColor,
    required this.botBubbleBorder,
    required this.botBubbleText,
  });

  factory _AiPalette.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AiPalette(
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryContainer,
      onPrimaryContainer: scheme.onPrimaryContainer,
      surface: scheme.surface,
      surfaceMuted: scheme.surfaceContainerHighest,
      surfaceHigh: scheme.surfaceContainerHigh,
      outline: scheme.outline,
      outlineSoft: scheme.outlineVariant,
      onSurface: scheme.onSurface,
      onSurfaceMuted: scheme.onSurfaceVariant,
      onSurfaceFaded: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      userBubbleGradient: isDark
          ? [scheme.primary, scheme.primaryContainer]
          : [scheme.primary.withValues(alpha: 0.85), scheme.primary],
      botBubbleColor: scheme.surfaceContainerHigh,
      botBubbleBorder: scheme.outlineVariant,
      botBubbleText: scheme.onSurface,
    );
  }

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceHigh;
  final Color outline;
  final Color outlineSoft;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color onSurfaceFaded;
  final List<Color> userBubbleGradient;
  final Color botBubbleColor;
  final Color botBubbleBorder;
  final Color botBubbleText;
}

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
    final palette = _AiPalette.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: palette.surface,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: palette.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _messages.clear());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: palette.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add,
                                size: 14, color: palette.onPrimaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              l10n.t('aiNewChat'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: palette.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: palette.outlineSoft, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: palette.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: palette.primary,
                        ),
                      ),
                      title: Text(
                        history[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: palette.onSurface,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.t('aiHistoryLoaded')),
                            backgroundColor: palette.primary,
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
    final messenger = ScaffoldMessenger.of(context);
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
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.t('voiceInputStartFailed'))),
          );
        },
      );
    }
    if (!_speechReady) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.t('voiceInputUnavailable'))),
      );
      return;
    }
    setState(() => _isListening = true);
    final started = await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
    if (!started && mounted) {
      setState(() => _isListening = false);
      messenger.showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = _AiPalette.of(context);

    return PakFasalScaffold(
      title: l10n.t('askAi'),
      showBack: true,
      actions: [
        IconButton(
          icon: Icon(Icons.history, color: palette.primary),
          tooltip: l10n.t('aiHistory'),
          onPressed: () => _showHistoryPanel(context, l10n),
        ),
      ],
      child: Container(
        color: palette.surface,
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(l10n, palette)
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _ChatBubble(
                    message: _messages[index],
                    l10n: l10n,
                    palette: palette,
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

            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: palette.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        size: 14,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TypingDots(color: palette.primary),
                  ],
                ),
              ),

            _buildInputArea(l10n, palette),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, _AiPalette palette) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: palette.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 52,
                color: palette.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.t('aiNoMessagesTitle'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: palette.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.t('aiNoMessagesSubtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: palette.onSurfaceMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => _handleSubmitted(l10n.t('aiSampleQuestion')),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.outlineSoft),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 16, color: palette.primary),
                    const SizedBox(width: 6),
                    Text(
                      l10n.t('aiSampleQuestion'),
                      style: TextStyle(
                        color: palette.primary,
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

  Widget _buildInputArea(AppLocalizations l10n, _AiPalette palette) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.outlineSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.outlineSoft),
                ),
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleSubmitted,
                  style:
                      TextStyle(color: palette.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: l10n.t('typeMessage'),
                    hintStyle: TextStyle(
                      color: palette.onSurfaceFaded,
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

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isListening
                    ? AppColors.error.withValues(alpha: 0.10)
                    : palette.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _isListening ? AppColors.error : palette.outlineSoft,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isListening
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded,
                  color: _isListening ? AppColors.error : palette.primary,
                ),
                tooltip: _isListening
                    ? l10n.t('voiceListeningNow')
                    : l10n.t('voiceTapToSpeak'),
                onPressed: () => _toggleListening(l10n),
              ),
            ),
            const SizedBox(width: 8),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: palette.userBubbleGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded, color: palette.onPrimary),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});

  final Color color;

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
                color: widget.color.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.l10n,
    required this.palette,
    required this.isSpeaking,
    required this.onSpeak,
  });

  final _ChatMessage message;
  final AppLocalizations l10n;
  final _AiPalette palette;
  final bool isSpeaking;
  final VoidCallback? onSpeak;

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
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 10, top: 2),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: palette.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: palette.primary,
              ),
            ),

          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.isUser
                        ? l10n.t('aiYouLabel')
                        : l10n.t('aiAssistantLabel'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: message.isUser
                          ? palette.primary
                          : palette.onSurfaceMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? LinearGradient(
                      colors: palette.userBubbleGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: message.isUser ? null : palette.botBubbleColor,
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
                        : Border.all(color: palette.botBubbleBorder),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withValues(
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
                          ? palette.onPrimary
                          : palette.botBubbleText,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),

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
                            color: palette.onSurfaceMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.t('voice'),
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.onSurfaceMuted,
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
