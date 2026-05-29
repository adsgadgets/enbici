# ADR-001: Estructura Inicial del Repositorio — Monorepo Modular

**Fecha:** 2026-05-28
**Estado:** Aceptado
**Autores:** Equipo EnBici / AdsGadgets

---

## Contexto

EnBici necesita un repositorio que aloje tres apps distintas (ciclista, acompañante en moto, conductor de auto) y un backend compartido. Se evaluaron tres enfoques:

1. **Monorepo con un solo repositorio** — todo el código en un lugar
2. **Polyrepo** — un repositorio por app/servicio (backend, mobile-cyclist, mobile-companion, mobile-driver)
3. **Monolito monorepo con monolito modular** — un repo, backend como monolito con módulos independientes

---

## Decisión

Usaremos **opción 3: monorepo con monolito modular en el backend**.

```
enbici/
├── backend/     (Node.js + Express, módulos: auth, rides, payments, sos...)
├── mobile/      (React Native + Expo, tres conjuntos de pantallas)
├── docs/
├── tasks/
├── decisions/
└── infra/
```

---

## Justificación

### Por qué monorepo (no polyrepo)

| Factor | Monorepo | Polyrepo |
|--------|----------|----------|
| Código compartido (tipos, utils) | ✅ Fácil | ❌ Requiere packages privados |
| Cambios cross-sistema en un PR | ✅ Un solo PR | ❌ PRs en múltiples repos |
| Onboarding nuevos devs | ✅ `git clone` único | ❌ Múltiples repos que clonar |
| Visibilidad del sistema completo | ✅ Total | ❌ Fragmentada |
| Riesgo con equipo pequeño (3 devs) | ✅ Bajo | ❌ Alto (overhead de gestión) |

**Con un equipo de 3 devs, el polyrepo añade overhead sin beneficios reales hasta que el sistema escale.**

### Por qué monolito modular (no microservicios desde el inicio)

| Factor | Monolito modular | Microservicios desde el inicio |
|--------|-----------------|-------------------------------|
| Velocidad de desarrollo | ✅ Alta (sin overhead de infra) | ❌ Baja (múltiples deployments) |
| Costo de infraestructura MVP | ✅ 1x EC2, 1x RDS | ❌ 8+ servicios, 8+ RDS/SQS |
| Debugging y tracing | ✅ Simple (logs locales) | ❌ Requiere Jaeger/Zipkin |
| Migración futura | ✅ Módulos independientes → fácil extracción | N/A |
| Riesgo de over-engineering | ✅ Bajo | ❌ Alto |

**Un monolito bien modularizado puede soportar hasta ~50.000 solicitudes/día sin necesitar microservicios. El MVP apunta a 500 DAU (~15.000 solicitudes/mes).**

### Ruta de migración a microservicios (si es necesario)

Cuando el volumen lo justifique (estimado mes 18-24):
1. Extraer `payments/` → servicio independiente (mayor criticidad de aislamiento)
2. Extraer `tracking/` → servicio WebSocket dedicado (mayor carga)
3. Extraer `sos/` → servicio de alta disponibilidad con SLA propio
4. El resto puede mantenerse como monolito si el volumen no lo requiere

---

## Consecuencias

### Positivas
- Inicio de desarrollo inmediato sin overhead de infra
- Un solo repositorio para rastrear todo el historial de cambios
- Compartición de código entre backend y móvil sin paquetes privados
- Facturas AWS significativamente menores en los primeros 6 meses

### Negativas
- El backend no puede escalarse módulo por módulo (solo horizontalmente como un todo)
- Si un módulo tiene un bug crítico, afecta a todos los módulos (mitigado con circuit breakers)
- Las pruebas de integración pueden volverse lentas con el tiempo (mitigado con mocks)

---

## Alternativas Descartadas

### Turborepo / Nx (monorepo con tooling avanzado)
Evaluado pero descartado. Añade complejidad de configuración para un equipo de 3 devs. Se puede adoptar en V2 si el volumen de código lo justifica.

### Firebase como backend completo
Descartado. Firebase RTDB tiene latencia de 800ms en zonas rurales colombianas vs 250ms con Socket.io + Redis. Las geoqueries de PostGIS no tienen equivalente nativo en Firebase. Los costos de Firestore escalan mal con el volumen de puntos GPS.

---

## Referencias

- [Docs Arquitectura](../docs/02-arquitectura.md)
- [Backlog MVP](../tasks/backlog.md)
- [Stack Stack decisión](../docs/00-vision-del-producto.md)
