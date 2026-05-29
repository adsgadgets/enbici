import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/sos_button.dart';

/// Pantalla 7 — Viaje en curso
/// Mapa fullscreen + botón SOS + datos del viaje
/// TODO: Implementar tracking real-time en siguiente sprint
class RideInProgressScreen extends ConsumerStatefulWidget {
  const RideInProgressScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<RideInProgressScreen> createState() =>
      _RideInProgressScreenState();
}

class _RideInProgressScreenState extends ConsumerState<RideInProgressScreen> {
  bool _sosActive = false;

  void _activateSOS() {
    setState(() => _sosActive = true);
    // TODO: llamar a api.activateSOS(widget.rideId)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 SOS activado — Soporte notificado'),
        backgroundColor: AppColors.sos,
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _cancelSOS() {
    setState(() => _sosActive = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS cancelado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa (placeholder — se integrará con tracking real)
          Container(
            color: const Color(0xFF1A1A2E),
            child: const Center(
              child: Text(
                '🗺️\nMapa del viaje\n(en construcción)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          // Header con datos del viaje
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('00:00',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 16),
                    const Icon(Icons.speed_rounded,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    const Text('0 km/h',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón SOS — siempre visible, esquina inferior derecha
          Positioned(
            right: AppSizes.paddingL,
            bottom: AppSizes.paddingXL + MediaQuery.of(context).padding.bottom,
            child: SOSButton(
              isActive: _sosActive,
              onActivated: _activateSOS,
              onCancelled: _cancelSOS,
            ),
          ),
        ],
      ),
    );
  }
}
