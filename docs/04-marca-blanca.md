# Sistema de Marca Blanca — EnBici

## Concepto

EnBici puede licenciarse a operadores en otras ciudades o países bajo su propia marca. El sistema de marca blanca permite cambiar nombre, colores, logos y configuración regional sin modificar el código base.

---

## Configuración por Tenant

Cada operador tiene su propio archivo `tenant.config.json`:

```json
{
  "tenantId": "enbici-colombia",
  "brandName": "EnBici",
  "brandNameShort": "EB",
  "country": "CO",
  "currency": "COP",
  "timezone": "America/Bogota",
  "locale": "es-CO",
  "colors": {
    "primary": "#E84700",
    "secondary": "#1A1A1A",
    "background": "#121212",
    "surface": "#1E1E1E",
    "onPrimary": "#FFFFFF",
    "onBackground": "#FFFFFF",
    "sos": "#FF0000",
    "success": "#4CAF50",
    "warning": "#FFC107"
  },
  "logo": {
    "light": "assets/logo-light.png",
    "dark": "assets/logo-dark.png",
    "icon": "assets/icon.png"
  },
  "contact": {
    "supportPhone": "+57-300-000-0000",
    "supportWhatsApp": "+57-300-000-0000",
    "supportEmail": "soporte@enbici.co",
    "emergencyNumber": "123"
  },
  "paymentProviders": {
    "primary": "wompi",
    "fallback": "bold"
  },
  "fareConfig": {
    "baseFareCOP": 15000,
    "perMinuteCOP": 500,
    "zoneMultipliers": {
      "urban": 1.0,
      "peripheral": 1.2,
      "rural": 1.3
    },
    "surgePricing": {
      "normal": 1.0,
      "peak": 1.5,
      "weekend": 1.2,
      "night": 1.8,
      "max": 2.0
    }
  },
  "platformFeePercent": 15,
  "companionPayoutPercent": 85,
  "features": {
    "motorcycleCompanion": true,
    "carDriver": true,
    "scheduledRides": false,
    "groupRides": false
  }
}
```

---

## Uso en el Código

```javascript
// backend/src/shared/tenant.js
const getTenantConfig = (tenantId) => {
  return require(`../../tenants/${tenantId}/tenant.config.json`);
};

// En el motor de tarifas
const config = getTenantConfig(req.tenantId);
const tarifa = calcularTarifa(minutos, zona, hora, config.fareConfig);
```

---

## Operadores Potenciales

| Mercado | Nombre sugerido | Ajustes necesarios |
|---------|----------------|-------------------|
| Ecuador | EnBici Ecuador | Moneda USD, número emergencias 911, proveedor pago local |
| Perú | EnBici Perú | Moneda SOL, integraciones SUNAT, Yape/Plin como pago |
| México | EnBici México | Peso MXN, CURP en verificación, Conekta/OpenPay |
| Chile | EnBici Chile | Peso CLP, RUT en verificación, Transbank/Khipu |

---

## Roadmap Marca Blanca

- **V1 (mes 8):** Sistema tenant básico — colores, logo, configuración tarifas
- **V2 (mes 12):** Multi-currency, multi-proveedor de pagos, portal para operadores
- **V3 (mes 18):** Panel de administración self-service para operadores por ciudad
