import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../services/gemini_service.dart';
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
    return Consumer<GeminiService>(
      builder: (context, gemini, child) {
        final hasResult = gemini.analysisResult.isNotEmpty && !gemini.isParsing;
        final riskScore = gemini.riskScore.toDouble();
        
        List<Color> bgColors = [
          const Color(0xFF1F1C2C),
          const Color(0xFF928DAB),
        ];

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Fraud Protection',
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
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Scam Shield',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Paste any suspicious message below to analyze its fraud risk score.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassCard(
                          opacity: 0.15,
                          padding: EdgeInsets.zero,
                          child: TextField(
                            controller: _textController,
                            maxLines: 5,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Paste suspicious text or transcript here...',
                              hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(24),
                            ),
                          ),
                        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        
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
                            gemini.isParsing ? 'Analyzing Risk...' : 'Scan for Fraud Risk',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ).animate().fade(delay: 400.ms),

                        const SizedBox(height: 32),

                        if (hasResult)
                          _buildGaugeShield(gemini, riskScore),
                      ]),
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

  Widget _buildGaugeShield(GeminiService gemini, double riskScore) {
    return GlassCard(
      opacity: 0.2,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
                    GaugeRange(startValue: 30, endValue: 70, color: Colors.orange),
                    GaugeRange(startValue: 70, endValue: 100, color: Colors.red),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(value: riskScore, needleColor: Colors.white, knobStyle: KnobStyle(color: Colors.white)),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        '${riskScore.toInt()}% Risk',
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    )
                  ],
                ),
              ],
            ).animate().scale(duration: 600.ms),
          ),
          const SizedBox(height: 16),
          Text(
            gemini.isScamDetected ? 'High Danger Scam Detected' : 'Likely Safe',
            style: GoogleFonts.inter(
              fontSize: 22,
              color: gemini.isScamDetected ? Colors.redAccent : Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          Text(
            gemini.analysisResult,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white,
              height: 1.5,
              fontSize: 16,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
