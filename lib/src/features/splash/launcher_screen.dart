import 'dart:ui';
import 'package:flutter/material.dart';

class SmartInvoiceLauncher extends StatefulWidget {
  final VoidCallback onFinish;

  const SmartInvoiceLauncher({
    super.key,
    required this.onFinish,
  });

  @override
  State<SmartInvoiceLauncher> createState() => _SmartInvoiceLauncherState();
}

class _SmartInvoiceLauncherState extends State<SmartInvoiceLauncher> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _drawAnimation;
  
  bool _startBlur = false;
  bool _isLoadingComplete = false;

  @override
  void initState() {
    super.initState();
    
    // --- LIAISON ANIMATION -> TRANSITION ---
    // Contrôleur natif Flutter pour piloter le dessin
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200), // Durée de l'animation de dessin
    );

    _drawAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Écouteur pour déclencher la suite quand le dessin est terminé
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationFinished();
      }
    });

    _initializeApp();
    
    // Lancer l'animation du logo
    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Simulation du chargement asynchrone (vérification Auth, base de données, etc.) de 3 secondes
    await Future.delayed(const Duration(seconds: 3));
    _isLoadingComplete = true;
    
    // Si l'animation est déjà terminée, on déclenche la transition
    if (_animationController.isCompleted) {
      _onAnimationFinished();
    }
  }

  void _onAnimationFinished() async {
    // On s'assure que le chargement EST terminé ET que l'animation est finie
    if (_isLoadingComplete && !_startBlur && mounted) {
      setState(() {
        _startBlur = true; // Déclenche l'effet Glassmorphism
      });
      
      // On laisse un délai de 600ms pour que le flou soit visible avant la transition vers l'app
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        widget.onFinish(); // Indique au main.dart (AnimatedSwitcher) de changer d'écran
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fond gris très clair
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- 1. ANIMATION LINE ART CENTRÉE ---
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: _drawAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _InvoiceLineArtPainter(
                      progress: _drawAnimation.value,
                      color: Colors.indigo, // Tracé de couleur Indigo
                    ),
                  );
                },
              ),
            ),
          ),
          
          // --- 2. EFFET DE FLOU (GLASSMORPHISM) ---
          if (_startBlur)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: const Color(0xFFF5F7FA).withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Peintre personnalisé pour dessiner le logo "Facture" de manière progressive
class _InvoiceLineArtPainter extends CustomPainter {
  final double progress;
  final Color color;

  _InvoiceLineArtPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // 1. Le contour du document (avec coin corné)
    path.moveTo(size.width * 0.25, size.height * 0.1);
    path.lineTo(size.width * 0.55, size.height * 0.1);
    path.lineTo(size.width * 0.75, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.9);
    path.lineTo(size.width * 0.25, size.height * 0.9);
    path.close();

    // 2. La ligne du coin corné
    path.moveTo(size.width * 0.55, size.height * 0.1);
    path.lineTo(size.width * 0.55, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.3);

    // 3. Les lignes de texte à l'intérieur de la facture
    path.moveTo(size.width * 0.4, size.height * 0.45);
    path.lineTo(size.width * 0.6, size.height * 0.45);

    path.moveTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.6);

    path.moveTo(size.width * 0.4, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height * 0.75);

    // Animation : Extraire uniquement la portion du tracé correspondant au "progress"
    final pathMetrics = path.computeMetrics();
    final animatedPath = Path();

    for (final metric in pathMetrics) {
      final extractLength = metric.length * progress;
      animatedPath.addPath(metric.extractPath(0.0, extractLength), Offset.zero);
    }

    // Dessiner le tracé animé
    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _InvoiceLineArtPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
