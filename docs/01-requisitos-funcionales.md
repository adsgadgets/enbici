# Requisitos Funcionales — EnBici

## RF-01: Autenticación y Perfiles

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-01.1 | El sistema debe permitir registro e inicio de sesión via OTP SMS (Firebase Auth) para cualquier número celular colombiano | P0 |
| RF-01.2 | El usuario debe seleccionar su rol en el primer login: Ciclista, Acompañante en Moto, o Conductor de Auto | P0 |
| RF-01.3 | El ciclista debe poder registrar: nombre, contacto de emergencia (nombre + teléfono), EPS/Prepagada | P0 |
| RF-01.4 | El sistema debe mantener sesión activa con refresh token (30 días) sin requerir nuevo OTP | P1 |
| RF-01.5 | El usuario debe poder editar su perfil en cualquier momento | P1 |

---

## RF-02: Registro y Verificación de Acompañantes

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-02.1 | El acompañante en moto debe subir: foto cédula, licencia A2, SOAT vigente, Tecno-mecánica vigente | P0 |
| RF-02.2 | El conductor de auto debe subir: foto cédula, licencia B1 o B2 | P0 |
| RF-02.3 | El sistema debe verificar automáticamente SOAT y tecno-mecánica en RUNT por número de placa (vía Deqode o Semáforo Rojo) | P0 |
| RF-02.4 | El sistema debe consultar RNEC/DIJIN para verificar antecedentes penales | P0 |
| RF-02.5 | El sistema debe calcular un score de riesgo (0-100). Score < 50: rechazo automático. Score 50-74: revisión humana. Score ≥ 75: aprobación automática | P0 |
| RF-02.6 | El acompañante debe completar un video de entrenamiento de 3 minutos y un quiz con puntaje ≥ 80% | P1 |
| RF-02.7 | El sistema debe notificar al acompañante el resultado de su verificación en máximo 48 horas | P1 |
| RF-02.8 | El acompañante debe poder actualizar documentos vencidos sin perder el historial de calificaciones | P2 |

---

## RF-03: Solicitud y Matching de Servicio

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-03.1 | El ciclista debe poder ver en el mapa los acompañantes disponibles en un radio de 2km en tiempo real | P0 |
| RF-03.2 | El ciclista debe poder seleccionar la modalidad: Acompañante en Moto o Conductor de Auto | P0 |
| RF-03.3 | El punto A (origen) debe detectarse automáticamente por GPS. El punto B (destino) se ingresa manualmente | P0 |
| RF-03.4 | El sistema debe mostrar estimado de precio y tiempo de llegada del acompañante antes de confirmar | P0 |
| RF-03.5 | El sistema debe enviar la solicitud al acompañante más cercano disponible. Si no acepta en 30s, pasar al siguiente | P0 |
| RF-03.6 | El acompañante tiene 30 segundos para aceptar o rechazar cada solicitud | P0 |
| RF-03.7 | El ciclista debe poder cancelar la solicitud sin costo hasta que el acompañante acepte | P1 |
| RF-03.8 | El sistema debe soportar reservas programadas con hasta 7 días de anticipación | P2 |

---

## RF-04: Viaje en Curso

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-04.1 | Una vez iniciado el viaje, ambos usuarios deben ver la ubicación del otro en tiempo real (actualización cada 3 segundos) | P0 |
| RF-04.2 | El acompañante debe navegar con Google Maps turn-by-turn hacia el punto A para recoger al ciclista | P0 |
| RF-04.3 | El sistema debe registrar todos los puntos GPS del viaje en `location_stream` | P0 |
| RF-04.4 | Si se pierde la señal celular, los puntos GPS deben guardarse localmente en SQLite y sincronizarse al reconectar | P0 |
| RF-04.5 | El ciclista debe ver su velocidad actual, distancia recorrida y tiempo transcurrido durante el viaje | P1 |
| RF-04.6 | El acompañante y ciclista deben poder comunicarse por chat de texto dentro de la app durante el viaje | P1 |
| RF-04.7 | El acompañante (moto) debe poder registrar las herramientas que porta en su perfil | P2 |

---

## RF-05: Protocolo SOS

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-05.1 | El botón SOS debe estar siempre visible durante el viaje (60×60px, rojo pulsante) | P0 |
| RF-05.2 | El SOS debe requerir doble tap para activarse: primer tap abre confirmación 2s, segundo tap activa | P0 |
| RF-05.3 | Al activarse el SOS, la frecuencia de actualización GPS debe cambiar de 3s a 1s automáticamente | P0 |
| RF-05.4 | Al activarse el SOS, se debe notificar inmediatamente al acompañante y al equipo de soporte de EnBici | P0 |
| RF-05.5 | El equipo de soporte debe ver: nombre del ciclista, ubicación exacta, historial GPS de los últimos 5 minutos, contacto de emergencia, EPS | P0 |
| RF-05.6 | Si en 60s no hay respuesta del ciclista, el agente de soporte debe llamar al número de emergencias (123) con las coordenadas GPS | P0 |
| RF-05.7 | Los primeros 10 segundos post-activación el ciclista debe poder cancelar con el botón "Fue un error" | P0 |
| RF-05.8 | Más de 3 falsas alarmas en 30 días debe generar una advertencia en el perfil del ciclista | P1 |
| RF-05.9 | El audio y video de la cámara del dispositivo deben iniciarse automáticamente al activar SOS (con consentimiento previo del usuario) | P2 |

---

## RF-06: Pagos y Facturación

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-06.1 | El pago debe procesarse automáticamente al finalizar el viaje vía Wompi | P0 |
| RF-06.2 | Toda transacción debe tener un `idempotency_key` UUID único para evitar cobros duplicados | P0 |
| RF-06.3 | Si Wompi falla, el sistema debe intentar con Bold como fallback automáticamente | P0 |
| RF-06.4 | El sistema debe distribuir automáticamente: 85% al acompañante, 15% a la plataforma | P0 |
| RF-06.5 | Los acompañantes deben recibir sus pagos cada martes por transferencia bancaria (ACH) | P1 |
| RF-06.6 | El ciclista debe recibir un resumen detallado del viaje y el cobro por notificación push y email | P1 |
| RF-06.7 | El sistema debe soportar tarjeta de crédito/débito y PSE vía Wompi | P1 |
| RF-06.8 | En caso de disputa, el pago al acompañante debe quedar retenido hasta resolución (máximo 5 días hábiles) | P2 |

---

## RF-07: Calificaciones y Reputación

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-07.1 | Al finalizar el viaje, ambos usuarios deben poder calificar al otro con 1 a 5 estrellas y comentario opcional | P0 |
| RF-07.2 | El rating promedio del acompañante debe ser visible para el ciclista antes de confirmar la solicitud | P1 |
| RF-07.3 | Un acompañante con rating < 3.5 en los últimos 20 viajes debe quedar en revisión automática | P1 |
| RF-07.4 | El historial de calificaciones recibidas debe ser visible para el propio usuario | P2 |

---

## RF-08: Historial y Reportes

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF-08.1 | El ciclista debe poder ver su historial de viajes con: fecha, ruta, acompañante, costo total | P1 |
| RF-08.2 | El acompañante debe ver su historial de ganancias: por viaje, semanal, mensual | P1 |
| RF-08.3 | El acompañante debe ver sus estadísticas: viajes completados, rating promedio, tasa de aceptación | P2 |

---

## Prioridades de Implementación

- **P0:** Bloqueante — MVP no funciona sin esto
- **P1:** Importante — debe estar en el primer lanzamiento público
- **P2:** Deseable — puede ir en V1.1 o V2

**Total requisitos P0:** 24 | **P1:** 14 | **P2:** 7
