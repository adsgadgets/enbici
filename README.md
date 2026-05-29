# EnBici 🚴‍♂️

**Plataforma de acompañamiento de seguridad para ciclistas en Colombia**

EnBici conecta ciclistas con acompañantes de confianza en tiempo real — ya sea un piloto experto en moto que los sigue por rutas de montaña, o un conductor que lleva su vehículo mientras ellos pedalean. Pensado para Colombia, diseñado para el ciclismo de verdad.

---

## El problema que resolvemos

Las rutas de montaña colombianas son hermosas pero peligrosas. Un pinchazo en el páramo, una caída en zona sin señal, un accidente sin nadie cerca. EnBici es la capa de seguridad que le faltaba al ciclismo colombiano.

---

## Stack Tecnológico

| Capa | Tecnología | Por qué |
|------|------------|---------|
| Mobile | React Native + Expo | iOS + Android con un solo código |
| Backend | Node.js + Express.js | Rápido para MVP, Socket.io nativo |
| Base de datos | PostgreSQL 15 + PostGIS | Geoqueries optimizadas, transacciones ACID |
| Real-time | Socket.io + Redis Pub/Sub | Latencia rural ~250ms (vs 800ms Firebase RTDB) |
| Autenticación | Firebase Auth (OTP SMS) | Verificación telefónica nativa Colombia |
| Mapas | Google Maps API | Mejor cobertura en zonas rurales colombianas |
| Pagos | Wompi (principal) + Bold (fallback) | Nativos Colombia, comisión 2.4% |
| Almacenamiento | AWS S3 + CloudFront | Fotos y videos de entrenamientos |
| Infraestructura | AWS sa-east-1 (São Paulo) | LATAM, acepta COP |

---

## Modalidades de Servicio

### 🏍️ Acompañante en Moto
Un piloto certificado (licencia A2) te sigue durante toda la ruta. Porta herramientas básicas (bomba, parches, extractor). Ideal para rutas largas o zonas de riesgo.

### 🚗 Conductor de Auto Propio
Conduce tu propio vehículo con tu bicicleta a bordo mientras tú pedaleas. Reporta incidentes, gestiona paradas de avituallamiento. Ideal para competencias y rutas de entrenamiento.

---

## Estructura del Proyecto

```
enbici/
├── backend/                    # API Node.js + Express.js
│   ├── src/
│   │   ├── auth/               # JWT + Firebase Auth
│   │   ├── users/              # Perfiles ciclista/acompañante/conductor
│   │   ├── rides/              # Solicitudes, matching, estados
│   │   ├── tracking/           # WebSocket, GPS streaming
│   │   ├── payments/           # Wompi, Bold, webhooks
│   │   ├── vehicles/           # Motos, autos, documentos
│   │   ├── ratings/            # Reviews post-viaje
│   │   ├── sos/                # Botón emergencia, protocolo
│   │   └── shared/             # Utils, constantes, tipos
│   ├── socket/                 # Socket.io event handlers
│   ├── middleware/              # Auth, rate limiting, logging
│   ├── db/
│   │   ├── migrations/         # Knex migrations (nunca modificar las existentes)
│   │   └── seeds/              # Datos de prueba
│   └── tests/                  # Jest + Supertest
│
├── mobile/                     # React Native + Expo
│   └── src/
│       ├── screens/
│       │   ├── cyclist/        # 11 pantallas del ciclista
│       │   ├── companion/      # 10 pantallas del acompañante en moto
│       │   └── driver/         # 11 pantallas del conductor de auto
│       ├── components/         # Componentes reutilizables
│       ├── navigation/         # React Navigation stacks
│       ├── hooks/              # Custom hooks (useLocation, useSocket, etc.)
│       ├── services/           # API client, Firebase, Google Maps
│       ├── store/              # Zustand stores
│       └── assets/             # Imágenes, fuentes, íconos
│
├── docs/                       # Documentación del proyecto
│   ├── 00-vision-del-producto.md
│   ├── 01-requisitos-funcionales.md
│   ├── 02-arquitectura.md
│   ├── 03-roadmap.md
│   └── 04-marca-blanca.md
│
├── tasks/                      # Backlog y gestión de tareas
│   ├── backlog.md
│   └── bugs.md
│
├── decisions/                  # Architecture Decision Records (ADRs)
│   └── 001-estructura-inicial.md
│
├── infra/                      # Infraestructura
│   ├── docker/
│   │   └── docker-compose.yml  # Dev local: PostgreSQL + Redis + pgAdmin
│   └── aws/                    # Terraform / configs AWS (sa-east-1)
│
├── prompts/                    # Prompts para trabajo con IA
├── scripts/                    # Scripts de utilidad
├── AI_INSTRUCTIONS.md          # Reglas críticas para desarrollo con IA
├── .env.example                # Variables de entorno documentadas
└── CHANGELOG.md
```

---

## Inicio Rápido (Desarrollo Local)

### Prerrequisitos
- Node.js 20+
- Docker + Docker Compose
- Git

### 1. Clonar y configurar
```bash
git clone https://github.com/adsgadgets/enbici.git
cd enbici
cp .env.example .env
# Editar .env con tus credenciales reales
```

### 2. Levantar servicios de base de datos
```bash
cd infra/docker
docker compose up -d
# PostgreSQL 15 + PostGIS en localhost:5432
# Redis 7 en localhost:6379
# pgAdmin en localhost:5050
```

### 3. Instalar y migrar backend
```bash
cd backend
npm install
npm run migrate   # Crea tablas y extensión PostGIS
npm run seed      # Datos de prueba (opcional)
npm run dev       # Puerto 3000
```

### 4. Iniciar app móvil
```bash
cd mobile
npm install
npx expo start
# Escanear QR con Expo Go (Android/iOS)
```

---

## Modelo de Negocio

- **Tarifa base:** COP 15.000 + COP 500/min
- **Recargo rural:** +30% | Periférico: +20%
- **Comisión plataforma:** 15% (acompañante recibe 85%)
- **Ventaja vs competencia:** Uber cobra 25% — nosotros 15% para atraer mejores acompañantes

---

## KPIs Target (Mes 4 post-lanzamiento)

| Métrica | Meta |
|---------|------|
| Ciclistas activos diarios | 500 |
| Acompañantes disponibles | 300-400 |
| Tiempo de respuesta a solicitud | < 60 segundos |
| Rating promedio acompañante | 4.6 / 5.0 |
| Tiempo respuesta SOS | < 30 segundos |

---

## Documentación

- [Visión del Producto](docs/00-vision-del-producto.md)
- [Requisitos Funcionales](docs/01-requisitos-funcionales.md)
- [Arquitectura Técnica](docs/02-arquitectura.md)
- [Roadmap](docs/03-roadmap.md)
- [Backlog](tasks/backlog.md)
- [Reglas para IA](AI_INSTRUCTIONS.md)

---

## Contacto

**AdsGadgets** — lalagartija54@gmail.com

Hecho con amor por ciclistas, para ciclistas. 🇨🇴
