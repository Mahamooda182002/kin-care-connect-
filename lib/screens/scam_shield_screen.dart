import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

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
    // Dynamic background based on scam detection stage
    return Consumer<GeminiService>(
      builder: (context, gemini, child) {
        final isScam = gemini.isScamDetected;
        final hasResult = gemini.analysisResult.isNotEmpty && !gemini.isParsing;
        
        List<Color> bgColors = [
          const Color(0xFF1F1C2C),
          const Color(0xFF928DAB),
        ];
        
        if (hasResult) {
          bgColors = isScam 
              ? [const Color(0xFF801336), const Color(0xFFC72C41)] // Red Danger
              : [const Color(0xFF134E5E), const Color(0xFF71B280)]; // Green Safe
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Fraud Protection',
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
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
            elevation: 0,
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Scam Shield',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paste any suspicious SMS, email, or message below to check for scams.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Expanded(
                      flex: 2,
                      child: GlassCard(
                        opacity: 0.15,
                        padding: EdgeInsets.zero,
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Paste suspicious text or transcript here...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.all(24),
                          ),
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.white.withOpacity(0.5)),
                            ),
                            elevation: 0,
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
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                ) 
                              : const Icon(Icons.security, size: 28, color: Colors.white),
                          label: Text(
                            gemini.isParsing ? 'Analyzing...' : 'Scan for Fraud',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ).animate().fade(delay: 400.ms),

                        const SizedBox(height: 32),

                        if (hasResult)
                          _buildResultShield(gemini),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultShield(GeminiService gemini) {
    final bool isScam = gemini.isScamDetected;
    final Color shieldColor = isScam ? const Color(0xFFFF5252) : const Color(0xFF69F0AE);
    final IconData shieldIcon = isScam ? Icons.gpp_bad : Icons.gpp_good;
    final String shieldText = isScam ? 'SCAM DETECTED' : 'SAFE';

    return GlassCard(
      opacity: 0.2,
      borderColor: shieldColor,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: shieldColor.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)
              ]
            ),
            child: Icon(shieldIcon, size: 90, color: shieldColor)
                .animate()
                .scaleXY(begin: 0.5, end: 1.0, curve: Curves.elasticOut, duration: 1000.ms),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            shieldText,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: shieldColor,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 16),
          
          Text(
            gemini.analysisResult,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              height: 1.5,
              fontSize: 18,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

