import 'dart:ui';
import 'package:flutter/material.dart';

class SmartDeliveryLauncher extends StatefulWidget {
  final VoidCallback onFinish;

  const SmartDeliveryLauncher({
    super.key,
    required this.onFinish,
  });

  @override
  State<SmartDeliveryLauncher> createState() => _SmartDeliveryLauncherState();
}

class _SmartDeliveryLauncherState extends State<SmartDeliveryLauncher> with SingleTickerProviderStateMixin {
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
          // --- 1. ANIMATION LOGO DELIVERY ---
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(_drawAnimation),
              child: FadeTransition(
                opacity: _drawAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
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
