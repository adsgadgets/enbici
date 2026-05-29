import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Botón SOS — Componente crítico de seguridad
///
/// Requiere DOBLE TAP para activarse (anti-activación accidental):
/// 1. Primer tap: muestra anillo de confirmación durante 2 segundos
/// 2. Segundo tap dentro de los 2s: activa el SOS
///
/// Si pasan 2 segundos sin segundo tap → se cancela silenciosamente.
/// Los primeros 10s post-activación aparece botón "Fue un error".
class SOSButton extends StatefulWidget {
  const SOSButton({
    super.key,
    required this.onActivated,
    required this.onCancelled,
    this.isActive = false,
  });

  final VoidCallback onActivated;
  final VoidCallback onCancelled;
  final bool isActive;

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool _waitingForSecondTap = false;
  DateTime? _firstTapTime;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isActive) return;

    final now = DateTime.now();

    if (!_waitingForSecondTap) {
      // PRIMER TAP: iniciar ventana de confirmación
      setState(() => _waitingForSecondTap = true);
      _firstTapTime = now;

      // Feedback háptico: 1 vibración corta
      HapticFeedback.mediumImpact();

      // Cancelar automáticamente si no hay segundo tap en 2 segundos
      Future.delayed(
        Duration(milliseconds: SOSConstants.doubleTapWindowMs),
        () {
          if (mounted && _waitingForSecondTap) {
            setState(() => _waitingForSecondTap = false);
          }
        },
      );
    } else {
      // SEGUNDO TAP dentro de la ventana → ACTIVAR SOS
      final elapsed = now.difference(_firstTapTime!).inMilliseconds;
      if (elapsed <= SOSConstants.doubleTapWindowMs) {
        setState(() => _waitingForSecondTap = false);
        _activateSOS();
      }
    }
  }

  void _activateSOS() {
    // Vibración larga repetida = SOS activo
    Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
    HapticFeedback.heavyImpact();
    widget.onActivated();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Texto de instrucción
        if (_waitingForSecondTap)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Toca de nuevo para confirmar',
              style: TextStyle(
                color: AppColors.sos,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

        // Botón principal
        ScaleTransition(
          scale: widget.isActive ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: AppSizes.sosButton,
              height: AppSizes.sosButton,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _waitingForSecondTap
                    ? AppColors.sosBackground
                    : (widget.isActive ? AppColors.sos : AppColors.sos.withOpacity(0.9)),
                border: Border.all(
                  color: AppColors.sos,
                  width: _waitingForSecondTap ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sos.withOpacity(0.5),
                    blurRadius: widget.isActive ? 20 : 8,
                    spreadRadius: widget.isActive ? 4 : 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 32),
                  SizedBox(height: 2),
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Botón "Fue un error" (visible 10s post-activación)
        if (widget.isActive)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: widget.onCancelled,
              child: const Text(
                'Fue un error',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }
}
