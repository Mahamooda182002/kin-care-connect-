import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../widgets/glass_card.dart';

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
  bool _notificationTriggered = false;

  static const double _movementThreshold = 1.5; // Sensitivity threshold
  static const int _stillDurationSeconds = 4 * 60 * 60; // 4 hours

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      bool currentlyMoving = (magnitude - 9.8).abs() > _movementThreshold;

      if (currentlyMoving) {
        _onMovementDetected();
      }
    });
    _resetStillTimer();
  }

  void _onMovementDetected() {
    _lastActive = DateTime.now();
    _notificationTriggered = false;

    if (!_isMoving) {
      setState(() {
        _isMoving = true;
      });
      context.read<FirebaseService>().updateLastActiveStatus(true);
    }
    _resetStillTimer();
  }

  void _resetStillTimer() {
    _stillTimer?.cancel();
    _stillTimer = Timer(const Duration(seconds: _stillDurationSeconds), () {
      if (mounted) {
        if (_isMoving) {
          setState(() {
            _isMoving = false;
          });
          context.read<FirebaseService>().updateLastActiveStatus(false);
        }
        
        // Trigger notification after 4 hours of no movement
        if (!_notificationTriggered) {
          NotificationService.showInactivityAlert();
          _notificationTriggered = true;
        }
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Routine Intelligence',
          style: GoogleFonts.grandHotel(
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildLifeSignsCard(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildLifeSignsCard() {
    final statusColor = _isMoving ? AppTheme.success : AppTheme.error;
    
    return GlassCard(
      opacity: 0.1,
      borderColor: statusColor.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _isMoving ? Icons.directions_walk : Icons.accessibility_new,
            size: 80,
            color: statusColor,
          )
          .animate(target: _isMoving ? 1 : 0)
          .scaleXY(end: 1.15, curve: Curves.easeInOutBack),
          
          const SizedBox(height: 20),
          
          Text(
            _isMoving ? 'Status: Active' : 'Status: Still',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _isMoving 
                ? 'Healthy movement pattern detected.' 
                : 'No movement detected for a while.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.update, size: 22, color: Colors.white70),
                const SizedBox(width: 12),
                Text(
                  'Last Active: ${_lastActive.hour}:${_lastActive.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fade(duration: 800.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }

  Widget _buildFeedPost(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 10)
              ]
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.favorite, color: AppTheme.error, size: 20),
            ),
          ),
          title: const Text('Health Insight', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text('${index + 1} hours ago', style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.more_vert, color: Colors.white),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GlassCard(
            opacity: 0.1,
            blur: 10,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 220,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Hydration Reminder: Ensure you drink a glass of water after your walk.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22, 
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        Row(
          children: [
            IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.white), onPressed: () {}),
            const Spacer(),
            IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white), onPressed: () {}),
          ],
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Text('Liked by family_watch', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 24),
      ],
    ).animate().fade(delay: (300 + (index * 100)).ms);
  }
}
