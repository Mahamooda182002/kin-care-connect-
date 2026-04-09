import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService extends ChangeNotifier {
  final String _apiKey = 'AIzaSyCGZnfjWql6UUUkQF5y6nRtbmf2w7zzXDI';
  bool isParsing = false;
  
  // Scam Shield State
  String analysisResult = '';
  int riskScore = 0;
  bool isScamDetected = false;

  // Medical Translation State
  String medicalSummary = '';

  void _setLoading(bool value) {
    isParsing = value;
    notifyListeners();
  }

  Future<void> analyzeText(String userText) async {
    if (userText.trim().isEmpty) {
      analysisResult = 'Please enter some text to analyze.';
      riskScore = 0;
      isScamDetected = false;
      notifyListeners();
      return;
    }

    _setLoading(true);
    analysisResult = '';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro-latest',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
      You are an expert scam and fraud detector. Analyze this text for scams (high-pressure, voice cloning, phishing).
      Return ONLY a JSON object with this exact structure:
      {
        "risk_score": <number between 0 and 100>,
        "reason": "<short explanation why it's safe or a scam (max 2 sentences)>"
      }
      
      Text to analyze: "$userText"
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text?.trim() ?? '{}';
      
      final Map<String, dynamic> jsonResponse = jsonDecode(responseText);
      
      riskScore = jsonResponse['risk_score'] ?? 0;
      analysisResult = jsonResponse['reason'] ?? 'Unknown formatting.';
      isScamDetected = riskScore > 50;

    } catch (e) {
      analysisResult = 'Error connecting to Gemini: $e';
      riskScore = 0;
      isScamDetected = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> translateMedicalJargonAudio(Uint8List audioBytes, String mimeType) async {
    if (audioBytes.isEmpty) return;

    _setLoading(true);
    medicalSummary = '';
    notifyListeners();

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro-latest',
        apiKey: _apiKey,
      );

      final prompt = 'Summarize this medical audio for a family caregiver. Provide 3 clear actionable points.';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, audioBytes),
        ])
      ];

      final response = await model.generateContent(content);
      medicalSummary = response.text ?? 'Could not generate summary.';
    } catch (e) {
      medicalSummary = 'Error connecting to Gemini Audio API: $e';
    } finally {
      _setLoading(false);
    }
  }
}
