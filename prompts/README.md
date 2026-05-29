# Prompts para Desarrollo con IA — EnBici

Esta carpeta contiene prompts reutilizables para trabajar con asistentes de IA en el desarrollo de EnBici.

## Estructura

```
prompts/
├── README.md                    (este archivo)
├── backend/
│   ├── nuevo-endpoint.md        Prompt para crear un nuevo endpoint REST
│   ├── nueva-migracion.md       Prompt para crear una migración de DB
│   └── test-unitario.md         Prompt para crear tests Jest
├── mobile/
│   ├── nueva-pantalla.md        Prompt para crear una nueva pantalla React Native
│   └── nuevo-componente.md      Prompt para crear un componente reutilizable
└── debug/
    └── error-analisis.md        Prompt para analizar errores y stack traces
```

## Reglas de Uso

1. **Siempre incluir contexto de EnBici** — referencia a `AI_INSTRUCTIONS.md` en cada prompt
2. **Especificar el archivo destino** — indicar exactamente en qué archivo debe escribir el código
3. **Listar las dependencias** — qué módulos o servicios debe importar el código generado
4. **Definir criterios de aceptación** — cómo verificar que el código funciona correctamente

## Prompt Base (usar como punto de partida)

```
Eres un desarrollador senior trabajando en EnBici, una app de acompañamiento 
para ciclistas en Colombia. El proyecto usa:
- Backend: Node.js + Express.js (sin TypeScript en MVP)
- DB: PostgreSQL 15 + PostGIS
- Real-time: Socket.io + Redis Pub/Sub
- Mobile: React Native + Expo
- Pagos: Wompi (siempre con idempotency_key UUID)
- Auth: Firebase Auth OTP

Reglas críticas (nunca violar):
- Nunca modificar migraciones existentes — crear nuevas
- Siempre incluir idempotency_key en transacciones de pago
- GPS se anonimiza después de 90 días (Ley 1581/2012)
- Botones mínimo 48×48px en mobile
- SOS requiere doble tap para activarse

[Aquí tu petición específica]
```

## Convenciones de Commits para Código Generado por IA

Cuando un commit incluye código generado o asistido por IA, agregar en el mensaje:
```
feat(rides): agregar endpoint de matching por radio PostGIS

Co-authored-by: Claude <claude@anthropic.com>
```
