import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../services/gemini_service.dart';

class MedicalTranslationScreen extends StatefulWidget {
  const MedicalTranslationScreen({super.key});

  @override
  State<MedicalTranslationScreen> createState() => _MedicalTranslationScreenState();
}

class _MedicalTranslationScreenState extends State<MedicalTranslationScreen> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => debugPrint('onError: $val'),
      onStatus: (val) {
        debugPrint('onStatus: $val');
        if (val == 'done' || val == 'notListening') {
          if (_isListening && mounted) {
            setState(() => _isListening = false);
            _processRecording();
          }
        }
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) {
      _initSpeech();
    }
    
    _lastWords = '';
    // Clear previous results
    Provider.of<GeminiService>(context, listen: false).analysisResult = '';
    
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _processRecording();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void _processRecording() {
    if (_lastWords.isNotEmpty) {
      Provider.of<GeminiService>(context, listen: false).translateMedicalJargon(_lastWords);
    }
  }

  @override
  Widget build(BuildContext context) {
    final geminiService = context.watch<GeminiService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clinical Translator',
          style: GoogleFonts.grandHotel(
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Record Doctor Visit',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'We will translate complex medical jargon into 3 simple, important tasks for you.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
              
              const SizedBox(height: 32),
              
              // Recording Interface
              Center(
                child: GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? AppTheme.error.withOpacity(0.1) : AppTheme.surface,
                      border: Border.all(
                        color: _isListening ? AppTheme.error : AppTheme.secondary,
                        width: 4,
                      ),
                      boxShadow: AppTheme.softShadows,
                    ),
                    child: Center(
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 64,
                        color: _isListening ? AppTheme.error : AppTheme.textLight,
                      ),
                    ),
                  ),
                ),
              ).animate(target: _isListening ? 1 : 0).scale(end: const Offset(1.1, 1.1), duration: 1.seconds).loop(reverse: true),
              
              const SizedBox(height: 24),
              
              Center(
                child: Text(
                  _isListening 
                      ? 'Listening... Tap to stop' 
                      : (_speechEnabled ? 'Tap to start recording' : 'Speech recognition unavailable'),
                  style: TextStyle(
                    color: _isListening ? AppTheme.error : AppTheme.accentBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_lastWords.isNotEmpty && !_isListening && !geminiService.isParsing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Transcript: "$_lastWords"',
                    style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              Expanded(
                child: _buildResultArea(geminiService),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultArea(GeminiService geminiService) {
    if (geminiService.isParsing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.accentBlue),
            SizedBox(height: 16),
            Text('Analyzing conversation...', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    if (geminiService.analysisResult.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.secondary),
          boxShadow: AppTheme.softShadows,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.medical_information_outlined, color: AppTheme.accentBlue, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Medical Card',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(color: AppTheme.secondary, height: 32),
              Text(
                geminiService.analysisResult,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: AppTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
      ).animate().fade(duration: 600.ms).slideY(begin: 0.1);
    }

    return const SizedBox.shrink();
  }
}
