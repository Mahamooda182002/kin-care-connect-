import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 80,
                  color: AppTheme.primary,
                ).animate().custom(
                  duration: 800.ms,
                  builder: (_, value, child) => Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: child,
                  ),
                ).fade(duration: 800.ms),
                
                const SizedBox(height: 32),
                Text(
                  'Kin-CareConnect',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.grandHotel(
                    color: AppTheme.textLight,
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 48),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Phone number, username, or email',
                  ),
                ).animate().fade(delay: 400.ms).slideX(begin: 0.05),
                
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                ).animate().fade(delay: 500.ms).slideX(begin: 0.05),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Instagram-style bottom navigation wrapper
                    Navigator.pushReplacementNamed(context, '/main_nav');
                  },
                  child: const Text('Log in'),
                ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.secondary)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: AppTheme.secondary)),
                  ],
                ).animate().fade(delay: 700.ms),

                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.facebook, color: AppTheme.accentBlue),
                  label: const Text(
                    'Log in with Relatives',
                    style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold),
                  ),
                ).animate().fade(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.secondary, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: AppTheme.textMuted),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Sign up.',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
