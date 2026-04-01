import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class LifeSignsScreen extends StatefulWidget {
  const LifeSignsScreen({super.key});

  @override
  State<LifeSignsScreen> createState() => _LifeSignsScreenState();
}

class _LifeSignsScreenState extends State<LifeSignsScreen> {
  DateTime _lastMoved = DateTime.now();
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _accelerometerSubscription = userAccelerometerEventStream().listen((event) {
      // Threshold for movement
      if (event.x.abs() > 1.5 || event.y.abs() > 1.5 || event.z.abs() > 1.5) {
        setState(() {
          _lastMoved = DateTime.now();
          _isActive = true;
        });
      } else {
        final diff = DateTime.now().difference(_lastMoved);
        if (diff.inSeconds > 30 && _isActive) {
          setState(() {
            _isActive = false; // Presumed inactive if no movement for 30s
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  String _getTimeAgo() {
    final diff = DateTime.now().difference(_lastMoved);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inMinutes < 1) return '${diff.inSeconds} seconds ago';
    if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
    return '${diff.inHours} hours ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeSigns Monitor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isActive 
                      ? AppTheme.success.withOpacity(0.1) 
                      : AppTheme.error.withOpacity(0.1),
                  border: Border.all(
                    color: _isActive ? AppTheme.success : AppTheme.error,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _isActive ? Icons.favorite : Icons.favorite_border,
                    size: 100,
                    color: _isActive ? AppTheme.success : AppTheme.error,
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: _isActive ? 800.ms : 2000.ms),
                ),
              ).animate().scale(delay: 200.ms),
              
              const SizedBox(height: 40),
              
              Text(
                'Status: ${_isActive ? 'Active' : 'Inactive'}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: _isActive ? AppTheme.success : AppTheme.error,
                  fontSize: 28,
                ),
              ).animate().fade(delay: 400.ms),
              
              const SizedBox(height: 16),
              
              Text(
                'Last detected movement:\n${_getTimeAgo()}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ).animate().fade(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
