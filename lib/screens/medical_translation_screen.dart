import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class MedicalTranslationScreen extends StatefulWidget {
  const MedicalTranslationScreen({super.key});

  @override
  State<MedicalTranslationScreen> createState() =>
      _MedicalTranslationScreenState();
}

class _MedicalTranslationScreenState extends State<MedicalTranslationScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isLoading = false;
  String _recordingPath = '';
  String _message = '';

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        setState(() => _message = 'Microphone permission is required to record.');
        return;
      }
      final dir = await getTemporaryDirectory();
      _recordingPath =
          '${dir.path}/medical_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordingPath,
      );
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _message = '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Could not start recording. Check microphone permission.');
    }
  }

  Future<void> _stopRecording() async {
    setState(() => _isLoading = true);
    try {
      await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _message =
            'Recording saved temporarily on this device. Secure AI summarization is not enabled yet. Do not rely on an AI summary for medical decisions; confirm instructions with the clinician.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Could not finish recording. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text('Medical Translator', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.health_and_safety_outlined, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'Record a conversation only with the other person’s consent.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : (_isRecording ? _stopRecording : _startRecording),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red.withOpacity(0.8) : Colors.purple.withOpacity(0.8),
                  ),
                  child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 50, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isLoading ? 'Saving recording…' : (_isRecording ? 'Recording… Tap to stop' : 'Tap to record'),
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(_message, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'MVP note: automatic medical transcription and AI summaries are not enabled yet. Recordings are temporary and are not uploaded by this screen.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
