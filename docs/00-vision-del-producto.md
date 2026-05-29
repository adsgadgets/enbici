# Visión del Producto — EnBici

## El Problema

Colombia tiene más de 1.2 millones de ciclistas activos. Las rutas de montaña —páramos de Cundinamarca, Boyacá, Antioquia— son algunas de las más espectaculares del mundo. También son algunas de las más peligrosas.

**El ciclista colombiano enfrenta:**
- Pinchazos y averías mecánicas en zonas sin señal celular
- Caídas en carreteras sin acceso a auxilio inmediato
- Rutas sin soporte logístico de alimentación y agua
- Vehículos propios sin conductor cuando hacen rutas punto a punto
- Sin contacto de emergencia activo durante el trayecto

Hoy, el único recurso disponible es llamar a un familiar o esperar que pase alguien.

---

## La Solución

**EnBici** es una plataforma de acompañamiento de seguridad para ciclistas en Colombia. Funciona como Uber, pero en vez de transporte, conecta ciclistas con acompañantes certificados que los asisten durante toda la ruta.

### Modalidad 1: Acompañante en Moto
Un piloto experto con licencia A2 sigue al ciclista durante la ruta:
- Porta herramientas básicas: bomba, parches, extractor de pacha, lubricante
- Gestiona el tráfico detrás del ciclista en zonas de riesgo
- Activa protocolo de emergencia SOS si hay un accidente
- Coordina con servicios de emergencia con coordenadas GPS exactas

### Modalidad 2: Conductor de Auto Propio
El conductor maneja el vehículo del ciclista mientras él pedalea:
- Ideal para rutas punto a punto (el auto llega al destino)
- Gestiona paradas de avituallamiento y soporte
- Porta la bicicleta si el ciclista necesita abandonar la ruta
- Hace el checklist de seguridad inicial: rack, amarre, inspección bici

---

## Usuarios Objetivo

### Ciclistas (clientes)
- **Primario:** Ciclista recreativo 30-55 años, estrato 4-6, Bogotá y Medellín
- **Secundario:** Ciclista de ruta/competencia que entrena en zonas periurbanas
- **Terciario:** Grupos de ciclistas que organizan salidas de fin de semana
- **Dolor principal:** Salir solo sin red de seguridad, o perder el auto en destino

### Acompañantes en Moto
- Motociclistas con licencia A2 vigente
- Buscando ingresos complementarios flexibles (ej: mensajeros en tiempo libre)
- Conocen bien las rutas ciclísticas de su ciudad/región
- Perfil: 25-45 años, SOAT y tecno-mecánica al día

### Conductores de Auto Propio
- Personas con licencia B1/B2, historial de conducción limpio
- El servicio usa el vehículo del ciclista, no el del conductor
- Ideal para conductores que viven cerca de zonas ciclísticas populares

---

## Propuesta de Valor

| Para el Ciclista | Para el Acompañante |
|-----------------|---------------------|
| Seguridad activa en ruta | Ingresos flexibles, sin horario fijo |
| Alguien que conoce la ruta | Comisión 85% (vs 75% Uber) |
| Asistencia mecánica inmediata | Sin costo de entrada a la plataforma |
| Protocolo SOS con GPS | Pagos cada martes |
| Contacto emergencia siempre activo | Rating construye reputación |

---

## Mercado y Oportunidad

- **TAM (Colombia):** 1.2M ciclistas activos
- **SAM (Bogotá + Medellín):** ~420.000 ciclistas en zonas objetivo
- **SOM (Año 1):** 500 DAU ciclistas = ~15.000 servicios/mes
- **GMV Target Mes 4:** COP 63 millones (~$15.750 USD)
- **Revenue (15%):** COP 9.5 millones/mes (~$2.362 USD)
- **Ciclo de vida del cliente:** Alta frecuencia (ciclistas salen 2-4 veces/semana)

---

## Diferenciadores vs Competencia

| Factor | EnBici | Uber/Cabify | Solución actual |
|--------|--------|-------------|-----------------|
| Modelo específico ciclismo | ✅ | ❌ | ❌ |
| Acompañante en moto | ✅ | ❌ | ❌ |
| Protocolo SOS con GPS | ✅ | ❌ | ❌ |
| Comisión acompañante | 85% | 75% | N/A |
| Verificación RUNT | ✅ | Parcial | ❌ |
| Offline-first GPS | ✅ | Parcial | ❌ |

---

## KPIs de Producto (Target Mes 4)

| Métrica | Meta | Por qué importa |
|---------|------|-----------------|
| DAU Ciclistas | 500 | Tracción inicial |
| Acompañantes activos | 300-400 | Supply para match |
| Tiempo match | < 60s | UX competitiva |
| Tasa aceptación | > 75% | Salud del supply |
| Rating promedio | 4.6/5.0 | Confianza |
| Tasa disputas | < 2% | Calidad servicio |
| Tiempo respuesta SOS | < 30s | Seguridad crítica |

---

## Principios de Diseño

1. **Seguridad primero:** Cada decisión de diseño prioriza la seguridad del ciclista
2. **Funciona sin señal:** Offline-first para zonas rurales con cobertura irregular
3. **Guantes on:** Botones mínimo 48×48px, dark mode por defecto
4. **Cero fricción en emergencias:** El SOS debe activarse en < 3 segundos desde que el ciclista lo decide
5. **Transparencia:** El ciclista siempre sabe dónde está su acompañante y viceversa
