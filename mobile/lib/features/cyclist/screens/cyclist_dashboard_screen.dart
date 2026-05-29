import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/services/api_service.dart';

/// Pantalla 3 — Dashboard principal del ciclista
/// Mapa a pantalla completa con:
/// - Ubicación del ciclista (punto azul)
/// - Pines de acompañantes disponibles en radio 2km
/// - Bottom sheet con botón "Solicitar servicio"
/// - FAB para centrar mapa en la ubicación actual
class CyclistDashboardScreen extends ConsumerStatefulWidget {
  const CyclistDashboardScreen({super.key});

  @override
  ConsumerState<CyclistDashboardScreen> createState() =>
      _CyclistDashboardScreenState();
}

class _CyclistDashboardScreenState
    extends ConsumerState<CyclistDashboardScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<NearbyCompanion> _companions = [];
  bool _loadingLocation = true;
  bool _loadingCompanions = false;
  Timer? _refreshTimer;

  // Mapa oscuro personalizado (visibilidad bajo sol)
  static const _mapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#212121"}]},
    {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
    {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────
  // Ubicación
  // ──────────────────────────────────────

  Future<void> _initLocation() async {
    final permission = await _requestLocationPermission();
    if (!permission) {
      setState(() => _loadingLocation = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _loadingLocation = false;
      });
      _centerMap(position);
      await _loadNearbyCompanions();

      // Actualizar acompañantes cada 15 segundos
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _loadNearbyCompanions(),
      );
    } catch (e) {
      setState(() => _loadingLocation = false);
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void _centerMap(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  // Acompañantes cercanos
  // ──────────────────────────────────────

  Future<void> _loadNearbyCompanions() async {
    if (_currentPosition == null) return;
    setState(() => _loadingCompanions = true);

    try {
      final api = ref.read(apiServiceProvider);
      final companions = await api.getNearbyCompanions(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        serviceType: 'motorcycle',
      );

      final markers = <Marker>{};

      for (final companion in companions) {
        markers.add(
          Marker(
            markerId: MarkerId(companion.userId),
            position: LatLng(companion.lat, companion.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: companion.name,
              snippet:
                  '⭐ ${companion.rating.toStringAsFixed(1)} · ${companion.distanceLabel} · ~${companion.etaMinutes} min',
            ),
            onTap: () => _showCompanionCard(companion),
          ),
        );
      }

      setState(() {
        _companions = companions;
        _markers = markers;
        _loadingCompanions = false;
      });
    } catch (_) {
      setState(() => _loadingCompanions = false);
    }
  }

  void _showCompanionCard(NearbyCompanion companion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CompanionPreviewSheet(
        companion: companion,
        onRequest: () {
          Navigator.pop(context);
          context.push('/cyclist/request');
        },
      ),
    );
  }

  // ──────────────────────────────────────
  // UI
  // ──────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa a pantalla completa ──
          _loadingLocation
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : const LatLng(4.7110, -74.0721), // Bogotá fallback
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    controller.setMapStyle(_mapStyle);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  mapType: MapType.normal,
                ),

          // ── Header con bienvenida ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  // Chip de acompañantes disponibles
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _loadingCompanions
                              ? 'Buscando...'
                              : '${_companions.length} acompañantes cerca',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Botón de perfil
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.95),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_outline_rounded),
                      onPressed: () {}, // TODO: perfil
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── FAB centrar mapa ──
          Positioned(
            right: AppSizes.paddingM,
            bottom: 240,
            child: FloatingActionButton.small(
              heroTag: 'center_map',
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.onSurface,
              elevation: 4,
              onPressed: () {
                if (_currentPosition != null) _centerMap(_currentPosition!);
              },
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // ── Bottom Sheet fijo ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomRequestSheet(
              companionsCount: _companions.length,
              onRequest: () => context.push('/cyclist/request'),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────
// Bottom sheet: solicitar servicio
// ──────────────────────────────────────
class _BottomRequestSheet extends StatelessWidget {
  const _BottomRequestSheet({
    required this.companionsCount,
    required this.onRequest,
  });

  final int companionsCount;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        AppSizes.paddingL + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          Row(
            children: [
              const Text(
                '¿A dónde vas hoy?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (companionsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$companionsCount disponibles',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Selector de tipo de servicio
          Row(
            children: [
              Expanded(
                child: _ServiceTypeChip(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Moto',
                  sublabel: 'Te sigue en ruta',
                  selected: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: _ServiceTypeChip(
                  icon: Icons.directions_car_rounded,
                  label: 'Auto propio',
                  sublabel: 'Conduce tu vehículo',
                  selected: false,
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingM),

          // Botón principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: companionsCount > 0 ? onRequest : null,
              icon: const Icon(Icons.search_rounded),
              label: Text(
                companionsCount > 0
                    ? 'Solicitar acompañamiento'
                    : 'Sin acompañantes disponibles',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTypeChip extends StatelessWidget {
  const _ServiceTypeChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS + 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.primary
                        : AppColors.onSurface,
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────
// Preview de un acompañante en el mapa
// ──────────────────────────────────────
class _CompanionPreviewSheet extends StatelessWidget {
  const _CompanionPreviewSheet({
    required this.companion,
    required this.onRequest,
  });

  final NearbyCompanion companion;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(companion.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          companion.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.two_wheeler_rounded,
                            color: AppColors.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          companion.vehicleBrand,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    companion.distanceLabel,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '~${companion.etaMinutes} min',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRequest,
              child: Text('Solicitar a ${companion.name.split(' ').first}'),
            ),
          ),
        ],
      ),
    );
  }
}
