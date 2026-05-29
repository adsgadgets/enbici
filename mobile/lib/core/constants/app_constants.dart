/// Constantes globales de la aplicación EnBici

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1', // Android emulator → localhost
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 30000;
}

class RideConstants {
  RideConstants._();

  // Matching
  static const double searchRadiusMeters = 2000.0; // 2km
  static const int companionAcceptTimeoutSeconds = 30;

  // GPS tracking
  static const int gpsUpdateIntervalNormal = 3;    // segundos (viaje normal)
  static const int gpsUpdateIntervalSOS = 1;        // segundos (SOS activo)
  static const int gpsBatchSizeOffline = 500;       // puntos en SQLite sin señal

  // Anonimización GPS (Ley 1581/2012 Colombia)
  static const int gpsRetentionDays = 90;

  // Tarifas COP
  static const int baseFareCOP = 15000;
  static const int perMinuteCOP = 500;
}

class SOSConstants {
  SOSConstants._();

  static const int doubleTapWindowMs = 2000;       // Ventana para segundo tap
  static const int cancellationWindowSeconds = 10; // "Fue un error"
  static const int maxFalseAlarmsPerMonth = 3;
  static const int supportResponseTargetSeconds = 30;
  static const String emergencyNumber = '123';     // Colombia
}

class FareConstants {
  FareConstants._();

  static const Map<String, double> zoneMultipliers = {
    'urban': 1.0,
    'peripheral': 1.2,
    'rural': 1.3,
  };

  static const Map<String, double> surgeMultipliers = {
    'normal': 1.0,
    'peak': 1.5,     // Hora pico: 7-9am, 5-7pm
    'weekend': 1.2,  // Fines de semana
    'night': 1.8,    // 10pm - 5am
  };

  static const double maxSurgeMultiplier = 2.0;
  static const double platformFeePercent = 0.15;   // 15% comisión
  static const double companionPayoutPercent = 0.85; // 85% al acompañante
}
