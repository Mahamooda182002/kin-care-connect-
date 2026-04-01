import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

class ScamShieldScreen extends StatefulWidget {
  const ScamShieldScreen({super.key});

  @override
  State<ScamShieldScreen> createState() => _ScamShieldScreenState();
}

class _ScamShieldScreenState extends State<ScamShieldScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fraud Protection',
          style: GoogleFonts.grandHotel(
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Scam Shield',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Paste any suspicious SMS, email, or message below to check for scams.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
              
              const SizedBox(height: 24),
              
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadows,
                    border: Border.all(color: AppTheme.secondary),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Paste suspicious text or transcript here...',
                      hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.5)),
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              ),
              
              const SizedBox(height: 24),
              
              Consumer<GeminiService>(
                builder: (context, gemini, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: gemini.isParsing ? null : () {
                          FocusScope.of(context).unfocus();
                          if (_textController.text.isNotEmpty) {
                            gemini.analyzeText(_textController.text);
                          }
                        },
                        icon: gemini.isParsing 
                            ? const SizedBox(
                                width: 24, 
                                height: 24, 
                                child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)
                              ) 
                            : const Icon(Icons.security, size: 28),
                        label: Text(
                          gemini.isParsing ? 'Analyzing...' : 'Scan for Fraud',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ).animate().fade(delay: 400.ms),

                      const SizedBox(height: 32),

                      if (gemini.analysisResult.isNotEmpty && !gemini.isParsing)
                        _buildResultShield(gemini),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultShield(GeminiService gemini) {
    final bool isScam = gemini.isScamDetected;
    final Color shieldColor = isScam ? AppTheme.error : AppTheme.success;
    final IconData shieldIcon = isScam ? Icons.gpp_bad : Icons.gpp_good;
    final String shieldText = isScam ? 'SCAM DETECTED' : 'SAFE';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: shieldColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: shieldColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: shieldColor.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 4,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(shieldIcon, size: 80, color: shieldColor)
              .animate()
              .scaleXY(begin: 0.5, end: 1.0, curve: Curves.elasticOut, duration: 800.ms),
          
          const SizedBox(height: 16),
          
          Text(
            shieldText,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: shieldColor,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 16),
          
          Text(
            gemini.analysisResult,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textMedium,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
