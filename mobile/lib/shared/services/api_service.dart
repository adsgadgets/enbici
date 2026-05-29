import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user_model.dart';

/// Cliente HTTP centralizado con Dio
/// - Base URL desde .env
/// - JWT token adjunto automáticamente
/// - Manejo de errores centralizado
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['FLUTTER_API_URL'] ?? 'http://10.0.2.2:3000/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Adjuntar JWT en cada request
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 401 → limpiar token y redirigir al login (manejado por el router)
        if (error.response?.statusCode == 401) {
          const FlutterSecureStorage().delete(key: 'jwt_token');
        }
        handler.next(error);
      },
    ));
  }

  late final Dio _dio;

  // ──────────────────────────────────────
  // AUTH
  // ──────────────────────────────────────

  /// Verifica el token Firebase OTP con el backend y retorna JWT + User
  Future<({String jwt, UserModel user})> verifyFirebaseToken(
      String firebaseToken) async {
    final response = await _dio.post('/auth/verify-otp', data: {
      'firebase_token': firebaseToken,
    });

    final data = response.data as Map<String, dynamic>;
    return (
      jwt: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  // ──────────────────────────────────────
  // USUARIOS
  // ──────────────────────────────────────

  Future<UserModel> getMe() async {
    final response = await _dio.get('/users/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/users/me', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ──────────────────────────────────────
  // ACOMPAÑANTES CERCANOS
  // ──────────────────────────────────────

  Future<List<NearbyCompanion>> getNearbyCompanions({
    required double lat,
    required double lng,
    required String serviceType, // 'motorcycle' | 'car_driver'
  }) async {
    final response = await _dio.get('/companions/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'service_type': serviceType,
    });

    final list = response.data as List<dynamic>;
    return list
        .map((e) => NearbyCompanion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ──────────────────────────────────────
  // VIAJES
  // ──────────────────────────────────────

  Future<Map<String, dynamic>> createRide({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String serviceType,
  }) async {
    final response = await _dio.post('/rides', data: {
      'origin': {'lat': originLat, 'lng': originLng},
      'destination': {'lat': destLat, 'lng': destLng},
      'service_type': serviceType,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> activateSOS(String rideId) async {
    await _dio.post('/rides/$rideId/sos');
  }
}

/// Acompañante cercano retornado por el endpoint de matching
class NearbyCompanion {
  const NearbyCompanion({
    required this.userId,
    required this.name,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
    required this.vehiclePlate,
    required this.vehicleBrand,
    required this.serviceType,
  });

  final String userId;
  final String name;
  final double rating;
  final double lat;
  final double lng;
  final double distanceMeters;
  final String vehiclePlate;
  final String vehicleBrand;
  final String serviceType;

  factory NearbyCompanion.fromJson(Map<String, dynamic> json) =>
      NearbyCompanion(
        userId: json['id'] as String,
        name: json['name'] as String,
        rating: (json['rating'] as num).toDouble(),
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        distanceMeters: (json['distance_meters'] as num).toDouble(),
        vehiclePlate: json['plate'] as String,
        vehicleBrand: json['brand'] as String,
        serviceType: json['service_type'] as String,
      );

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }

  int get etaMinutes => (distanceMeters / 500).ceil(); // ~30 km/h en moto
}
