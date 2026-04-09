import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
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
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _audioFilePath = '${dir.path}/medical_audio.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _audioFilePath!,
        );
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint("Recording error: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioFilePath = path;
      });
      _processRecording();
    } catch (e) {
      debugPrint("Stop recording error: $e");
    }
  }

  Future<void> _processRecording() async {
    if (_audioFilePath != null) {
      final file = File(_audioFilePath!);
      if (await file.exists()) {
        Uint8List bytes = await file.readAsBytes();
        if (mounted) {
          Provider.of<GeminiService>(context, listen: false).translateMedicalJargonAudio(bytes, 'audio/mp4');
        }
      }
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
          style: GoogleFonts.inter(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture audio of complex medical jargon and let AI give you 3 simple actionable points.',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                ),
                
                const SizedBox(height: 48),
                
                Center(
                  child: GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? AppTheme.error.withOpacity(0.8) : Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: _isRecording ? AppTheme.error : Colors.white.withOpacity(0.5),
                          width: 4,
                        ),
                        boxShadow: [
                          if (_isRecording) 
                             BoxShadow(color: AppTheme.error.withOpacity(0.6), blurRadius: 30, spreadRadius: 10)
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ).animate(
                  target: _isRecording ? 1 : 0, 
                  onPlay: (controller) => controller.repeat(reverse: true)
                ).scaleXY(end: 1.15, duration: 1000.ms, curve: Curves.easeInOut),
                
                const SizedBox(height: 32),
                
                Center(
                  child: Text(
                    _isRecording ? 'Recording... Tap to stop' : 'Tap microphone to start',
                    style: GoogleFonts.inter(
                      color: _isRecording ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
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
            Text('Processing Audio...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (geminiService.medicalSummary.isNotEmpty) {
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
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const Divider(color: Colors.white30, height: 32),
              Text(
                geminiService.medicalSummary,
                style: GoogleFonts.inter(
                  height: 1.6,
                  fontSize: 16,
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
