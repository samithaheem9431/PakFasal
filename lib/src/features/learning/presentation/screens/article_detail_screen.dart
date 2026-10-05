import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/learning_article_models.dart';
import '../widgets/learning_widgets.dart';

/// Full reader view for one learning article. [article] carries both
/// languages; display text is resolved live from the current locale so
/// switching language updates this screen instantly, even while it's open.
///
/// Every article gets read-aloud support driven entirely by
/// `article.sections`, so any newly added article (with its own stages)
/// gets this behaviour for free — no code changes needed per article:
///
/// - The top "Listen to Article" control plays every stage in order,
///   automatically advancing to the next one when the current finishes.
/// - Each paragraph (stage) is also individually tappable: tapping a
///   stage plays just that one; tapping the stage that's already playing
///   stops it; tapping a different stage while one is playing
///   immediately switches playback to the one just tapped.
class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  final LearningArticleEntry article;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  int _currentStageIndex = -1;
  bool _isSequentialMode = false;

  // `flutter_tts` fires its cancel/completion callbacks asynchronously, so a
  // `stop()` we issue to switch to a new stage can have its `cancel` event
  // arrive *after* we've already started the next stage — which would
  // otherwise wipe out the new state. `_activeRequestId` identifies the
  // "current" playback attempt; `_suppressCancelCount` swallows exactly the
  // cancel events we caused ourselves via an explicit `stop()` call, so only
  // genuine/unexpected cancellations reset the UI.
  int _activeRequestId = 0;
  int _suppressCancelCount = 0;

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(_onStageSpeechComplete);
    _flutterTts.setCancelHandler(_onNativeCancel);
    _flutterTts.setErrorHandler((_) => _resetPlaybackState());
  }

  void _onNativeCancel() {
    if (_suppressCancelCount > 0) {
      // This cancel was caused by our own stop()-then-switch/stop call;
      // the calling method already updates state, so ignore it here.
      _suppressCancelCount--;
      return;
    }
    _resetPlaybackState();
  }

  void _onStageSpeechComplete() {
    if (!mounted || !_isPlaying) return;
    final stages = widget.article.sections;
    final nextIndex = _currentStageIndex + 1;
    if (_isSequentialMode && nextIndex < stages.length) {
      final requestId = _activeRequestId;
      setState(() => _currentStageIndex = nextIndex);
      _speak(nextIndex, requestId);
    } else {
      _resetPlaybackState();
    }
  }

  void _resetPlaybackState() {
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _currentStageIndex = -1;
      _isSequentialMode = false;
    });
  }

  /// Stops any current speech (suppressing the resulting stray cancel
  /// event) and resets the UI to "not playing".
  Future<void> _stopPlayback() async {
    final requestId = ++_activeRequestId;
    _suppressCancelCount++;
    await _flutterTts.stop();
    if (!mounted || requestId != _activeRequestId) return;
    setState(() {
      _isPlaying = false;
      _currentStageIndex = -1;
      _isSequentialMode = false;
    });
  }

  /// Starts playback at [index]. If something is already playing, its
  /// speech is stopped first (with the stray cancel event suppressed) so
  /// switching stages never gets clobbered by a late callback.
  Future<void> _startStage(int index, {required bool sequential}) async {
    final requestId = ++_activeRequestId;
    if (_isPlaying) {
      _suppressCancelCount++;
      await _flutterTts.stop();
      if (!mounted || requestId != _activeRequestId) return;
    }

    setState(() {
      _isPlaying = true;
      _isSequentialMode = sequential;
      _currentStageIndex = index;
    });
    await _speak(index, requestId);
  }

  /// Top "Listen to Article" control: reads every stage in order.
  Future<void> _togglePlayback() async {
    if (widget.article.sections.isEmpty) return;
    if (_isPlaying) {
      await _stopPlayback();
      return;
    }
    await _startStage(0, sequential: true);
  }

  /// Tapping a specific paragraph: play just that stage. Tapping the
  /// currently-playing stage stops it; tapping a different one while
  /// something is playing switches playback to the newly tapped stage.
  Future<void> _toggleStage(int index) async {
    if (_isPlaying && _currentStageIndex == index) {
      await _stopPlayback();
      return;
    }
    await _startStage(index, sequential: false);
  }

  Future<void> _speak(int index, int requestId) async {
    final stages = widget.article.sections;
    if (index < 0 || index >= stages.length) return;

    final languageCode = Localizations.localeOf(context).languageCode;
    final stage = stages[index];
    final text = '${stage.heading(languageCode)}. ${stage.body(languageCode)}';

    final didSpeak = await _speakWithRetry(text, languageCode, requestId);
    if (!mounted || requestId != _activeRequestId) return;
    if (!didSpeak) {
      setState(() {
        _isPlaying = false;
        _currentStageIndex = -1;
        _isSequentialMode = false;
      });
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('voiceServiceUnavailable'))),
      );
    }
  }

  Future<bool> _speakWithRetry(
    String text,
    String languageCode,
    int requestId,
  ) async {
    final ttsLocale = languageCode == 'ur' ? 'ur-PK' : 'en-US';

    for (var attempt = 0; attempt < 4; attempt++) {
      if (requestId != _activeRequestId) return false;

      final languageResult = await _flutterTts.setLanguage(ttsLocale);
      if (requestId != _activeRequestId) return false;
      if (_isLanguageUnavailable(languageResult)) {
        await Future.delayed(const Duration(milliseconds: 250));
        continue;
      }

      final speakResult = await _flutterTts.speak(text);
      if (speakResult == 1 || speakResult == '1') {
        return true;
      }

      await Future.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  bool _isLanguageUnavailable(dynamic languageResult) {
    if (languageResult is int) {
      return languageResult < 0;
    }
    if (languageResult is String) {
      final parsed = int.tryParse(languageResult);
      if (parsed != null) return parsed < 0;
    }
    return languageResult == null;
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final languageCode =
        context.watch<LocalizationController>().locale.languageCode;
    final stages = article.sections;

    return PakFasalScaffold(
      title: article.category(languageCode),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          LearningDetailHeader(
            icon: article.icon,
            title: article.title(languageCode),
            subtitle: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  l10n.t(
                    'articleReadTimeMinutes',
                    params: {'minutes': article.readTimeMinutes},
                  ),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              article.summary(languageCode),
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (stages.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ListenControl(
              isPlaying: _isPlaying,
              currentStageIndex: _currentStageIndex,
              totalStages: stages.length,
              currentStageHeading: _isPlaying && _currentStageIndex >= 0
                  ? stages[_currentStageIndex].heading(languageCode)
                  : null,
              l10n: l10n,
              onTap: _togglePlayback,
            ),
          ],
          const SizedBox(height: 22),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final isActiveStage = _isPlaying && _currentStageIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleStage(index),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActiveStage
                          ? scheme.primaryContainer.withValues(alpha: 0.35)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isActiveStage
                          ? Border.all(
                              color: scheme.primary.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              margin: const EdgeInsets.only(top: 3, right: 10),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                stage.heading(languageCode),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isActiveStage
                                  ? Icons.stop_circle_rounded
                                  : Icons.volume_up_outlined,
                              size: 20,
                              color: isActiveStage
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stage.body(languageCode),
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// The Play/Stop control shown for an article. While playing, it shows
/// which stage (section) is currently being read out, e.g.
/// "Stage 2 of 3 · Fertilizer timing".
class _ListenControl extends StatelessWidget {
  const _ListenControl({
    required this.isPlaying,
    required this.currentStageIndex,
    required this.totalStages,
    required this.currentStageHeading,
    required this.l10n,
    required this.onTap,
  });

  final bool isPlaying;
  final int currentStageIndex;
  final int totalStages;
  final String? currentStageHeading;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isPlaying
                ? scheme.primary.withValues(alpha: 0.1)
                : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.6),
              width: isPlaying ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPlaying ? scheme.primary : scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  color: isPlaying ? scheme.onPrimary : scheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPlaying
                          ? l10n.t('articleStopListening')
                          : l10n.t('articleListenButton'),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (isPlaying && currentStageHeading != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${l10n.t('articleStageProgress', params: {
                              'current': currentStageIndex + 1,
                              'total': totalStages,
                            })} · $currentStageHeading',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
