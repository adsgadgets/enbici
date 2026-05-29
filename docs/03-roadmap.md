# Roadmap de Desarrollo — EnBici

## Resumen de Fases

| Fase | Semanas | Entregable Principal | Estado |
|------|---------|---------------------|--------|
| 0 — Legal y Compliance | 1-2 | T&C, póliza, proveedor docs | 🔴 Pendiente |
| 1 — Backend MVP | 1-6 | API REST + WebSockets + Wompi | 🔴 Pendiente |
| 2 — App Ciclista | 3-10 | 11 pantallas iOS+Android | 🔴 Pendiente |
| 3 — App Acompañante Moto | 5-12 | 10 pantallas + verificación docs | 🔴 Pendiente |
| 4 — App Conductor Auto | 7-14 | 11 pantallas + checklist seguridad | 🔴 Pendiente |
| 5 — Beta Privada | 14-20 | 300 usuarios Bogotá + Medellín | 🔴 Pendiente |
| 6 — Lanzamiento Público | 20+ | App Store + Google Play | 🔴 Pendiente |

---

## FASE 0: Legal y Compliance (Semanas 1-2, paralela al desarrollo)

**Crítico antes de cualquier lanzamiento con usuarios reales.**

### Checklist
- [ ] Consultar abogado especialista en transporte: ¿requiere habilitación Decreto 1079/2015 + Resolución 3365/2018 o el modelo de "acompañamiento" lo elude?
- [ ] Redactar Términos y Condiciones para las 3 apps (ciclista, acompañante, conductor)
- [ ] Redactar Política de Privacidad (Ley 1581/2012 — Habeas Data)
- [ ] Contratar póliza de responsabilidad civil para la plataforma (mínimo COP 50 millones — AXA Colombia / Liberty)
- [ ] Abrir cuenta empresarial: necesita SAS constituida
- [ ] Contratar proveedor verificación docs: Deqode o Semáforo Rojo (RUNT + RNEC, COP 2.000-5.000/consulta)
- [ ] Iniciar negociación con SURA para pólizas por trayecto (proceso de 2-3 meses)

### Entregable
Concepto legal escrito que defina el modelo de negocio bajo el marco regulatorio colombiano.

---

## FASE 1: Backend MVP (Semanas 1-6)

### Sprint 1 (Semanas 1-2): Fundamentos
- [ ] Setup monorepo: crear estructura de carpetas, package.json, ESLint, Prettier
- [ ] Docker Compose: PostgreSQL 15 + PostGIS + Redis 7 + pgAdmin
- [ ] Firebase Admin SDK: verificar OTP tokens del cliente
- [ ] JWT middleware: generar y validar tokens de sesión
- [ ] Modelos de base de datos: migrations para `users`, `vehicles`, `rides`
- [ ] Endpoints básicos: `POST /auth/verify-otp`, `GET /users/me`, `PUT /users/me`
- [ ] GitHub Actions CI: lint + tests en cada PR

### Sprint 2 (Semanas 3-4): Viaje
- [ ] Google Maps Directions API: calcular tiempo y distancia A→B
- [ ] Motor de tarifas: `fare.service.js` con recargos por zona y surge pricing
- [ ] Matching algorithm: `ST_DWithin` PostGIS para buscar en radio 2km
- [ ] Socket.io setup + Redis Pub/Sub: infraestructura WebSocket
- [ ] Endpoints: `POST /rides`, `PUT /rides/:id/accept`, `PUT /rides/:id/start`, `PUT /rides/:id/complete`
- [ ] WebSocket events: `location:update`, `location:broadcast`, `ride:accepted`

### Sprint 3 (Semanas 5-6): Pagos y SOS
- [ ] Wompi integration: `POST /payments/initiate`, `POST /payments/webhook`
- [ ] Tabla `transactions` con `idempotency_key`
- [ ] Bold fallback: si Wompi falla, reintentar con Bold en <5s
- [ ] SOS module: `POST /rides/:id/sos`, alerta al acompañante + soporte
- [ ] Tabla `emergency_alerts` con historial GPS (JSONB)
- [ ] Ratings: `POST /ratings` post-viaje
- [ ] Load test: 500 conexiones WebSocket simultáneas con Artillery
- [ ] Documentación API: Swagger/OpenAPI

### Criterio de éxito Fase 1
- [ ] API responde en < 200ms el 95% de las peticiones
- [ ] 500 WebSockets simultáneos sin degradación
- [ ] Pago de prueba exitoso con tarjeta de prueba Wompi
- [ ] SOS activa notificaciones en < 5 segundos

---

## FASE 2: App Ciclista (Semanas 3-10)

### 11 Pantallas a construir

| Pantalla | Semana | Prioridad |
|----------|--------|-----------|
| 1. Onboarding/Login (OTP SMS) | 3 | P0 |
| 2. Registro ciclista | 3 | P0 |
| 3. Dashboard (mapa + acompañantes) | 4 | P0 |
| 4. Solicitar servicio (tipo + ruta + precio) | 5 | P0 |
| 5. Confirmación de ruta | 5 | P0 |
| 6. Esperando acompañante (tracking real-time) | 6 | P0 |
| 7. Viaje en curso (mapa + SOS) | 6-7 | P0 |
| 8. Finalizar viaje | 7 | P1 |
| 9. Pago y rating | 8 | P0 |
| 10. Historial de viajes | 9 | P1 |
| 11. Perfil | 10 | P1 |

### Componentes críticos
- `<SOSButton>`: doble tap, 60×60px, rojo pulsante, feedback háptico
- `<CompanionMap>`: Google Maps con pin del acompañante actualizándose en tiempo real
- `<FareEstimate>`: desglose de tarifa con zona y surge
- Hook `useSocket`: gestión conexión Socket.io con reconexión automática
- Hook `useLocation`: GPS con fallback SQLite offline

### UX constraints
- Botones mínimo 48×48px (guantes)
- Dark mode por defecto
- Contraste WCAG AA mínimo (idealmente AAA)
- Fuente: Inter, mínimo 16px en textos de acción

---

## FASE 3: App Acompañante en Moto (Semanas 5-12)

### 10 Pantallas

| Pantalla | Semana | Prioridad |
|----------|--------|-----------|
| 1. Onboarding verificación (subir docs) | 5 | P0 |
| 2. Dashboard (online/offline + ganancias) | 6 | P0 |
| 3. Notificación solicitud (30s timer) | 7 | P0 |
| 4. En ruta al ciclista (navegación) | 8 | P0 |
| 5. Confirmación de llegada al punto A | 8 | P0 |
| 6. Viaje activo (track del ciclista) | 9 | P0 |
| 7. Finalizar viaje | 9 | P1 |
| 8. Perfil de herramientas | 10 | P2 |
| 9. Ganancias (historial + próximo pago) | 11 | P1 |
| 10. Estado de verificación docs | 12 | P1 |

### Componente crítico
- `<RequestCard>`: card de solicitud con timer 30s y botones Aceptar/Rechazar grandes
- Notificación push FCM: debe despertar la app incluso en background

---

## FASE 4: App Conductor de Auto Propio (Semanas 7-14)

### Diferencias vs App Moto
- Checklist inicial obligatorio (6-8 puntos con fotos)
- Verificación adicional: licencia B1/B2
- Tarifa 25% mayor que moto
- Pantalla de herramientas de soporte mecánico específica

### 11 Pantallas
Similar a App Moto + pantalla de checklist de seguridad vehicular.

---

## FASE 5: Beta Privada (Semanas 14-20)

### Objetivos
- 300 usuarios beta (ciclistas + acompañantes) en Bogotá y Medellín
- Invitación por lista de espera (formulario Google Forms)
- Soporte dedicado (WhatsApp Business + chat in-app)

### Checklist técnico
- [ ] Testing GPS en zonas rurales: Patios (Cundinamarca), La Cuchilla del Tablazo, vías Boyacá
- [ ] Simular pérdida de señal y verificar batch-sync SQLite → servidor
- [ ] Protocolo SOS simulado en campo: medir tiempo real de respuesta (meta: < 30s)
- [ ] Load test: 500 WebSockets + 100 transacciones concurrentes
- [ ] Verificar webhooks Wompi en producción (no solo sandbox)
- [ ] Test de verificación RUNT con placas reales (sandbox Deqode)
- [ ] App Store Connect + Google Play Console: apps internas/beta cerrada

### KPIs de éxito beta
- 150+ viajes completados
- Tiempo respuesta SOS < 30s en el 90% de simulaciones
- 0 fallos de pago duplicado
- Rating promedio acompañante > 4.0

---

## FASE 6: Lanzamiento Público (Semanas 20+)

### Prerrequisitos
- [ ] Aprobación App Store (iOS): tiempo estimado 7-14 días
- [ ] Aprobación Google Play: tiempo estimado 3-7 días
- [ ] Concepto legal definitivo (Fase 0)
- [ ] Póliza de responsabilidad activa
- [ ] Integración SURA por trayecto activa
- [ ] 300+ acompañantes verificados disponibles
- [ ] Equipo de soporte: 2 agentes, turnos 6AM-10PM, 7 días

### Canales de lanzamiento
- Grupos de ciclismo Bogotá/Medellín (Facebook, WhatsApp, Strava)
- Tiendas de ciclismo (flyers + QR)
- Influencers ciclistas colombianos
- PR en medios especializados

---

## Equipo Recomendado

| Rol | Dedicación | Responsabilidad |
|-----|-----------|-----------------|
| Dev Full-Stack x2 | 100% | Backend + Mobile (compartido) |
| Dev Mobile (React Native) x1 | 100% | Apps móviles |
| DevOps x1 | 50% | AWS, CI/CD, monitoreo |
| Abogado transporte | Externo | Legal y compliance |
| Agente soporte x2 | 100% | Chat + WhatsApp + SOS |

**Inversión MVP estimada:** ~$134.000 USD (6 meses, incluyendo equipo + infra + proveedores)
