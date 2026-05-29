# Reporte de Bugs — EnBici

## Plantilla para reportar un bug

```
### [BUG-XXX] Título breve del problema

**Fecha:** YYYY-MM-DD
**Reportado por:** [nombre o username]
**Severidad:** Crítica | Alta | Media | Baja
**Módulo:** auth | rides | tracking | payments | sos | mobile-cyclist | mobile-companion | mobile-driver

**Descripción:**
[Qué está pasando y cuál es el comportamiento esperado]

**Pasos para reproducir:**
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

**Resultado actual:**
[Lo que ocurre]

**Resultado esperado:**
[Lo que debería ocurrir]

**Evidencia:**
- Screenshots / video:
- Logs del servidor:
- Stack trace:

**Entorno:**
- Plataforma: iOS X.X | Android X | Web
- Dispositivo: [modelo]
- Versión app: X.X.X
- Versión backend: X.X.X
- Entorno: dev | staging | producción

**Estado:** Abierto | En progreso | Resuelto | No reproducible
**Asignado a:**
**PR de solución:**
```

---

## Severidades

| Nivel | Definición | SLA de respuesta |
|-------|-----------|-----------------|
| **Crítica** | Pérdida de datos, fallo de pago, SOS no funciona, app no abre | < 2 horas |
| **Alta** | Feature principal rota (matching, tracking, pagos lentos) | < 24 horas |
| **Media** | Feature secundaria con workaround disponible | < 3 días |
| **Baja** | Problemas estéticos, textos incorrectos, mejoras UX | Próximo sprint |

---

## Bugs Activos

_(Vacío — no hay bugs reportados aún)_

---

## Bugs Resueltos

_(Vacío — no hay bugs resueltos aún)_
