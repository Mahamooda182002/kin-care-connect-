import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../theme/app_theme.dart';
import '../services/firebase_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _stillTimer;
  bool _isMoving = false;
  DateTime _lastActive = DateTime.now();

  static const double _movementThreshold = 1.5; // Sensitivity threshold
  static const int _stillDurationSeconds = 10; // Time before marking as "Still"

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      // Calculate acceleration magnitude (approx 9.8 is gravity, so we check difference)
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      bool currentlyMoving = (magnitude - 9.8).abs() > _movementThreshold;

      if (currentlyMoving) {
        _onMovementDetected();
      }
    });

    // Start initial timer
    _resetStillTimer();
  }

  void _onMovementDetected() {
    if (!_isMoving) {
      setState(() {
        _isMoving = true;
        _lastActive = DateTime.now();
      });
      // Update Firebase
      context.read<FirebaseService>().updateLastActiveStatus(true);
    }
    _resetStillTimer();
  }

  void _resetStillTimer() {
    _stillTimer?.cancel();
    _stillTimer = Timer(const Duration(seconds: _stillDurationSeconds), () {
      if (mounted && _isMoving) {
        setState(() {
          _isMoving = false;
        });
        // Update Firebase
        context.read<FirebaseService>().updateLastActiveStatus(false);
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _stillTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Routine Intelligence',
          style: GoogleFonts.grandHotel(
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildLifeSignsCard(),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: Divider(color: AppTheme.secondary, height: 1, thickness: 0.5),
          ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildFeedPost(context, index);
              },
              childCount: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeSignsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadows,
        border: Border.all(
          color: _isMoving ? AppTheme.success.withOpacity(0.5) : AppTheme.error.withOpacity(0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _isMoving ? Icons.directions_walk : Icons.accessibility_new,
            size: 64,
            color: _isMoving ? AppTheme.success : AppTheme.textMuted,
          )
          .animate(target: _isMoving ? 1 : 0)
          .scaleXY(end: 1.1, curve: Curves.easeInOut)
          .tint(color: AppTheme.success),
          
          const SizedBox(height: 16),
          
          Text(
            _isMoving ? 'Status: Active' : 'Status: Still',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: _isMoving ? AppTheme.success : AppTheme.error,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _isMoving 
                ? 'Device movement detected.' 
                : 'No movement detected for $_stillDurationSeconds seconds.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.secondary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.update, size: 20, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                Text(
                  'Last Active: ${_lastActive.hour}:${_lastActive.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildFeedPost(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppTheme.surface,
            child: Icon(Icons.favorite, color: AppTheme.primary, size: 20),
          ),
          title: const Text('Health Insight', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${index + 1} hours ago'),
          trailing: const Icon(Icons.more_vert),
        ),
        
        Container(
          width: double.infinity,
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.secondary),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Hydration Reminder: Ensure you drink a glass of water after your walk.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppTheme.textMedium),
              ),
            ),
          ),
        ),
        
        Row(
          children: [
            IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
            IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
            const Spacer(),
            IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          ],
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Text('Liked by family_watch', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
      ],
    ).animate().fade(delay: (300 + (index * 100)).ms);
  }
}
