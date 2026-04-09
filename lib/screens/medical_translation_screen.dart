import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MedicalTranslationScreen extends StatefulWidget {
  const MedicalTranslationScreen({super.key});
  @override
  State<MedicalTranslationScreen> createState() =>
      _MedicalTranslatorScreenState();
}

class _MedicalTranslatorScreenState extends State<MedicalTranslationScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _summary = '';
  String _recordingPath = '';
  bool _isLoading = false;

  final String _geminiKey = 'AIzaSyCGZnfjWql6UUUkQF5y6nRtbmf2w7zzXDI';

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/medical_audio.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordingPath,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopAndAnalyze() async {
    await _recorder.stop();
    setState(() {
      _isRecording = false;
      _isLoading = true;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiKey,
      );
      final audioBytes = await File(_recordingPath).readAsBytes();
      final response = await model.generateContent([
        Content.multi([
          DataPart('audio/m4a', audioBytes),
          TextPart(
            'Summarize this medical audio for a family caregiver. '
            'Give 3 simple action items.',
          ),
        ])
      ]);
      setState(() {
        _summary = response.text ?? 'No summary generated.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _summary = 'Error analyzing audio: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text('Medical Translator',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isRecording ? _stopAndAnalyze : _startRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? Colors.red.withOpacity(0.8)
                      : Colors.purple.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: _isRecording
                          ? Colors.red.withOpacity(0.5)
                          : Colors.purple.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isRecording ? 'Recording... Tap to Stop' : 'Tap to Record',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.purple),
            if (_summary.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  _summary,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
