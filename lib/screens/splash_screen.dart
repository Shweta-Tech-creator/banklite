import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/banking_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_wrapper.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // 1. Formation of the architectural Bank structure
  late AnimationController _bankFormController;
  late Animation<double> _roofAnimation;
  late Animation<double> _pillarsAnimation;
  late Animation<double> _baseAnimation;
  late Animation<double> _glowBurstAnimation;

  // 2. Dual continuous orbital ring beam controllers
  late AnimationController _orbitController;
  late AnimationController _innerOrbitController;

  // 3. Ambient floating particle & breathing glow controller
  late AnimationController _ambientController;

  // 4. Text & branding reveal
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Formation sequence (1.8s)
    _bankFormController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _roofAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bankFormController, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)),
    );

    _pillarsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bankFormController, curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic)),
    );

    _baseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bankFormController, curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic)),
    );

    _glowBurstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bankFormController, curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack)),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bankFormController, curve: const Interval(0.4, 0.9, curve: Curves.easeIn)),
    );

    _textSlideAnimation = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(parent: _bankFormController, curve: const Interval(0.4, 0.95, curve: Curves.easeOutCubic)),
    );

    // Continuous Primary Clockwise Orbital Comet (1.6s loop)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Continuous Secondary Counter-Clockwise Orbital Comet (2.4s loop)
    _innerOrbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Ambient floating starfield pulse (3s loop)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _bankFormController.forward();

    // Transition to Dashboard (if logged in) or Login screen after 2.9s
    _navTimer = Timer(const Duration(milliseconds: 2900), () {
      if (mounted) {
        final isLoggedIn = context.bankingRead.isLoggedIn;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 450),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _bankFormController.dispose();
    _orbitController.dispose();
    _innerOrbitController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF030712), // Obsidian Space Void
                Color(0xFF0A1128), // Deep Royal Navy
                Color(0xFF001F3F), // Electric Midnight Blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Background Bokeh Sparkles
                AnimatedBuilder(
                  animation: _ambientController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: _StarfieldPainter(progress: _ambientController.value),
                    );
                  },
                ),

                // 2. Central Animation Column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Central Bank Formation Core & Orbital Ring Loader
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _bankFormController,
                        _orbitController,
                        _innerOrbitController,
                        _ambientController,
                      ]),
                      builder: (context, child) {
                        final outerAngle = _orbitController.value * 2 * math.pi;
                        final innerAngle = -(_innerOrbitController.value * 2 * math.pi);
                        final burst = _glowBurstAnimation.value;
                        final ambientPulse = 1.0 + (_ambientController.value * 0.08);

                        return SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Radial Energy Bloom Halo
                              Transform.scale(
                                scale: ambientPulse,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.electricCyan.withValues(alpha: 0.25 * burst),
                                        AppColors.accentBlue.withValues(alpha: 0.12 * burst),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Dual Orbital Comets Moving Around the Bank
                              CustomPaint(
                                size: const Size(190, 190),
                                painter: _DualOrbitalCometPainter(
                                  outerAngle: outerAngle,
                                  innerAngle: innerAngle,
                                  formProgress: _bankFormController.value,
                                ),
                              ),

                              // Neoclassical Architectural Bank Emblem (Draws & Forms Live)
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0F172A), Color(0xFF003B73), Color(0xFF0066FF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: AppColors.electricCyan.withValues(alpha: 0.5 + (burst * 0.5)),
                                    width: 2.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentBlue.withValues(alpha: 0.5),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomPaint(
                                    size: const Size(50, 48),
                                    painter: _BankArchitecturePainter(
                                      roofProgress: _roofAnimation.value,
                                      pillarsProgress: _pillarsAnimation.value,
                                      baseProgress: _baseAnimation.value,
                                      burstProgress: burst,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // App Name & Tagline Reveal
                    AnimatedBuilder(
                      animation: _bankFormController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Column(
                              children: [
                                const Text(
                                  'BankLite',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Simple. Secure. Smarter Banking.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 3),

                    // 256-bit Bank Grade Security Footnote Badge
                    AnimatedBuilder(
                      animation: _bankFormController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: AppColors.electricCyan,
                                  size: 15,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '256-bit Bank Grade Security',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that procedurally draws and builds the neoclassical Bank structure step-by-step
class _BankArchitecturePainter extends CustomPainter {
  final double roofProgress;
  final double pillarsProgress;
  final double baseProgress;
  final double burstProgress;

  _BankArchitecturePainter({
    required this.roofProgress,
    required this.pillarsProgress,
    required this.baseProgress,
    required this.burstProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    // 1. Pediment / Triangular Roof Formation (0.0 -> roofProgress)
    if (roofProgress > 0.0) {
      final roofPath = Path();
      final apexX = w / 2;
      final apexY = h * 0.08;
      final leftX = w * 0.12;
      final rightX = w * 0.88;
      final roofBottomY = h * 0.32;

      // Draw left and right slopes outward from apex
      final currLeftX = apexX + (leftX - apexX) * roofProgress;
      final currRightX = apexX + (rightX - apexX) * roofProgress;
      final currBottomY = apexY + (roofBottomY - apexY) * roofProgress;

      roofPath.moveTo(apexX, apexY);
      roofPath.lineTo(currLeftX, currBottomY);
      roofPath.moveTo(apexX, apexY);
      roofPath.lineTo(currRightX, currBottomY);

      if (roofProgress > 0.6) {
        final baseWidthRatio = (roofProgress - 0.6) / 0.4;
        roofPath.moveTo(leftX, roofBottomY);
        roofPath.lineTo(leftX + (rightX - leftX) * baseWidthRatio, roofBottomY);
      }

      canvas.drawPath(roofPath, strokePaint);

      // Inner roof medallion dot when roof completes
      if (roofProgress > 0.8) {
        final dotPaint = Paint()..color = AppColors.electricCyan;
        canvas.drawCircle(Offset(w / 2, h * 0.22), 2.2 * roofProgress, dotPaint);
      }
    }

    // 2. Neoclassical Pillars (4 vertical columns dropping down)
    if (pillarsProgress > 0.0) {
      final pillarTopY = h * 0.36;
      final pillarMaxBottomY = h * 0.74;
      final currentPillarBottomY = pillarTopY + (pillarMaxBottomY - pillarTopY) * pillarsProgress;

      const columnPositions = [0.22, 0.40, 0.60, 0.78];
      const columnWidth = 3.5;

      for (final colXRatio in columnPositions) {
        final colCenterX = w * colXRatio;
        final colRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            colCenterX - (columnWidth / 2),
            pillarTopY,
            columnWidth,
            currentPillarBottomY - pillarTopY,
          ),
          const Radius.circular(1.5),
        );
        canvas.drawRRect(colRect, fillPaint);
      }
    }

    // 3. Foundation Base Steps (Expanding outward at base)
    if (baseProgress > 0.0) {
      final step1Y = h * 0.78;
      final step2Y = h * 0.88;

      final step1Width = (w * 0.84) * baseProgress;
      final step2Width = (w * 0.94) * baseProgress;

      final step1Rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, step1Y), width: step1Width, height: 3.2),
        const Radius.circular(1.5),
      );
      final step2Rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, step2Y), width: step2Width, height: 3.8),
        const Radius.circular(1.8),
      );

      canvas.drawRRect(step1Rect, fillPaint);
      canvas.drawRRect(step2Rect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BankArchitecturePainter oldDelegate) {
    return oldDelegate.roofProgress != roofProgress ||
        oldDelegate.pillarsProgress != pillarsProgress ||
        oldDelegate.baseProgress != baseProgress ||
        oldDelegate.burstProgress != burstProgress;
  }
}

/// Custom painter for Dual Glowing Orbital Comets with particle beams traveling 360° around the bank
class _DualOrbitalCometPainter extends CustomPainter {
  final double outerAngle;
  final double innerAngle;
  final double formProgress;

  _DualOrbitalCometPainter({
    required this.outerAngle,
    required this.innerAngle,
    required this.formProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - 8;
    final innerRadius = outerRadius - 16;

    // 1. Outer Faint Track
    final outerTrackPaint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.12 * formProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, outerRadius, outerTrackPaint);

    // 2. Outer Primary Clockwise Glowing Comet Beam
    final outerSweep = math.pi * 0.9;
    final outerStart = outerAngle - outerSweep;
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);

    final outerGradient = SweepGradient(
      startAngle: outerStart,
      endAngle: outerStart + outerSweep,
      colors: [
        const Color(0xFF00D2FF).withValues(alpha: 0.0),
        const Color(0xFF0066FF).withValues(alpha: 0.6),
        const Color(0xFF00D2FF),
        Colors.white,
      ],
      stops: const [0.0, 0.45, 0.85, 1.0],
      transform: GradientRotation(outerStart),
    );

    final outerBeamPaint = Paint()
      ..shader = outerGradient.createShader(outerRect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.6;

    canvas.drawArc(outerRect, outerStart, outerSweep, false, outerBeamPaint);

    // Outer Comet Head (Bright Star with Neon Bloom)
    final outerHeadX = center.dx + outerRadius * math.cos(outerAngle);
    final outerHeadY = center.dy + outerRadius * math.sin(outerAngle);
    final outerHeadCenter = Offset(outerHeadX, outerHeadY);

    final outerGlowPaint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(outerHeadCenter, 6.5, outerGlowPaint);

    final outerCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(outerHeadCenter, 3.8, outerCorePaint);

    // 3. Inner Counter-Clockwise Orbital Arc
    if (formProgress > 0.4) {
      final innerSweep = math.pi * 0.6;
      final innerStart = innerAngle - innerSweep;
      final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

      final innerGradient = SweepGradient(
        startAngle: innerStart,
        endAngle: innerStart + innerSweep,
        colors: [
          const Color(0xFF0066FF).withValues(alpha: 0.0),
          const Color(0xFF00D2FF).withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.7, 1.0],
        transform: GradientRotation(innerStart),
      );

      final innerBeamPaint = Paint()
        ..shader = innerGradient.createShader(innerRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;

      canvas.drawArc(innerRect, innerStart, innerSweep, false, innerBeamPaint);

      // Inner Particle Spark
      final innerHeadX = center.dx + innerRadius * math.cos(innerAngle);
      final innerHeadY = center.dy + innerRadius * math.sin(innerAngle);
      canvas.drawCircle(
        Offset(innerHeadX, innerHeadY),
        2.5,
        Paint()..color = const Color(0xFF00D2FF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DualOrbitalCometPainter oldDelegate) {
    return oldDelegate.outerAngle != outerAngle ||
        oldDelegate.innerAngle != innerAngle ||
        oldDelegate.formProgress != formProgress;
  }
}

/// Atmospheric bokeh stardust particles in the void background
class _StarfieldPainter extends CustomPainter {
  final double progress;

  _StarfieldPainter({required this.progress});

  static final List<Offset> _stars = [
    const Offset(0.15, 0.20),
    const Offset(0.82, 0.18),
    const Offset(0.25, 0.75),
    const Offset(0.78, 0.72),
    const Offset(0.10, 0.50),
    const Offset(0.90, 0.45),
    const Offset(0.50, 0.12),
    const Offset(0.48, 0.88),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      final pos = Offset(star.dx * size.width, star.dy * size.height);
      final opacity = (0.25 + 0.35 * math.sin((progress * 2 * math.pi) + (i * 0.8))).clamp(0.1, 0.7);

      paint.color = AppColors.electricCyan.withValues(alpha: opacity);
      final radius = 1.2 + (i % 3 == 0 ? 1.0 : 0.0);
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
