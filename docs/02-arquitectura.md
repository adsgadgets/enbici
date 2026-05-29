# Arquitectura Técnica — EnBici

## Diagrama General

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENTES MÓVILES                         │
│                                                             │
│  [App Ciclista]   [App Acompañante Moto]   [App Conductor]  │
│  Flutter (Dart) — compilado nativo ARM iOS + Android        │
│  - google_maps_flutter      - flutter_background_geolocation│
│  - firebase_auth (OTP)      - socket_io_client              │
│  - sqflite (queue offline)  - Riverpod (estado)             │
│  - go_router (navegación)   - vibration (háptico SOS)       │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS (443) + WSS (443)
                           │
┌──────────────────────────▼──────────────────────────────────┐
│              AWS sa-east-1 (São Paulo)                      │
│                                                             │
│  ┌─────────────────────────────────────┐                    │
│  │   Application Load Balancer (ALB)   │                    │
│  │   Termina TLS + health checks       │                    │
│  └───────────────┬─────────────────────┘                    │
│                  │                                           │
│  ┌───────────────▼─────────────────────┐                    │
│  │   EC2 t3.medium (Auto Scaling)      │                    │
│  │   Node.js + Express.js              │                    │
│  │   ├── /api/v1 (REST)                │                    │
│  │   │   ├── auth/                     │                    │
│  │   │   ├── users/                    │                    │
│  │   │   ├── rides/                    │                    │
│  │   │   ├── payments/                 │                    │
│  │   │   ├── vehicles/                 │                    │
│  │   │   ├── ratings/                  │                    │
│  │   │   └── sos/                      │                    │
│  │   └── Socket.io Server (WSS)        │                    │
│  │       ├── location:update           │                    │
│  │       ├── ride:accepted             │                    │
│  │       └── sos:activated             │                    │
│  └───────┬───────────────┬─────────────┘                    │
│          │               │                                   │
│  ┌───────▼──────┐ ┌──────▼────────┐                         │
│  │ PostgreSQL 15│ │ Redis 7       │                         │
│  │ + PostGIS    │ │ Pub/Sub       │                         │
│  │ RDS db.t3    │ │ ElastiCache   │                         │
│  │ Multi-AZ     │ │               │                         │
│  └──────────────┘ └───────────────┘                         │
│                                                             │
│  ┌──────────────────────────┐                               │
│  │ S3 + CloudFront          │                               │
│  │ Fotos/videos de viajes   │                               │
│  └──────────────────────────┘                               │
└─────────────────────────────────────────────────────────────┘
         │                           │
┌────────▼─────────┐    ┌────────────▼────────┐
│  Firebase Auth   │    │  Servicios externos  │
│  (OTP SMS)       │    │  - Wompi (pagos)     │
│  Gratis 10k MAU  │    │  - Bold (fallback)   │
└──────────────────┘    │  - Deqode (RUNT)     │
                        │  - SURA (seguro)     │
                        │  - FCM (push notif)  │
                        └──────────────────────┘
```

---

## Flujo GPS en Tiempo Real

```
Acompañante/Conductor (móvil)
    │ location:update {lat, lng, speed, accuracy, rideId}
    │ cada 3s (normal) | cada 1s (SOS activo)
    ▼
Socket.io Server (Node.js)
    │ Redis PUBLISH → canal: ride:{rideId}:location
    ▼
Redis Pub/Sub
    │ Redis SUBSCRIBE ← todos los servidores Node.js
    ▼
Socket.io Server (otro nodo si hay escalado horizontal)
    │ location:broadcast {lat, lng, speed, timestamp}
    ▼
Ciclista (móvil) → pinta el pin del acompañante en Google Maps

[Si hay pérdida de señal]
    Móvil → SQLite queue local (hasta 500 puntos)
    Al reconectar → POST /api/v1/tracking/batch-sync
    Servidor → inserta en location_stream con timestamp original
```

---

## Esquema de Base de Datos

### Tabla: users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('cyclist','motorcyclist','driver')),
  verification_status VARCHAR(20) DEFAULT 'pending'
    CHECK (verification_status IN ('pending','approved','rejected','suspended')),
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),
  eps_name VARCHAR(100),
  rating DECIMAL(3,2) DEFAULT 5.00,
  total_rides INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: vehicles
```sql
CREATE TABLE vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  plate VARCHAR(10) NOT NULL,
  type VARCHAR(20) NOT NULL CHECK (type IN ('motorcycle','car')),
  brand VARCHAR(50),
  model VARCHAR(50),
  year INTEGER,
  soat_expiry DATE NOT NULL,
  techno_expiry DATE NOT NULL,  -- tecno-mecánica
  current_location GEOGRAPHY(POINT, 4326),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vehicles_location ON vehicles USING GIST(current_location);
```

### Tabla: rides
```sql
CREATE TABLE rides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cyclist_id UUID REFERENCES users(id),
  companion_id UUID REFERENCES users(id),
  service_type VARCHAR(20) CHECK (service_type IN ('motorcycle','car_driver')),
  origin GEOGRAPHY(POINT, 4326) NOT NULL,
  destination GEOGRAPHY(POINT, 4326),
  origin_address TEXT,
  destination_address TEXT,
  status VARCHAR(20) DEFAULT 'pending'
    CHECK (status IN ('pending','accepted','companion_en_route','in_progress','completed','cancelled')),
  fare_cop INTEGER,                       -- tarifa en COP
  duration_minutes INTEGER,
  distance_km DECIMAL(8,2),
  zone VARCHAR(20) CHECK (zone IN ('urban','peripheral','rural')),
  surge_multiplier DECIMAL(3,2) DEFAULT 1.0,
  scheduled_at TIMESTAMPTZ,              -- NULL = inmediato
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancel_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rides_cyclist ON rides(cyclist_id);
CREATE INDEX idx_rides_companion ON rides(companion_id);
CREATE INDEX idx_rides_status ON rides(status);
```

### Tabla: location_stream
```sql
CREATE TABLE location_stream (
  id BIGSERIAL,
  ride_id UUID REFERENCES rides(id),
  user_id UUID REFERENCES users(id),
  location GEOGRAPHY(POINT, 4326) NOT NULL,
  speed_kmh DECIMAL(5,2),
  accuracy_m DECIMAL(6,2),
  is_sos_active BOOLEAN DEFAULT false,
  recorded_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (id, recorded_at)
) PARTITION BY RANGE (recorded_at);
-- Crear particiones mensuales: 2026_05, 2026_06, etc.
-- Script: scripts/create-location-partitions.sh
-- Anonimizar después de 90 días: borrar user_id, redondear coordenadas a 3 decimales
```

### Tabla: transactions
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id UUID REFERENCES rides(id),
  amount_cop INTEGER NOT NULL,
  platform_fee_cop INTEGER NOT NULL,      -- 15% de amount_cop
  companion_payout_cop INTEGER NOT NULL,  -- 85% de amount_cop
  payment_method VARCHAR(20) CHECK (payment_method IN ('wompi','bold')),
  provider_tx_id VARCHAR(100),            -- ID de Wompi o Bold
  idempotency_key UUID UNIQUE NOT NULL,   -- CRÍTICO: evita cobros dobles
  status VARCHAR(20) DEFAULT 'pending'
    CHECK (status IN ('pending','processing','completed','failed','refunded')),
  wompi_status VARCHAR(50),               -- Estado nativo de Wompi
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: ratings
```sql
CREATE TABLE ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id UUID REFERENCES rides(id),
  rater_id UUID REFERENCES users(id),
  ratee_id UUID REFERENCES users(id),
  score SMALLINT CHECK (score BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(ride_id, rater_id)
);
```

### Tabla: emergency_alerts
```sql
CREATE TABLE emergency_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id UUID REFERENCES rides(id),
  user_id UUID REFERENCES users(id),
  alert_type VARCHAR(30) CHECK (alert_type IN ('sos','accident','harassment','false_alarm')),
  location GEOGRAPHY(POINT, 4326),
  gps_history JSONB,                      -- Últimos 5 min de puntos GPS
  support_agent_id UUID,
  resolution_notes TEXT,
  status VARCHAR(20) DEFAULT 'open'
    CHECK (status IN ('open','in_progress','resolved','false_alarm')),
  opened_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
  -- Retención: 2 años (requisito legal Colombia)
);
```

---

## Algoritmo de Matching (PostGIS)

```sql
-- Buscar acompañantes disponibles en radio de 2km
SELECT
  u.id,
  u.name,
  u.rating,
  v.plate,
  v.brand,
  v.model,
  ST_Distance(v.current_location, ST_MakePoint($lon, $lat)::GEOGRAPHY) AS distance_meters
FROM users u
JOIN vehicles v ON v.user_id = u.id
WHERE
  u.role = $service_type              -- 'motorcyclist' o 'driver'
  AND u.verification_status = 'approved'
  AND ST_DWithin(
    v.current_location,
    ST_MakePoint($lon, $lat)::GEOGRAPHY,
    2000                              -- 2000 metros = 2km
  )
  AND u.id NOT IN (
    SELECT companion_id FROM rides
    WHERE status IN ('accepted', 'companion_en_route', 'in_progress')
  )
ORDER BY distance_meters ASC, u.rating DESC
LIMIT 10;
```

---

## Motor de Cálculo de Tarifas

```javascript
// backend/src/rides/fare.service.js

const TARIFA_BASE_COP = 15000;
const POR_MINUTO_COP = 500;

const RECARGOS_ZONA = {
  urban: 1.0,
  peripheral: 1.2,
  rural: 1.3,
};

const SURGE_PRICING = {
  normal: 1.0,
  peak: 1.5,    // 7-9am, 5-7pm lunes-viernes
  weekend: 1.2, // sábado y domingo
  night: 1.8,   // 10pm-5am
};

function calcularTarifa(duracionMin, zona, horaLocal) {
  const recargo = RECARGOS_ZONA[zona] ?? 1.0;
  const surge = getSurgePricing(horaLocal);

  const tarifaBruta = (TARIFA_BASE_COP + POR_MINUTO_COP * duracionMin)
                      * recargo
                      * surge;

  // Redondear a COP 100 más cercanos
  return Math.round(tarifaBruta / 100) * 100;
}

function getSurgePricing(horaLocal) {
  const hora = horaLocal.getHours();
  const diaSemana = horaLocal.getDay(); // 0=Dom, 6=Sáb

  if (diaSemana === 0 || diaSemana === 6) return SURGE_PRICING.weekend;
  if (hora >= 22 || hora < 5) return SURGE_PRICING.night;
  if ((hora >= 7 && hora < 9) || (hora >= 17 && hora < 19)) return SURGE_PRICING.peak;

  return SURGE_PRICING.normal;
}
```

---

## Decisiones Arquitectónicas

Ver carpeta `decisions/` para los ADRs completos.

### Flutter vs React Native
Flutter compila a código nativo ARM (no JS bridge), lo que da 60fps consistentes durante el tracking GPS en el mapa. El paquete `flutter_background_geolocation` maneja correctamente el GPS en background en iOS (donde React Native requiere configuración manual compleja). El SDK `google_maps_flutter` es el oficial de Google. Dart tipado estáticamente reduce errores en producción. Estado con Riverpod es más predecible que hooks de React para un equipo no-JS.

### Monolito modular → Microservicios
El MVP usa un monolito modular. Cada módulo (`auth`, `rides`, `payments`, etc.) tiene su propia carpeta con routes, controllers y services. Si el volumen lo requiere, cada módulo puede extraerse como microservicio independiente sin refactor masivo.

### WebSockets vs Firebase RTDB
Firebase RTDB tiene latencia de 800ms en zonas rurales colombianas (pruebas con 3G/2G). Socket.io + Redis Pub/Sub logra ~250ms. Para tracking GPS en tiempo real, esto es crítico.

### PostgreSQL + PostGIS vs MongoDB
PostGIS permite `ST_DWithin` para búsquedas geoespaciales eficientes con índices GIST. Las transacciones ACID de PostgreSQL son críticas para los pagos. MongoDB fue descartado.

### Wompi vs Stripe vs PayU
Wompi tiene latencia 1-2s, comisión 2.4%, y SDKs oficiales mantenidos. Acepta PSE, tarjetas y nequi. PayU tiene latencia 4-8s. Stripe no tiene adquirencia local Colombia.

---

## Infraestructura AWS sa-east-1

### MVP (mes 1-4) — ~COP 450.000/mes
- 1x EC2 t3.micro (Node.js + Socket.io)
- 1x RDS PostgreSQL db.t3.micro (20GB SSD)
- 1x ElastiCache Redis cache.t3.micro
- S3 Standard (fotos/videos) + CloudFront

### Escala V1 (mes 5+) — ~COP 870.000/mes
- ALB + 2x EC2 t3.medium (Auto Scaling Group, min 2, max 6)
- RDS db.t3.small Multi-AZ (failover automático)
- Redis Cluster con Redis Adapter para WebSockets horizontales
