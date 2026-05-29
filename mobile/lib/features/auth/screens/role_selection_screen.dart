import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user_model.dart';

/// Pantalla de selección de rol (solo aparece en el primer login)
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.paddingXL),
              const Text(
                '¿Cómo vas a usar EnBici?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes cambiar esto después desde tu perfil.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),
              _RoleCard(
                icon: Icons.directions_bike_rounded,
                title: 'Soy ciclista',
                subtitle: 'Quiero contratar acompañamiento en mis rutas',
                role: UserRole.cyclist,
                onTap: () => context.go('/cyclist/dashboard'),
              ),
              const SizedBox(height: AppSizes.paddingM),
              _RoleCard(
                icon: Icons.two_wheeler_rounded,
                title: 'Acompañante en Moto',
                subtitle: 'Quiero ganar dinero siguiendo a ciclistas',
                role: UserRole.motorcyclist,
                onTap: () => context.go('/cyclist/dashboard'), // TODO: companion dashboard
              ),
              const SizedBox(height: AppSizes.paddingM),
              _RoleCard(
                icon: Icons.directions_car_rounded,
                title: 'Conductor de Auto',
                subtitle: 'Conduzco el vehículo del ciclista durante su ruta',
                role: UserRole.driver,
                onTap: () => context.go('/cyclist/dashboard'), // TODO: driver dashboard
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.role,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final UserRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
