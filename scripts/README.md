# Scripts de Utilidad — EnBici

Esta carpeta contiene scripts para automatizar tareas de desarrollo, mantenimiento y operaciones.

## Scripts Planificados

### Base de Datos

| Script | Descripción | Uso |
|--------|-------------|-----|
| `create-location-partitions.sh` | Crea particiones mensuales en `location_stream` | Ejecutar al inicio de cada mes |
| `anonymize-gps.sh` | Anonimiza puntos GPS con más de 90 días | Ejecutar semanalmente (cron) |
| `backup-db.sh` | Backup manual de PostgreSQL a S3 | Uso en emergencias |

### Desarrollo

| Script | Descripción | Uso |
|--------|-------------|-----|
| `seed-test-data.js` | Genera datos de prueba (ciclistas, acompañantes, viajes) | `npm run seed` en backend |
| `generate-test-rides.js` | Simula N viajes con GPS tracks completos | Testing de carga |

### Verificación

| Script | Descripción | Uso |
|--------|-------------|-----|
| `test-wompi-webhook.sh` | Envía un webhook de prueba simulando pago exitoso | Debugging de pagos |
| `simulate-sos.js` | Simula activación de SOS con coordenadas reales | Testing del protocolo |

## Convención de Nomenclatura

- Shell scripts: `kebab-case.sh`
- Node.js scripts: `kebab-case.js`
- Agregar comentario en la primera línea con: propósito, argumentos y ejemplo de uso

## Cómo agregar un nuevo script

1. Crear el archivo en `scripts/`
2. Documentarlo en esta tabla
3. Si tiene argumentos, incluir `--help` flag
4. Si es un cron job, documentar la frecuencia recomendada
