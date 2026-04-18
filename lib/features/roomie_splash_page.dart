import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_routes.dart';
import 'auth/data/auth_repository.dart';

class RoomieSplashPage extends ConsumerStatefulWidget {
  const RoomieSplashPage({super.key});

  @override
  ConsumerState<RoomieSplashPage> createState() => _RoomieSplashPageState();
}

class _RoomieSplashPageState extends ConsumerState<RoomieSplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _houseController;
  late final AnimationController _peopleController;
  late final AnimationController _arcController;
  late final AnimationController _textController;

  late final Animation<double> _houseProgress;
  late final Animation<double> _peopleOpacity;
  late final Animation<Offset> _leftPersonOffset;
  late final Animation<Offset> _rightPersonOffset;
  late final Animation<double> _arcProgress;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textScale;

  @override
  void initState() {
    super.initState();

    _houseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _peopleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _houseProgress = CurvedAnimation(
      parent: _houseController,
      curve: Curves.easeOutCubic,
    );

    _peopleOpacity = CurvedAnimation(
      parent: _peopleController,
      curve: Curves.easeOut,
    );

    _leftPersonOffset = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _peopleController, curve: Curves.easeOutBack),
    );

    _rightPersonOffset = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _peopleController, curve: Curves.easeOutBack),
    );

    _arcProgress = CurvedAnimation(
      parent: _arcController,
      curve: Curves.easeOut,
    );

    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    _textScale = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    _runAnimation();
  }

  Future<void> _runAnimation() async {
    await _houseController.forward();
    await _peopleController.forward();
    await _arcController.forward();
    await _textController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final loginResult =
        await ref.read(authRepositoryProvider).tryLoginWithRefreshToken();
    if (!mounted) return;

    final targetRoute =
        loginResult == null ? AppRoutes.register : AppRoutes.shell;

    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  void dispose() {
    _houseController.dispose();
    _peopleController.dispose();
    _arcController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF5D2B99);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _houseController,
            _peopleController,
            _arcController,
            _textController,
          ]),
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 130,
                  height: 117,
                  child: CustomPaint(
                    painter: _RoomieLogoPainter(
                      houseProgress: _houseProgress.value,
                      peopleOpacity: _peopleOpacity.value,
                      leftPersonDy: _leftPersonOffset.value.dy,
                      rightPersonDy: _rightPersonOffset.value.dy,
                      arcProgress: _arcProgress.value,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Opacity(
                  opacity: _textOpacity.value,
                  child: Transform.scale(
                    scale: _textScale.value,
                    child: const Text(
                      'Roomie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RoomieLogoPainter extends CustomPainter {
  final double houseProgress;
  final double peopleOpacity;
  final double leftPersonDy;
  final double rightPersonDy;
  final double arcProgress;

  _RoomieLogoPainter({
    required this.houseProgress,
    required this.peopleOpacity,
    required this.leftPersonDy,
    required this.rightPersonDy,
    required this.arcProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final whiteFill = Paint()
      ..color = Colors.white.withOpacity(peopleOpacity)
      ..style = PaintingStyle.fill;

    final housePath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.17)
      ..lineTo(size.width * 0.20, size.height * 0.47)
      ..lineTo(size.width * 0.20, size.height * 0.89)
      ..lineTo(size.width * 0.80, size.height * 0.89)
      ..lineTo(size.width * 0.80, size.height * 0.47)
      ..lineTo(size.width * 0.725, size.height * 0.47)
      ..lineTo(size.width * 0.725, size.height * 0.31)
      ..lineTo(size.width * 0.625, size.height * 0.31)
      ..lineTo(size.width * 0.625, size.height * 0.38)
      ..lineTo(size.width * 0.50, size.height * 0.17);

    for (final metric in housePath.computeMetrics()) {
      final extracted = metric.extractPath(0, metric.length * houseProgress);
      canvas.drawPath(extracted, whiteStroke);
    }

    final leftHeadCenter = Offset(
      size.width * 0.385,
      size.height * (0.64 + leftPersonDy),
    );
    final rightHeadCenter = Offset(
      size.width * 0.615,
      size.height * (0.64 + rightPersonDy),
    );

    canvas.drawCircle(leftHeadCenter, size.width * 0.092, whiteFill);
    canvas.drawCircle(rightHeadCenter, size.width * 0.092, whiteFill);

    final leftBody = Path()
      ..moveTo(size.width * 0.295, size.height * (0.83 + leftPersonDy))
      ..quadraticBezierTo(
        size.width * 0.295,
        size.height * (0.75 + leftPersonDy),
        size.width * 0.385,
        size.height * (0.75 + leftPersonDy),
      )
      ..quadraticBezierTo(
        size.width * 0.475,
        size.height * (0.75 + leftPersonDy),
        size.width * 0.475,
        size.height * (0.83 + leftPersonDy),
      )
      ..close();

    final rightBody = Path()
      ..moveTo(size.width * 0.525, size.height * (0.83 + rightPersonDy))
      ..quadraticBezierTo(
        size.width * 0.525,
        size.height * (0.75 + rightPersonDy),
        size.width * 0.615,
        size.height * (0.75 + rightPersonDy),
      )
      ..quadraticBezierTo(
        size.width * 0.705,
        size.height * (0.75 + rightPersonDy),
        size.width * 0.705,
        size.height * (0.83 + rightPersonDy),
      )
      ..close();

    canvas.drawPath(leftBody, whiteFill);
    canvas.drawPath(rightBody, whiteFill);

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final arc = Path()
      ..moveTo(size.width * 0.46, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.60,
        size.width * 0.54,
        size.height * 0.66,
      );

    for (final metric in arc.computeMetrics()) {
      final extracted = metric.extractPath(0, metric.length * arcProgress);
      canvas.drawPath(extracted, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoomieLogoPainter oldDelegate) {
    return oldDelegate.houseProgress != houseProgress ||
        oldDelegate.peopleOpacity != peopleOpacity ||
        oldDelegate.leftPersonDy != leftPersonDy ||
        oldDelegate.rightPersonDy != rightPersonDy ||
        oldDelegate.arcProgress != arcProgress;
  }
}
