import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:trusted/features/auth/presentation/screens/login_screen.dart';
import 'package:trusted/features/profile/presentation/screens/home_screen.dart';

/// A custom splash screen for the Trusted app
/// Features a dynamic animated background, lock animation,
/// and elegant text animations for the app name and tagline
class SplashScreen extends StatefulWidget {
  /// Constructor
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _lockAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _taglineAnimationController;
  late AnimationController _securityElementsController;
  
  // Animations
  late Animation<double> _backgroundAnimation1;
  late Animation<double> _backgroundAnimation2;
  late Animation<double> _glowAnimation;
  late Animation<double> _taglineOpacityAnimation;
  late Animation<double> _securityElementsAnimation;
  
  // Particles for background effect - reduced count for better performance
  final List<Particle> _particles = [];
  final List<GamepadParticle> _gamepadParticles = [];
  final int _particleCount = 15;
  final int _gamepadParticleCount = 4;
  
  // Timer for navigation
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialize background animation controller
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Configure background animations for gradient
    _backgroundAnimation1 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);
    
    _backgroundAnimation2 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Initialize lock animation controller
    _lockAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // Initialize glow animation controller
    _glowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    // Configure glow animation
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _glowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize tagline animation controller
    _taglineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // Configure tagline opacity animation
    _taglineOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _taglineAnimationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Initialize security elements animation controller
    _securityElementsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _securityElementsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _securityElementsController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Initialize particles for background effect
    _initializeParticles();
    
    // Start animations with proper timing
    _startAnimationSequence();
    
    // Set timer to navigate to appropriate screen after 6 seconds
    _navigationTimer = Timer(
      const Duration(seconds: 6),
      () {
        _navigateToNextScreen();
      },
    );
  }

  /// Navigate to the appropriate screen based on authentication status
  void _navigateToNextScreen() {
    // Use Riverpod to get the current auth state
    final authState = ProviderScope.containerOf(context).read(authStateProvider);
    
    if (authState.user != null) {
      // User is authenticated, navigate to home screen
      if (authState.user!.isAdmin) {
        Navigator.of(context).pushReplacementNamed('/admin/dashboard');
      } else if (authState.user!.isActive) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (authState.user!.isPending) {
        Navigator.of(context).pushReplacementNamed('/waiting');
      } else if (authState.user!.isRejected) {
        Navigator.of(context).pushReplacementNamed('/rejected');
      }
    } else {
      // User is not authenticated, navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  /// Initialize particles for background effect
  void _initializeParticles() {
    final random = math.Random();
    
    // Regular particles with reduced speed for better performance
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        Particle(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          speed: (0.2 + random.nextDouble() * 0.6) * 0.3,
          radius: 1 + random.nextDouble() * 2,
          opacity: 0.1 + random.nextDouble() * 0.3,
        ),
      );
    }
    
    // Initialize gamepad particles for gaming theme
    for (int i = 0; i < _gamepadParticleCount; i++) {
      _gamepadParticles.add(
        GamepadParticle(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          speed: (0.1 + random.nextDouble() * 0.2) * 0.3,
          size: 8 + random.nextDouble() * 12,
          opacity: 0.05 + random.nextDouble() * 0.15,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.01,
          rotation: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  /// Start animation sequence with adjusted timing
  void _startAnimationSequence() {
    // Start lock animation with custom curve for more elegant effect
    _lockAnimationController.repeat(
      min: 0.0,
      max: 1.0,
      period: const Duration(seconds: 3),
      reverse: true,
    );
    
    // Start glow animation after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      _glowAnimationController.forward();
    });
    
    // Start tagline animation after a delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      _taglineAnimationController.forward();
    });
    
    // Start security elements animation
    Future.delayed(const Duration(milliseconds: 3000), () {
      _securityElementsController.forward();
    });
  }

  @override
  void dispose() {
    // Dispose animation controllers
    _backgroundAnimationController.dispose();
    _lockAnimationController.dispose();
    _glowAnimationController.dispose();
    _taglineAnimationController.dispose();
    _securityElementsController.dispose();
    
    // Cancel navigation timer
    _navigationTimer?.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background with gradient and particles
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              // Update particles for animation
              for (final particle in _particles) {
                particle.position = Offset(
                  particle.position.dx,
                  (particle.position.dy + particle.speed) % MediaQuery.of(context).size.height,
                );
              }
              
              // Update gamepad particles for animation
              for (final gamepadParticle in _gamepadParticles) {
                gamepadParticle.position = Offset(
                  gamepadParticle.position.dx,
                  (gamepadParticle.position.dy + gamepadParticle.speed) % MediaQuery.of(context).size.height,
                );
                gamepadParticle.rotation += gamepadParticle.rotationSpeed;
              }
              
              return CustomPaint(
                painter: BackgroundPainter(
                  animation1Value: _backgroundAnimation1.value,
                  animation2Value: _backgroundAnimation2.value,
                  particles: _particles,
                  gamepadParticles: _gamepadParticles,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Content container
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer to push content slightly below center
                  const Spacer(flex: 2),
                  
                  // Enhanced logo with shield and lock
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.8),
                              AppColors.primary.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.4, 0.8, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3 + (_glowAnimation.value * 0.3)),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Shield background
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Icon(
                                  Icons.shield,
                                  size: 120,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Lock icon with enhanced animation
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: AnimatedBuilder(
                                  animation: _lockAnimationController,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary.withOpacity(0.3 + 0.3 * _lockAnimationController.value),
                                            blurRadius: 12 * _lockAnimationController.value,
                                            spreadRadius: 2 * _lockAnimationController.value,
                                          ),
                                        ],
                                      ),
                                      child: Transform.rotate(
                                        angle: 0.05 * math.sin(_lockAnimationController.value * math.pi * 2),
                                        child: Transform.scale(
                                          scale: 0.85 + 0.15 * _lockAnimationController.value,
                                          child: Icon(
                                            Icons.lock,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App name with smoother typewriter animation
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Trusted',
                            textStyle: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7 + 0.3 * _glowAnimation.value), // Fade effect
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withOpacity(_glowAnimation.value * 0.8),
                                  blurRadius: 12 * _glowAnimation.value,
                                  offset: const Offset(0, 0),
                                ),
                                Shadow(
                                  color: AppColors.secondary.withOpacity(_glowAnimation.value * 0.6),
                                  blurRadius: 18 * _glowAnimation.value,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            speed: const Duration(milliseconds: 300), // Slower for smoother effect
                            cursor: '',
                          ),
                        ],
                        totalRepeatCount: 1,
                        displayFullTextOnTap: true,
                        onNext: (index, isLast) {
                          // Add slight scale animation for each letter
                          _glowAnimationController.forward();
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tagline with fade-in animation and modern styling
                  FadeTransition(
                    opacity: _taglineOpacityAnimation,
                    child: Column(
                      children: [
                        Text(
                          'منصة التداول الآمنة',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: AppColors.primary.withOpacity(0.8),
                                blurRadius: 12,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: AppColors.secondary.withOpacity(0.6),
                                blurRadius: 18,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'أمان. ثقة. حماية.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Modern feature indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFeatureIndicator(Icons.security, 'تشفير متقدم'),
                            const SizedBox(width: 16),
                            _buildFeatureIndicator(Icons.verified, 'توثيق آمن'),
                            const SizedBox(width: 16),
                            _buildFeatureIndicator(Icons.speed, 'أداء سريع'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Spacer to push content slightly above center
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Helper method to build feature indicators
  Widget _buildFeatureIndicator(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for animated background with gradient and particles
class BackgroundPainter extends CustomPainter {
  final double animation1Value;
  final double animation2Value;
  final List<Particle> particles;
  final List<GamepadParticle> gamepadParticles;
  
  // Add previous values to compare in shouldRepaint
  final double _lastAnimation1Value;
  final double _lastAnimation2Value;

  BackgroundPainter({
    required this.animation1Value,
    required this.animation2Value,
    required this.particles,
    required this.gamepadParticles,
  }) : _lastAnimation1Value = animation1Value,
       _lastAnimation2Value = animation2Value;

  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background with slower shifting effect
    final paint = Paint();
    
    // Create a simplified gradient with fewer color stops for better performance
    final gradient = LinearGradient(
      begin: Alignment(
        math.cos(animation1Value) * 0.1,
        math.sin(animation1Value) * 0.1,
      ),
      end: Alignment(
        math.cos(animation2Value + math.pi) * 0.1,
        math.sin(animation2Value + math.pi) * 0.1,
      ),
      colors: [
        AppColors.primary.withOpacity(0.8),
        AppColors.secondary.withOpacity(0.6),
        Color.lerp(AppColors.primary, AppColors.secondary, 0.5)!.withOpacity(0.7),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw particles (only if they're visible for better performance)
    for (final particle in particles) {
      // Skip drawing very small or transparent particles
      if (particle.radius < 1.0 || particle.opacity < 0.05) continue;
      
      // Draw particle with a simplified effect
      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity);
      
      canvas.drawCircle(
        particle.position,
        particle.radius,
        particlePaint,
      );
      
      // Add a smaller, brighter core only to larger particles
      if (particle.radius > 2.0) {
        final corePaint = Paint()
          ..color = Colors.white.withOpacity(particle.opacity * 1.2);
        
        canvas.drawCircle(
          particle.position,
          particle.radius * 0.4,
          corePaint,
        );
      }
    }
    
    // Draw gamepad particles - simplified for better performance
    for (final gamepadParticle in gamepadParticles) {
      // Skip drawing very transparent particles
      if (gamepadParticle.opacity < 0.05) continue;
      
      canvas.save();
      
      // Translate to particle position
      canvas.translate(gamepadParticle.position.dx, gamepadParticle.position.dy);
      
      // Rotate the canvas for gamepad rotation
      canvas.rotate(gamepadParticle.rotation);
      
      // Draw gamepad icon (simplified)
      final gamepadPaint = Paint()
        ..color = AppColors.primary.withOpacity(gamepadParticle.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      // Draw gamepad body - simplified shape
      final bodyRect = Rect.fromCenter(
        center: Offset.zero,
        width: gamepadParticle.size,
        height: gamepadParticle.size * 0.6,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, Radius.circular(gamepadParticle.size * 0.2)),
        gamepadPaint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    // Only repaint if animation values have changed significantly
    return (animation1Value - oldDelegate._lastAnimation1Value).abs() > 0.01 ||
           (animation2Value - oldDelegate._lastAnimation2Value).abs() > 0.01;
  }
}

/// Particle class for background effect
class Particle {
  Offset position;
  final double speed;
  final double radius;
  final double opacity;

  Particle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

/// GamepadParticle class for gaming-themed background effect
class GamepadParticle {
  Offset position;
  final double speed;
  final double size;
  final double opacity;
  double rotation;
  final double rotationSpeed;

  GamepadParticle({
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
  });
}