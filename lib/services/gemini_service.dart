import 'package:flutter/foundation.dart';

/// Client-side safety checks only. AI analysis must be provided by a
/// trusted backend; API secrets must never be embedded in the mobile app.
class GeminiService extends ChangeNotifier {
  bool isParsing = false;

  String analysisResult = '';
  int riskScore = 0;
  bool isScamDetected = false;
  String medicalSummary = '';

  Future<void> analyzeText(String userText) async {
    final text = userText.trim();
    if (text.isEmpty) {
      analysisResult = 'Please enter a message to check.';
      riskScore = 0;
      isScamDetected = false;
      notifyListeners();
      return;
    }

    isParsing = true;
    analysisResult = '';
    notifyListeners();

    try {
      // Conservative offline screening for common warning signs. This is
      // deliberately not represented as an AI verdict or a guarantee.
      final lower = text.toLowerCase();
      final patterns = <String>[
        'otp',
        'one time password',
        'share your password',
        'verify your bank',
        'account will be blocked',
        'urgent payment',
        'send money immediately',
        'claim your prize',
        'click this link',
        'remote access',
        'gift card',
        'crypto investment',
        'upi pin',
      ];
      final matches = patterns.where(lower.contains).toList();
      riskScore = (matches.length * 22).clamp(0, 88);
      isScamDetected = riskScore >= 44;

      if (matches.isEmpty) {
        analysisResult =
            'No common warning phrases were detected. This does not prove the message is safe. Verify the sender through an official channel and never share an OTP, password, or UPI PIN.';
      } else {
        analysisResult =
            'Warning signs detected: ${matches.take(4).join(', ')}. Do not click links, share credentials, or send money until you independently verify the request. This is a basic offline check, not a definitive scam verdict.';
      }
    } finally {
      isParsing = false;
      notifyListeners();
    }
  }

  Future<void> translateMedicalJargonAudio(
    Uint8List audioBytes,
    String mimeType,
  ) async {
    medicalSummary =
        'AI medical summarization is temporarily unavailable while a secure backend is configured. Please use the clinician’s written instructions and confirm any medication or treatment questions directly with a qualified healthcare professional.';
    notifyListeners();
  }
}
