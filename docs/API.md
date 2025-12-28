# Documentación de API - Code DataLearn

Documentación completa de los endpoints REST de la API de CodeExplainer.

## 📋 Tabla de Contenidos

- [Información General](#información-general)
- [Autenticación](#autenticación)
- [Endpoints](#endpoints)
  - [Autenticación](#autenticación-endpoints)
  - [Ejecución de Código](#ejecución-de-código)
  - [Explicaciones](#explicaciones)
  - [Estadísticas](#estadísticas)
  - [Feedback](#feedback)
- [Códigos de Estado](#códigos-de-estado)
- [Manejo de Errores](#manejo-de-errores)
- [Rate Limiting](#rate-limiting)
- [Ejemplos de Uso](#ejemplos-de-uso)

---

## 🌐 Información General

### Base URL
``` 
Desarrollo:  http://localhost:8000/api
Producción:  https://api.codedatalearn.com/api
```

### Formato de Datos

- **Request**: JSON (`Content-Type: application/json`)
- **Response**: JSON
- **Encoding**: UTF-8
- **Datetime**: ISO 8601 (`2025-12-27T10:30:00Z`)

### Versionado

Versión actual: **v1**

Todas las rutas comienzan con `/api/v1/` (actualmente `/api/` apunta a v1)

---

## 🔐 Autenticación

### Tipo de Autenticación

CodeExplainer usa **JWT (JSON Web Tokens)** para autenticación.

### Headers Requeridos

Para endpoints protegidos, incluir:
```http
Authorization: Bearer <token>
```

### Obtener Token

1. Registrarse o hacer login
2. Recibir `access_token` y `refresh_token`
3. Usar `access_token` en header `Authorization`
4. Renovar con `refresh_token` cuando expire

### Expiración

- **Access Token**: 1 hora
- **Refresh Token**: 7 días

---

## 📡 Endpoints

---

## Autenticación Endpoints

### 1. Registrar Usuario

Crea una nueva cuenta de usuario.
```http
POST /api/auth/register/
```

#### Request Body
```json
{
  "nombre_usuario": "david_dev",
  "correo": "david@example.com",
  "contraseña": "SecurePass123!"
}
```

#### Validaciones

- `nombre_usuario`: 3-150 caracteres, alfanumérico + guiones
- `correo`: Formato válido de email, único
- `contraseña`: Mínimo 8 caracteres, al menos 1 número

#### Response (201 Created)
```json
{
  "id": 1,
  "nombre_usuario": "david_dev",
  "correo": "david@example.com",
  "es_premium": false,
  "fecha_creacion": "2025-12-27T10:30:00Z",
  "tokens": {
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Errores
```json
// 400 - Email ya existe
{
  "correo": ["Usuario con este correo ya existe."]
}

// 400 - Contraseña débil
{
  "contraseña": ["La contraseña debe tener al menos 8 caracteres."]
}
```

---

### 2. Login

Autentica un usuario existente.
```http
POST /api/auth/login/
```

#### Request Body
```json
{
  "correo": "david@example.com",
  "contraseña": "SecurePass123!"
}
```

#### Response (200 OK)
```json
{
  "id": 1,
  "nombre_usuario": "david_dev",
  "correo": "david@example.com",
  "es_premium": false,
  "tokens": {
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Errores
```json
// 401 - Credenciales inválidas
{
  "detail": "Credenciales inválidas."
}
```

---

### 3. Refresh Token

Renueva el access token usando refresh token.
```http
POST /api/auth/refresh/
```

#### Request Body
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Response (200 OK)
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 4. Logout

Invalida el refresh token actual.
```http
POST /api/auth/logout/
```

**Headers**: `Authorization: Bearer <token>`

#### Request Body
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Response (200 OK)
```json
{
  "detail": "Logout exitoso."
}
```

---

### 5. Usuario Actual

Obtiene información del usuario autenticado.
```http
GET /api/auth/me/
```

**Headers**: `Authorization: Bearer <token>`

#### Response (200 OK)
```json
{
  "id": 1,
  "nombre_usuario": "david_dev",
  "correo": "david@example.com",
  "es_premium": false,
  "fecha_creacion": "2025-12-27T10:30:00Z"
}
```

---

### 6. Actualizar Perfil

Actualiza información del usuario.
```http
PUT /api/auth/me/
PATCH /api/auth/me/
```

**Headers**: `Authorization: Bearer <token>`

#### Request Body
```json
{
  "nombre_usuario": "david_developer"
}
```

#### Response (200 OK)
```json
{
  "id": 1,
  "nombre_usuario": "david_developer",
  "correo": "david@example.com",
  "es_premium": false,
  "fecha_creacion": "2025-12-27T10:30:00Z"
}
```

---

## Ejecución de Código

### 7. Ejecutar Código

Ejecuta código en el lenguaje especificado sin generar explicación.
```http
POST /api/code/execute/
```

**Headers**: `Authorization: Bearer <token>`

#### Request Body
```json
{
  "lenguaje": "python",
  "codigo_fuente": "numeros = [1, 2, 3, 4, 5]\nprint(sum(numeros))",
  "entrada_proporcionada": ""
}
```

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `lenguaje` | string | Sí | `python`, `javascript`, o `java` |
| `codigo_fuente` | string | Sí | Código a ejecutar |
| `entrada_proporcionada` | string | No | Input para stdin (default: "") |

#### Response (200 OK)
```json
{
  "salida_ejecucion": {
    "stdout": "15\n",
    "stderr": null,
    "compile_output": null,
    "status": {
      "id": 3,
      "description": "Accepted"
    },
    "time": "0.012",
    "memory": 3456,
    "exit_code": 0
  },
  "lenguaje": "python"
}
```

#### Estados de Judge0

| ID | Descripción |
|----|-------------|
| 3 | Accepted |
| 4 | Wrong Answer |
| 5 | Time Limit Exceeded |
| 6 | Compilation Error |
| 11 | Runtime Error |

#### Errores
```json
// 400 - Código vacío
{
  "codigo_fuente": ["Este campo no puede estar vacío."]
}

// 400 - Lenguaje no soportado
{
  "lenguaje": ["Lenguaje no soportado. Opciones: python, javascript, java"]
}

// 503 - Judge0 no disponible
{
  "detail": "Servicio de ejecución temporalmente no disponible."
}
```

---

## Explicaciones

### 8. Explicar Código

Ejecuta código y genera explicación con IA.
```http
POST /api/code/explain/
```

**Headers**: `Authorization: Bearer <token>`

#### Request Body
```json
{
  "lenguaje": "python",
  "codigo_fuente": "numeros = [1, 2, 3, 4, 5]\nprint(sum(numeros))",
  "entrada_proporcionada": ""
}
```

#### Response (201 Created)
```json
{
  "id": 42,
  "usuario_id": 1,
  "lenguaje": "python",
  "codigo_fuente": "numeros = [1, 2, 3, 4, 5]\nprint(sum(numeros))",
  "entrada_proporcionada": "",
  "salida_ejecucion": {
    "stdout": "15\n",
    "status": {
      "description": "Accepted"
    },
    "time": "0.012",
    "memory": 3456
  },
  "explicacion_ia": {
    "resumen": "Este código suma todos los elementos de una lista de números.",
    "lineas": {
      "1": "Se crea una lista llamada 'numeros' con los valores del 1 al 5.",
      "2": "La función sum() calcula la suma de todos los elementos de la lista (1+2+3+4+5=15) y print() muestra el resultado en consola."
    },
    "buenas_practicas": [
      "Código limpio y legible",
      "Uso correcto de funciones built-in de Python",
      "Nombres de variables descriptivos"
    ],
    "sugerencias": [
      "Podrías agregar un comentario explicando qué hace el código",
      "Considera usar una variable para almacenar el resultado antes de imprimirlo"
    ]
  },
  "es_publico": false,
  "token_publico": null,
  "fecha_creacion": "2025-12-27T10:30:00Z",
  "creditos_restantes": 9
}
```

#### Estructura de `explicacion_ia`
```typescript
interface ExplicacionIA {
  resumen: string;                    // Resumen general
  lineas: Record<string, string>;     // Explicación por línea
  buenas_practicas: string[];         // Prácticas correctas detectadas
  sugerencias: string[];              // Mejoras sugeridas
}
```

#### Errores
```json
// 429 - Límite diario excedido
{
  "detail": "Has alcanzado el límite de 10 explicaciones diarias. Actualiza a Premium o espera 24 horas.",
  "codigo": "LIMITE_EXCEDIDO",
  "creditos_restantes": 0,
  "tiempo_para_reset": "14:30:00"  // HH:MM:SS hasta medianoche
}

// 503 - IA no disponible
{
  "detail": "Servicio de IA temporalmente no disponible. Intenta nuevamente."
}
```

---

### 9. Listar Explicaciones (Historial)

Obtiene el historial de explicaciones del usuario.
```http
GET /api/explanations/
```

**Headers**: `Authorization: Bearer <token>`

#### Query Parameters

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Número de página |
| `page_size` | integer | 20 | Elementos por página (max: 100) |
| `lenguaje` | string | - | Filtrar por lenguaje |
| `ordenar` | string | `-fecha_creacion` | Campo de ordenamiento |

#### Ejemplos
```http
GET /api/explanations/?page=1&page_size=10
GET /api/explanations/?lenguaje=python
GET /api/explanations/?ordenar=-fecha_creacion
```

#### Response (200 OK)
```json
{
  "count": 45,
  "next": "http://localhost:8000/api/explanations/?page=2",
  "previous": null,
  "results": [
    {
      "id": 42,
      "lenguaje": "python",
      "codigo_fuente": "numeros = [1, 2, 3, 4, 5]\nprint(sum(numeros))",
      "salida_ejecucion": {
        "stdout": "15\n"
      },
      "explicacion_ia": {
        "resumen": "Este código suma todos los elementos..."
      },
      "es_publico": false,
      "fecha_creacion": "2025-12-27T10:30:00Z"
    },
    // ... más resultados
  ]
}
```

---

### 10. Detalle de Explicación

Obtiene una explicación específica.
```http
GET /api/explanations/{id}/
```

**Headers**: `Authorization: Bearer <token>`

#### Response (200 OK)
```json
{
  "id": 42,
  "usuario_id": 1,
  "lenguaje": "python",
  "codigo_fuente": "numeros = [1, 2, 3, 4, 5]\nprint(sum(numeros))",
  "entrada_proporcionada": "",
  "salida_ejecucion": { ... },
  "explicacion_ia": { ... },
  "es_publico": false,
  "token_publico": null,
  "fecha_creacion": "2025-12-27T10:30:00Z"
}
```

#### Errores
```json
// 404 - No encontrado
{
  "detail": "No encontrado."
}

// 403 - No autorizado
{
  "detail": "No tienes permiso para acceder a esta explicación."
}
```

---

### 11. Eliminar Explicación

Elimina una explicación del historial.
```http
DELETE /api/explanations/{id}/
```

**Headers**: `Authorization: Bearer <token>`

#### Response (204 No Content)

Sin contenido en el body.

---

### 12. Compartir Explicación

Genera un link público para compartir.
```http
POST /api/explanations/{id}/share/
```

**Headers**: `Authorization: Bearer <token>`

#### Response (200 OK)
```json
{
  "id": 42,
  "es_publico": true,
  "token_publico": "a3f5b8c2-e1d4-4f7a-9c3b-2d8e6f1a4b7c",
  "url_publica": "https://codeexplainer.com/shared/a3f5b8c2-e1d4-4f7a-9c3b-2d8e6f1a4b7c"
}
```

---

### 13. Ver Explicación Pública

Accede a una explicación compartida (sin autenticación).
```http
GET /api/explanations/public/{token}/
```

**Sin autenticación requerida**

#### Response (200 OK)
```json
{
  "id": 42,
  "lenguaje": "python",
  "codigo_fuente": "numeros = [1, 2, 3, 4, 5]\nprint(sum(numeros))",
  "entrada_proporcionada": "",
  "salida_ejecucion": { ... },
  "explicacion_ia": { ... },
  "fecha_creacion": "2025-12-27T10:30:00Z"
}
```

**Nota**: No incluye `usuario_id` por privacidad.

---

## Estadísticas

### 14. Estadísticas del Usuario

Obtiene estadísticas de uso del usuario actual.
```http
GET /api/user/stats/
```

**Headers**: `Authorization: Bearer <token>`

#### Response (200 OK)
```json
{
  "usuario": {
    "id": 1,
    "nombre_usuario": "david_dev",
    "es_premium": false
  },
  "uso_hoy": {
    "fecha": "2025-12-27",
    "explicaciones_usadas": 7,
    "limite_explicaciones": 10,
    "explicaciones_restantes": 3,
    "ejecuciones_totales": 23
  },
  "estadisticas_globales": {
    "total_explicaciones": 45,
    "total_ejecuciones": 156,
    "lenguaje_favorito": "python",
    "dias_activos": 12
  }
}
```

---

## Feedback

### 15. Dar Feedback

Valora una explicación con 👍 o 👎.
```http
POST /api/explanations/{id}/feedback/
```

**Headers**: `Authorization: Bearer <token>`

#### Request Body
```json
{
  "es_util": true,
  "comentario": "Muy clara la explicación, me ayudó mucho"
}
```

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `es_util` | boolean | Sí | `true` = 👍, `false` = 👎 |
| `comentario` | string | No | Comentario opcional (max 500 chars) |

#### Response (201 Created)
```json
{
  "id": 15,
  "explicacion_id": 42,
  "usuario_id": 1,
  "es_util": true,
  "comentario": "Muy clara la explicación, me ayudó mucho",
  "fecha_creacion": "2025-12-27T10:35:00Z"
}
```

#### Errores
```json
// 400 - Ya dio feedback
{
  "detail": "Ya diste feedback para esta explicación. Usa PUT para actualizar."
}
```

---

### 16. Actualizar Feedback

Actualiza un feedback existente.
```http
PUT /api/explanations/{id}/feedback/
```

**Headers**: `Authorization: Bearer <token>`

#### Request Body
```json
{
  "es_util": false,
  "comentario": "Después de revisar, la explicación no era tan clara"
}
```

#### Response (200 OK)
```json
{
  "id": 15,
  "explicacion_id": 42,
  "usuario_id": 1,
  "es_util": false,
  "comentario": "Después de revisar, la explicación no era tan clara",
  "fecha_creacion": "2025-12-27T10:35:00Z"
}
```

---

### 17. Ver Feedback de Explicación

Obtiene estadísticas de feedback de una explicación.
```http
GET /api/explanations/{id}/feedback/stats/
```

**Headers**: `Authorization: Bearer <token>`

#### Response (200 OK)
```json
{
  "explicacion_id": 42,
  "total_feedback": 15,
  "likes": 12,
  "dislikes": 3,
  "porcentaje_util": 80.0,
  "comentarios_destacados": [
    "Muy clara la explicación",
    "Me ayudó a entender los ciclos"
  ]
}
```

---

## 📊 Códigos de Estado

### Éxito (2xx)

| Código | Descripción |
|--------|-------------|
| 200 | OK - Solicitud exitosa |
| 201 | Created - Recurso creado exitosamente |
| 204 | No Content - Eliminación exitosa |

### Errores del Cliente (4xx)

| Código | Descripción |
|--------|-------------|
| 400 | Bad Request - Datos inválidos |
| 401 | Unauthorized - No autenticado |
| 403 | Forbidden - Sin permisos |
| 404 | Not Found - Recurso no encontrado |
| 429 | Too Many Requests - Límite excedido |

### Errores del Servidor (5xx)

| Código | Descripción |
|--------|-------------|
| 500 | Internal Server Error - Error del servidor |
| 503 | Service Unavailable - Servicio no disponible |

---

## ⚠️ Manejo de Errores

### Formato de Error Estándar
```json
{
  "detail": "Mensaje descriptivo del error",
  "codigo": "CODIGO_ERROR_OPCIONAL",
  "campo": "campo_con_error",
  "extra_info": {}
}
```

### Ejemplos de Errores

#### Validación
```json
{
  "codigo_fuente": ["Este campo es requerido."],
  "lenguaje": ["Lenguaje no soportado."]
}
```

#### Límite Excedido
```json
{
  "detail": "Has alcanzado el límite de 10 explicaciones diarias.",
  "codigo": "LIMITE_EXCEDIDO",
  "creditos_restantes": 0,
  "tiempo_para_reset": "14:30:00"
}
```

#### Servicio No Disponible
```json
{
  "detail": "Servicio de ejecución temporalmente no disponible.",
  "codigo": "SERVICIO_NO_DISPONIBLE",
  "servicio": "judge0",
  "reintentar_en": 60
}
```

---

## 🚦 Rate Limiting

### Límites por Endpoint

| Endpoint | Límite | Ventana |
|----------|--------|---------|
| `/api/auth/login/` | 5 intentos | 15 minutos |
| `/api/code/execute/` | Ilimitado | - |
| `/api/code/explain/` | 10 (gratis) | 24 horas |
| `/api/code/explain/` | Ilimitado (premium) | - |
| Otros endpoints | 100 requests | 1 minuto |

### Headers de Rate Limit
```http
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 3
X-RateLimit-Reset: 1640606400
```

### Respuesta cuando se excede
```http
HTTP/1.1 429 Too Many Requests
Retry-After: 3600
```
```json
{
  "detail": "Límite de requests excedido. Reintentar en 1 hora.",
  "codigo": "RATE_LIMIT_EXCEDIDO"
}
```

---

## 💡 Ejemplos de Uso

### JavaScript (Axios)
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Interceptor para agregar token
api.interceptors.request.use(config => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Login
const login = async (correo, contraseña) => {
  const response = await api.post('/auth/login/', { correo, contraseña });
  localStorage.setItem('access_token', response.data.tokens.access);
  localStorage.setItem('refresh_token', response.data.tokens.refresh);
  return response.data;
};

// Explicar código
const explicarCodigo = async (codigo, lenguaje) => {
  const response = await api.post('/code/explain/', {
    codigo_fuente: codigo,
    lenguaje: lenguaje,
    entrada_proporcionada: ''
  });
  return response.data;
};
```

---

### Python (requests)
```python
import requests

BASE_URL = "http://localhost:8000/api"

class CodeExplainerClient:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({'Content-Type': 'application/json'})
    
    def login(self, correo, contraseña):
        response = self.session.post(
            f"{BASE_URL}/auth/login/",
            json={"correo": correo, "contraseña": contraseña}
        )
        data = response.json()
        self.session.headers.update({
            'Authorization': f"Bearer {data['tokens']['access']}"
        })
        return data
    
    def explicar_codigo(self, codigo, lenguaje):
        response = self.session.post(
            f"{BASE_URL}/code/explain/",
            json={
                "codigo_fuente": codigo,
                "lenguaje": lenguaje,
                "entrada_proporcionada": ""
            }
        )
        return response.json()

# Uso
client = CodeExplainerClient()
client.login("david@example.com", "SecurePass123!")
resultado = client.explicar_codigo("print('Hola')", "python")
print(resultado['explicacion_ia']['resumen'])
```

---

### cURL
```bash
# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"correo":"david@example.com","contraseña":"SecurePass123!"}'

# Explicar código (con token)
curl -X POST http://localhost:8000/api/code/explain/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "codigo_fuente": "print(\"Hola mundo\")",
    "lenguaje": "python",
    "entrada_proporcionada": ""
  }'
```

---

## 🔄 Flujo Completo de Ejemplo
```javascript
// 1. Registrar usuario
const registro = await fetch('http://localhost:8000/api/auth/register/', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    nombre_usuario: 'nuevo_usuario',
    correo: 'nuevo@example.com',
    contraseña: 'SecurePass123!'
  })
});
const { tokens } = await registro.json();

// 2. Guardar token
localStorage.setItem('access_token', tokens.access);

// 3. Ejecutar código
const ejecucion = await fetch('http://localhost:8000/api/code/execute/', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${tokens.access}`
  },
  body: JSON.stringify({
    codigo_fuente: 'print("Hola mundo")',
    lenguaje: 'python'
  })
});
const resultadoEjecucion = await ejecucion.json();
console.log(resultadoEjecucion.salida_ejecucion.stdout); // "Hola mundo\n"

// 4. Explicar código
const explicacion = await fetch('http://localhost:8000/api/code/explain/', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${tokens.access}`
  },
  body: JSON.stringify({
    codigo_fuente: 'print("Hola mundo")',
    lenguaje: 'python'
  })
});
const resultadoExplicacion = await explicacion.json();
console.log(resultadoExplicacion.explicacion_ia.resumen);

// 5. Dar feedback
await fetch(`http://localhost:8000/api/explanations/${resultadoExplicacion.id}/feedback/`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${tokens.access}`
  },
  body: JSON.stringify({
    es_util: true,
    comentario: 'Excelente explicación'
  })
});
```

---

## 📝 Notas Importantes

### Paginación

Todos los endpoints de lista usan paginación:
- Default: 20 items por página
- Máximo: 100 items por página
- Headers de paginación incluidos en response

### Caché

Las explicaciones se cachean por hash de código:
- Reduce costos de API de IA
- Mejora tiempo de respuesta
- Invisible para el usuario

### Timezone

Todos los timestamps están en UTC (ISO 8601).

### CORS

CORS está habilitado para:
- `http://localhost:3000` (desarrollo)
- `https://codeexplainer.com` (producción)

---

**Última actualización**: Diciembre 2024  
**Versión de API**: 1.0.0

**¿Preguntas o sugerencias?**  
Abre un issue en GitHub o contacta al equipo de desarrollo.