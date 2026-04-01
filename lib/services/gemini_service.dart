import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService extends ChangeNotifier {
  // Provided by user
  final String _apiKey = 'AIzaSyCGZnfjWql6UUUkQF5y6nRtbmf2w7zzXDI';
  bool isParsing = false;
  String analysisResult = '';
  bool isScamDetected = false;

  void _setLoading(bool value) {
    isParsing = value;
    notifyListeners();
  }

  Future<void> analyzeText(String userText) async {
    if (userText.trim().isEmpty) {
      analysisResult = 'Please enter some text to analyze.';
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
      );

      final prompt = '''
      You are an expert scam and fraud detector. Analyze the following text snippet/transcript and determine if it looks like a scam, paying special attention to "High-Pressure Scams" or "AI-Voice patterns".
      Reply with EXACTLY ONE WORD on the first line: either "SAFE" or "SCAM".
      On the second line, provide a short, easy-to-read explanation (max 2 sentences) of why it's safe or dangerous.
      Text to analyze: "$userText"
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final responseText = response.text?.trim() ?? '';
      
      if (responseText.toUpperCase().startsWith('SCAM')) {
        isScamDetected = true;
        analysisResult = responseText.substring(4).trim();
      } else if (responseText.toUpperCase().startsWith('SAFE')) {
        isScamDetected = false;
        analysisResult = responseText.substring(4).trim();
      } else {
        isScamDetected = false;
        analysisResult = responseText;
      }
    } catch (e) {
      analysisResult = 'Error connecting to Gemini Service: $e';
      isScamDetected = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> translateMedicalJargon(String transcript) async {
    if (transcript.trim().isEmpty) {
      analysisResult = 'No audio recorded. Please try again.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    analysisResult = '';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro-latest',
        apiKey: _apiKey,
      );

      final prompt = '''
      Analyze this doctor-patient conversation and summarize the 3 most important health tasks in simple, non-medical language for a family member.
      Format the summary as a readable list.
      Conversation transcript: "$transcript"
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      analysisResult = response.text ?? 'Could not generate summary.';
    } catch (e) {
      analysisResult = 'Error connecting to Gemini Service: $e';
    } finally {
      _setLoading(false);
    }
  }
}
