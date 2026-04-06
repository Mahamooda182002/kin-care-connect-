import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import '../widgets/glass_card.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Clinical Translator',
          style: GoogleFonts.grandHotel(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF3498DB),
              Color(0xFF2980B9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Record Doctor Visit',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'We will translate complex medical jargon into 3 simple, important tasks for you.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                
                const SizedBox(height: 48),
                
                // Recording Interface
                Center(
                  child: GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? AppTheme.error.withOpacity(0.8) : Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: _isListening ? AppTheme.error : Colors.white.withOpacity(0.5),
                          width: 4,
                        ),
                        boxShadow: [
                          if (_isListening) 
                             BoxShadow(color: AppTheme.error.withOpacity(0.6), blurRadius: 30, spreadRadius: 10)
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ).animate(
                  target: _isListening ? 1 : 0, 
                  onPlay: (controller) => controller.repeat(reverse: true)
                ).scaleXY(end: 1.15, duration: 1000.ms, curve: Curves.easeInOut),
                
                const SizedBox(height: 32),
                
                Center(
                  child: Text(
                    _isListening 
                        ? 'Listening... Tap to stop' 
                        : (_speechEnabled ? 'Tap microphone to start' : 'Speech recognition unavailable'),
                    style: TextStyle(
                      color: _isListening ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (_lastWords.isNotEmpty && !_isListening && !geminiService.isParsing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Transcript: "$_lastWords"',
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
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
      ),
    );
  }

  Widget _buildResultArea(GeminiService geminiService) {
    if (geminiService.isParsing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Simplifying medical tasks...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (geminiService.analysisResult.isNotEmpty) {
      return GlassCard(
        opacity: 0.15,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.medical_information_outlined, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Action Plan',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const Divider(color: Colors.white30, height: 32),
              Text(
                geminiService.analysisResult,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white,
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
