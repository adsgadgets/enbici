# Instrucciones para Desarrollo con IA — EnBici

Este documento define las convenciones, restricciones y contexto crítico que cualquier agente de IA debe conocer antes de trabajar en este repositorio.

---

## Contexto del Proyecto

EnBici es una plataforma móvil tipo "Uber" para ciclistas en Colombia. Conecta ciclistas con acompañantes de seguridad (piloto en moto o conductor de auto) en tiempo real o con reserva previa.

**Tres tipos de usuarios:**
1. **Ciclista** — quien solicita el servicio
2. **Acompañante en Moto** — piloto certificado (licencia A2) que sigue al ciclista
3. **Conductor de Auto Propio** — conduce el vehículo del ciclista mientras él pedalea

**País:** Colombia. Moneda: COP. Idioma: Español colombiano.

---

## Reglas Críticas (Nunca Violar)

### 1. Migraciones de Base de Datos
- **NUNCA modificar una migración existente** en `backend/db/migrations/`
- Si necesitas cambiar el esquema, SIEMPRE crear una nueva migración
- Las migraciones son inmutables una vez commiteadas
- Usar Knex.js para todas las migraciones

### 2. Idempotencia en Pagos
- **TODA transacción con Wompi o Bold debe incluir un `idempotency_key` UUID**
- El `idempotency_key` se genera en el servidor, no en el cliente
- Si un webhook llega dos veces, el sistema debe procesarlo una sola vez
- Tabla: `transactions.idempotency_key` (UNIQUE)

### 3. Datos GPS y Privacidad
- Los puntos de `location_stream` deben **anonimizarse después de 90 días** (borrar user_id, redondear coordenadas a 3 decimales)
- NUNCA almacenar coordenadas GPS exactas más de 90 días (Ley 1581/2012 Colombia)
- Los datos de `emergency_alerts` tienen retención de 2 años (requisito legal)

### 4. Botón SOS
- El SOS requiere **doble tap** para activarse (anti-activación accidental)
- Primero tap: muestra anillo de confirmación de 2 segundos
- Segundo tap dentro de los 2s: activa SOS
- Alternativa: long-press de 2 segundos
- **Nunca simplificar a un solo tap**
- Los primeros 10 segundos hay opción "Fue un error" para cancelar

### 5. WebSockets y Tracking
- Frecuencia GPS normal: cada **3 segundos**
- Frecuencia GPS durante SOS activo: cada **1 segundo**
- Si se pierde señal: guardar puntos en SQLite local y sincronizar en batch al reconectar
- NUNCA perder puntos GPS durante el viaje — son evidencia en caso de incidente

### 6. Verificación de Documentos
- NUNCA aprobar un acompañante/conductor sin verificación RUNT (SOAT + tecno-mecánica vigente)
- Score de riesgo mínimo para aprobación: 50/100
- Si score < 75: requiere revisión humana antes de aprobar
- Proveedor actual: Deqode (ver `DEQODE_API_KEY` en `.env`)

---

## Convenciones de Código

### Backend (Node.js + Express)
- **Lenguaje:** JavaScript (ES2022+), no TypeScript en MVP
- **Linting:** ESLint + Prettier (config en `.eslintrc.js`)
- **Estilo:** camelCase para variables/funciones, PascalCase para clases
- **Errores:** Siempre usar el middleware centralizado de errores (`middleware/errorHandler.js`)
- **Logs:** Winston logger, no `console.log` en producción
- **Tests:** Jest + Supertest, cobertura mínima 60% en módulos de pagos y SOS

### Mobile (Flutter + Dart)
- **Gestor de estado:** Riverpod (no BLoC, no Provider simple)
- **Navegación:** GoRouter v14+
- **Tema:** `AppTheme.darkTheme` en `lib/core/theme/app_theme.dart` — dark mode por defecto
- **Tamaño mínimo de botones táctiles:** 48×48px (`AppSizes.tapTargetMin`) — uso con guantes
- **Botón SOS:** usar SIEMPRE el widget `SOSButton` de `lib/shared/widgets/sos_button.dart`
- **Fuente:** Inter (definida en `pubspec.yaml` como asset)
- **GPS background:** usar `flutter_background_geolocation`, NO geolocator solo (no funciona en background en iOS)
- **GPS offline:** guardar en SQLite con `sqflite`, tabla `gps_queue`, sync con `POST /tracking/batch-sync`
- **idempotency_key:** generar con el paquete `uuid` (`const Uuid().v4()`) ANTES de llamar a la API de pagos

### Convenciones de Commits
```
tipo(alcance): descripción corta en minúsculas

Tipos: feat, fix, chore, docs, test, refactor, style, perf
Ejemplos:
  feat(rides): agregar algoritmo de matching por radio PostGIS
  fix(payments): corregir webhook duplicado con idempotency_key
  chore(infra): actualizar docker-compose con healthchecks
```

---

## Arquitectura Rápida

```
Cliente móvil (Flutter — compilado nativo ARM)
    ↓ HTTPS + WebSocket
API Gateway / Load Balancer (AWS ALB)
    ↓
Node.js + Express (EC2 sa-east-1)
    ├── REST API (rides, users, payments)
    ├── Socket.io (GPS tracking real-time)
    │   └── Redis Pub/Sub (escala horizontal)
    ├── PostgreSQL + PostGIS (RDS)
    │   ├── ST_DWithin → matching por radio 2km
    │   └── location_stream → particionada por día
    └── Firebase Auth (OTP SMS)
```

---

## Tarifas y Lógica de Negocio

```javascript
// Motor de tarifas
const calcularTarifa = (duracionMin, zona, hora) => {
  const BASE = 15000; // COP
  const POR_MINUTO = 500; // COP/min
  
  const recargos = {
    urbano: 1.0,
    periferico: 1.2,
    rural: 1.3
  };
  
  const surgePricing = {
    normal: 1.0,
    horaPico: 1.5,    // 7-9am, 5-7pm
    finde: 1.2,
    nocturno: 1.8     // 10pm-5am
  };
  
  const tarifa = (BASE + (POR_MINUTO * duracionMin)) 
                  * recargos[zona] 
                  * surgePricing[hora];
  
  return Math.round(tarifa / 100) * 100; // Redondear a COP 100
};

// Distribución del pago
// Acompañante: 85%
// Plataforma: 15% (comisión bruta)
// Wompi: ~3% del total
// Ganancia neta plataforma: ~9.5%
```

---

## Endpoints Principales (Referencia)

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/v1/auth/verify-otp` | Verificar código SMS Firebase |
| GET | `/api/v1/companions/nearby` | Acompañantes en radio 2km (PostGIS) |
| POST | `/api/v1/rides` | Crear solicitud de viaje |
| PUT | `/api/v1/rides/:id/accept` | Acompañante acepta solicitud |
| PUT | `/api/v1/rides/:id/start` | Iniciar viaje |
| PUT | `/api/v1/rides/:id/complete` | Finalizar viaje |
| POST | `/api/v1/rides/:id/sos` | Activar protocolo SOS |
| POST | `/api/v1/payments/initiate` | Iniciar pago Wompi |
| POST | `/api/v1/payments/webhook` | Webhook confirmación Wompi |
| POST | `/api/v1/ratings` | Calificar post-viaje |

---

## Eventos Socket.io

| Evento | Dirección | Descripción |
|--------|-----------|-------------|
| `location:update` | Cliente → Server | GPS del acompañante/conductor |
| `location:broadcast` | Server → Cliente | GPS al ciclista |
| `ride:accepted` | Server → Ciclista | Acompañante aceptó la solicitud |
| `ride:companion_arrived` | Server → Ciclista | Acompañante llegó al punto A |
| `sos:activated` | Ciclista → Server | Activar protocolo SOS |
| `sos:alert` | Server → Todos | Alerta SOS a acompañante + soporte |

---

## Notas Legales Colombia

- **Decreto 1079/2015:** Definir con abogado si el modelo es "transporte" o "acompañamiento" (cambia requisitos de habilitación)
- **Ley 1581/2012 (Habeas Data):** GPS anonimizado después de 90 días, Política de Privacidad obligatoria
- **RUNT:** Verificación de SOAT, tecno-mecánica y licencias por placa/cédula
- **SURA:** Pólizas por trayecto (en negociación, 2-3 meses para activar)
- **Código:** COP como moneda, zona horaria `America/Bogota` (UTC-5)

---

## Para Comenzar a Trabajar

1. Leer `docs/02-arquitectura.md` para entender el sistema completo
2. Revisar `tasks/backlog.md` para las historias de usuario priorizadas
3. Revisar el ADR en `decisions/001-estructura-inicial.md`
4. Nunca modificar migraciones existentes
5. Todo cambio de pagos debe incluir `idempotency_key`
