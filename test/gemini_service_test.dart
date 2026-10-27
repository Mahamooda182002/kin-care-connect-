import 'package:flutter_test/flutter_test.dart';
import 'package:kin_care_connect/services/gemini_service.dart';

void main() {
  group('GeminiService offline scam screening', () {
    late GeminiService service;

    setUp(() {
      service = GeminiService();
    });

    tearDown(() {
      service.dispose();
    });

    test('asks for text when input is empty', () async {
      await service.analyzeText('   ');

      expect(service.analysisResult, contains('Please enter'));
      expect(service.riskScore, 0);
      expect(service.isScamDetected, isFalse);
      expect(service.isParsing, isFalse);
    });

    test('flags common scam warning phrases conservatively', () async {
      await service.analyzeText(
        'Urgent payment required. Share your password and OTP now.',
      );

      expect(service.riskScore, greaterThan(0));
      expect(service.isScamDetected, isTrue);
      expect(service.analysisResult, contains('Warning signs detected'));
      expect(service.isParsing, isFalse);
    });

    test('does not claim that a message is definitely safe', () async {
      await service.analyzeText('Hello, are we meeting tomorrow?');

      expect(service.isScamDetected, isFalse);
      expect(service.analysisResult, contains('does not prove the message is safe'));
    });
  });
}
