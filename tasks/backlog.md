# Backlog de Historias de Usuario — EnBici

Formato: `[ID] Como [rol] quiero [acción] para [beneficio]`
Puntos: Fibonacci (1, 2, 3, 5, 8, 13)
Prioridad: P0 (bloqueante), P1 (primer lanzamiento), P2 (V1.1)

---

## ÉPICA 1: Autenticación y Perfiles

| ID | Historia | Puntos | Prioridad | Estado |
|----|---------|--------|-----------|--------|
| US-001 | Como **usuario nuevo**, quiero registrarme con mi número de celular colombiano y un código SMS, para no necesitar email ni contraseña | 5 | P0 | ☐ |
| US-002 | Como **usuario**, quiero seleccionar mi rol (ciclista, moto, conductor) en el primer ingreso, para ver la app correcta desde el inicio | 3 | P0 | ☐ |
| US-003 | Como **ciclista**, quiero registrar el contacto de emergencia (nombre + teléfono) y mi EPS, para que el equipo de soporte lo tenga en caso de accidente | 3 | P0 | ☐ |
| US-004 | Como **usuario**, quiero que la app me mantenga logueado por 30 días sin pedir código SMS de nuevo, para no tener que autenticarme constantemente | 2 | P1 | ☐ |

**Subtotal Épica 1:** 13 puntos

---

## ÉPICA 2: Verificación de Acompañantes

| ID | Historia | Puntos | Prioridad | Estado |
|----|---------|--------|-----------|--------|
| US-005 | Como **acompañante en moto**, quiero subir fotos de mi cédula, licencia A2, SOAT y tecno-mecánica, para iniciar el proceso de verificación | 5 | P0 | ☐ |
| US-006 | Como **plataforma**, quiero verificar automáticamente SOAT y tecno-mecánica en RUNT por placa, para garantizar que el vehículo está al día | 8 | P0 | ☐ |
| US-007 | Como **plataforma**, quiero consultar antecedentes penales (RNEC/DIJIN) de cada candidato, para proteger a los ciclistas | 8 | P0 | ☐ |
| US-008 | Como **acompañante**, quiero saber el resultado de mi verificación en máximo 48 horas, para poder comenzar a trabajar pronto | 3 | P1 | ☐ |
| US-009 | Como **acompañante**, quiero completar el video de entrenamiento y el quiz, para demostrar que conozco los protocolos de servicio | 5 | P1 | ☐ |

**Subtotal Épica 2:** 29 puntos

---

## ÉPICA 3: Solicitud y Matching

| ID | Historia | Puntos | Prioridad | Estado |
|----|---------|--------|-----------|--------|
| US-010 | Como **ciclista**, quiero ver en el mapa cuántos acompañantes hay disponibles cerca de mi ubicación, para saber si el servicio está disponible | 5 | P0 | ☐ |
| US-011 | Como **ciclista**, quiero seleccionar el tipo de acompañamiento (moto o conductor de auto), para elegir el servicio que necesito | 3 | P0 | ☐ |
| US-012 | Como **ciclista**, quiero que la app detecte automáticamente mi punto de inicio por GPS y yo ingrese el destino, para agilizar la solicitud | 3 | P0 | ☐ |
| US-013 | Como **ciclista**, quiero ver el estimado de precio y tiempo antes de confirmar, para decidir si el servicio me conviene | 5 | P0 | ☐ |
| US-014 | Como **acompañante**, quiero recibir notificaciones de solicitudes cercanas con un timer de 30 segundos, para poder aceptar o rechazar a tiempo | 8 | P0 | ☐ |
| US-015 | Como **ciclista**, quiero poder cancelar gratis hasta que el acompañante acepte, para cambiar de opinión sin costo | 2 | P1 | ☐ |

**Subtotal Épica 3:** 26 puntos

---

## ÉPICA 4: Viaje en Curso

| ID | Historia | Puntos | Prioridad | Estado |
|----|---------|--------|-----------|--------|
| US-016 | Como **ciclista**, quiero ver en el mapa dónde está mi acompañante en tiempo real, para saber cuándo llega | 8 | P0 | ☐ |
| US-017 | Como **acompañante**, quiero tener navegación turn-by-turn (Google Maps) hacia el ciclista, para llegar sin perderme | 5 | P0 | ☐ |
| US-018 | Como **ciclista**, quiero que la app registre todos los puntos GPS del viaje aunque pierda señal en la montaña, para tener un historial completo | 8 | P0 | ☐ |
| US-019 | Como **ciclista**, quiero ver mi velocidad, distancia y tiempo durante el viaje, para monitorear mi entrenamiento | 3 | P1 | ☐ |
| US-020 | Como **ciclista** o **acompañante**, quiero poder chatear por texto dentro de la app durante el viaje, para coordinar sin llamar | 5 | P1 | ☐ |

**Subtotal Épica 4:** 29 puntos

---

## ÉPICA 5: Protocolo SOS

| ID | Historia | Puntos | Prioridad | Estado |
|----|---------|--------|-----------|--------|
| US-021 | Como **ciclista**, quiero un botón SOS grande y visible durante todo el viaje, para poder pedir ayuda rápidamente si me accidento | 3 | P0 | ☐ |
| US-022 | Como **ciclista**, quiero que el SOS requiera doble tap para activarse, para no activarlo accidentalmente con un golpe | 5 | P0 | ☐ |
| US-023 | Como **equipo de soporte**, quiero recibir una alerta inmediata con la ubicación GPS exacta del ciclista y su historial de los últimos 5 minutos, para poder coordinar la respuesta de emergencia | 8 | P0 | ☐ |
| US-024 | Como **ciclista**, quiero poder cancelar el SOS en los primeros 10 segundos con "Fue un error", para evitar falsas alarmas | 3 | P0 | ☐ |

**Subtotal Épica 5:** 19 puntos

---

## ÉPICA 6: Pagos y Calificaciones

| ID | Historia | Puntos | Prioridad | Estado |
|----|---------|--------|-----------|--------|
| US-025 | Como **ciclista**, quiero que el pago se procese automáticamente al finalizar el viaje sin que tenga que hacer nada, para una experiencia sin fricción | 8 | P0 | ☐ |
| US-026 | Como **acompañante**, quiero poder calificar al ciclista y el ciclista calificarme a mí con 1-5 estrellas al terminar, para construir reputación mutua | 3 | P0 | ☐ |

**Subtotal Épica 6:** 11 puntos

---

## Resumen del Backlog

| Épica | Historias | Puntos | % del total |
|-------|-----------|--------|-------------|
| Autenticación y Perfiles | 4 | 13 | 10% |
| Verificación Acompañantes | 5 | 29 | 23% |
| Solicitud y Matching | 6 | 26 | 21% |
| Viaje en Curso | 5 | 29 | 23% |
| Protocolo SOS | 4 | 19 | 15% |
| Pagos y Calificaciones | 2 | 11 | 9% |
| **TOTAL** | **26** | **127** | **100%** |

**A 2 puntos/día (equipo de 3 devs):** ~64 días laborables = ~13 semanas para el MVP completo.

---

## Criterios de Aceptación Clave

### US-022 (SOS doble tap)
- [ ] Primer tap: aparece anillo de confirmación durante 2 segundos
- [ ] Segundo tap dentro de los 2s: SOS se activa
- [ ] Si pasan 2s sin segundo tap: el anillo desaparece, sin activación
- [ ] Alternativa: long-press de 2 segundos activa el SOS directamente
- [ ] Feedback háptico: vibración larga repetida cuando SOS está activo

### US-018 (GPS offline)
- [ ] Si el dispositivo pierde señal, continúa guardando puntos GPS en SQLite local
- [ ] Al reconectar, envía los puntos almacenados en batch (`POST /tracking/batch-sync`)
- [ ] Los puntos se insertan con el `recorded_at` original (no el momento de sync)
- [ ] La capacidad del buffer SQLite es de mínimo 500 puntos (≈25 minutos sin señal a 3s/punto)
