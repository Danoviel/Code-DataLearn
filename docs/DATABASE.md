# Modelo de Base de Datos - Code DataLearn

Este documento describe el esquema completo de la base de datos PostgreSQL utilizada en el proyecto.

## 📋 Tabla de Contenidos

- [Diagrama ER](#diagrama-er)
- [Tablas](#tablas)
  - [Usuario](#1-usuario)
  - [Explicacion](#2-explicacion)
  - [UsoDiario](#3-usodiario)
  - [ExplicacionCacheada](#4-explicacioncacheada)
  - [FeedbackExplicacion](#5-feedbackexplicacion)
- [Relaciones](#relaciones)
- [Índices](#índices)
- [Constraints](#constraints)
- [Migraciones](#migraciones)

---

## 🗺️ Diagrama ER
```
┌──────────────────┐
│     Usuario      │
│──────────────────│
│ PK id            │
│    nombre_usuario│
│    correo        │
│    contraseña    │
│    fecha_creacion│
│    es_premium    │
└────────┬─────────┘
         │
         │ 1
         │
         │ N
    ┌────┴─────────────────────┬──────────────────────┬─────────────────┐
    │                          │                      │                 │
    ▼                          ▼                      ▼                 ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐   ┌─────────────┐
│ Explicacion  │      │  UsoDiario   │      │   Feedback   │   │             │
│──────────────│      │──────────────│      │──────────────│   │  Caché es   │
│ PK id        │      │ PK id        │      │ PK id        │   │ independ.   │
│ FK usuario_id│      │ FK usuario_id│      │ FK usuario_id│   │             │
│    lenguaje  │      │    fecha     │      │ FK explic_id │   │             │
│    codigo... │      │    contador..│      │    es_util   │   │             │
└──────┬───────┘      └──────────────┘      │    comentario│   │             │
       │                                    └──────────────┘   │             │
       │ 1                                                     │             │
       │                                                       │             │
       │ N                                                     ▼             │
       └────────────────────────────────────────────►┌──────────────────┐   │
                                                      │ FeedbackExplic.. │   │
                                                      └──────────────────┘   │
                                                                             │
                                                      ┌──────────────────┐   │
                                                      │ExplicacionCache..│◄──┘
                                                      │──────────────────│
                                                      │ hash_codigo_fnte │
                                                      │ lenguaje         │
                                                      │ explicacion_ia   │
                                                      └──────────────────┘
```

---

## 📊 Tablas

### 1. Usuario

Tabla principal de autenticación y gestión de usuarios. Extiende el modelo User de Django.

#### Campos

| Campo | Tipo | Restricciones | Descripción |
|-------|------|--------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO INCREMENT | Identificador único del usuario |
| `nombre_usuario` | VARCHAR(150) | NOT NULL, UNIQUE | Nombre de usuario para login |
| `correo` | VARCHAR(254) | NOT NULL, UNIQUE | Email del usuario |
| `contraseña` | VARCHAR(128) | NOT NULL | Contraseña hasheada (Django auth) |
| `fecha_creacion` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de registro |
| `es_premium` | BOOLEAN | NOT NULL, DEFAULT FALSE | Indica si tiene plan premium |

#### Índices
- `idx_usuario_correo` en `correo` (búsqueda rápida en login)
- `idx_usuario_nombre` en `nombre_usuario` (búsqueda rápida)

#### Ejemplo
```sql
INSERT INTO usuario (nombre_usuario, correo, contraseña, es_premium)
VALUES ('david_dev', 'david@example.com', 'pbkdf2_sha256$...', FALSE);
```

---

### 2. Explicacion

Almacena el código ejecutado, sus resultados y la explicación generada por IA.

#### Campos

| Campo | Tipo | Restricciones | Descripción |
|-------|------|--------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO INCREMENT | Identificador único |
| `usuario_id` | INTEGER | FOREIGN KEY → Usuario(id), ON DELETE CASCADE | Usuario propietario |
| `lenguaje` | VARCHAR(20) | NOT NULL | Lenguaje: 'python', 'javascript', 'java' |
| `codigo_fuente` | TEXT | NOT NULL | Código fuente completo |
| `entrada_proporcionada` | TEXT | NULL | Input del usuario (stdin) si aplica |
| `salida_ejecucion` | JSONB | NOT NULL | Respuesta completa de Judge0 |
| `explicacion_ia` | JSONB | NOT NULL | Explicación estructurada de la IA |
| `es_publico` | BOOLEAN | NOT NULL, DEFAULT FALSE | Indica si es compartible públicamente |
| `token_publico` | VARCHAR(64) | UNIQUE, NULL | Token UUID para compartir |
| `fecha_creacion` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |

#### Estructura JSON esperada

**salida_ejecucion** (de Judge0):
```json
{
  "stdout": "Hola mundo\n",
  "stderr": null,
  "compile_output": null,
  "status": {
    "id": 3,
    "description": "Accepted"
  },
  "time": "0.012",
  "memory": 3456
}
```

**explicacion_ia** (generada):
```json
{
  "resumen": "Programa simple que imprime un saludo",
  "lineas": {
    "1": "Imprime el texto 'Hola mundo' en la consola",
    "2": "..."
  },
  "buenas_practicas": [
    "Código limpio y simple",
    "Uso correcto de print()"
  ],
  "sugerencias": [
    "Podrías usar f-strings para interpolación"
  ]
}
```

#### Índices
- `idx_explicacion_usuario_fecha` en `(usuario_id, fecha_creacion DESC)` (historial)
- `idx_explicacion_token` en `token_publico` (búsqueda de links públicos)
- `idx_explicacion_lenguaje` en `lenguaje` (filtros por lenguaje)

#### Ejemplo
```sql
INSERT INTO explicacion (usuario_id, lenguaje, codigo_fuente, salida_ejecucion, explicacion_ia)
VALUES (
  1,
  'python',
  'print("Hola mundo")',
  '{"stdout": "Hola mundo\n", "status": {"description": "Accepted"}}',
  '{"resumen": "Programa que imprime texto", "lineas": {...}}'
);
```

---

### 3. UsoDiario

Controla los límites de uso diario de cada usuario (rate limiting).

#### Campos

| Campo | Tipo | Restricciones | Descripción |
|-------|------|--------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO INCREMENT | Identificador único |
| `usuario_id` | INTEGER | FOREIGN KEY → Usuario(id), ON DELETE CASCADE | Usuario |
| `fecha` | DATE | NOT NULL | Fecha del registro (sin hora) |
| `contador_explicaciones` | INTEGER | NOT NULL, DEFAULT 0 | Cuántas explicaciones pidió hoy |
| `contador_ejecuciones` | INTEGER | NOT NULL, DEFAULT 0 | Cuántas ejecuciones hizo hoy |

#### Constraints
- `UNIQUE (usuario_id, fecha)` - Solo un registro por usuario por día

#### Índices
- `idx_uso_diario_usuario_fecha` en `(usuario_id, fecha)` (verificación rápida)

#### Lógica de negocio
```python
# Verificar si puede pedir otra explicación
uso_hoy = UsoDiario.objects.get_or_create(
    usuario_id=usuario.id,
    fecha=date.today()
)[0]

if uso_hoy.contador_explicaciones >= 10 and not usuario.es_premium:
    raise LimiteExcedido("Alcanzaste el límite de 10 explicaciones diarias")

uso_hoy.contador_explicaciones += 1
uso_hoy.save()
```

#### Ejemplo
```sql
INSERT INTO uso_diario (usuario_id, fecha, contador_explicaciones, contador_ejecuciones)
VALUES (1, '2025-01-15', 7, 23)
ON CONFLICT (usuario_id, fecha)
DO UPDATE SET 
  contador_explicaciones = uso_diario.contador_explicaciones + 1;
```

---

### 4. ExplicacionCacheada

Caché de explicaciones para código idéntico. Reduce costos de API de IA.

#### Campos

| Campo | Tipo | Restricciones | Descripción |
|-------|------|--------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO INCREMENT | Identificador único |
| `hash_codigo_fuente` | VARCHAR(64) | NOT NULL, UNIQUE | SHA-256 del código |
| `lenguaje` | VARCHAR(20) | NOT NULL | Lenguaje del código |
| `explicacion_ia` | JSONB | NOT NULL | Explicación almacenada |
| `contador_usos` | INTEGER | NOT NULL, DEFAULT 0 | Veces que se reutilizó |
| `fecha_creacion` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Primera vez cacheado |
| `ultimo_uso` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Última vez usado |

#### Índices
- `idx_cache_hash_lenguaje` en `(hash_codigo_fuente, lenguaje)` (búsqueda principal)
- `idx_cache_ultimo_uso` en `ultimo_uso` (limpieza de caché viejo)

#### Lógica de caché
```python
import hashlib

# Generar hash del código
codigo_hash = hashlib.sha256(codigo_fuente.encode('utf-8')).hexdigest()

# Buscar en caché
cached = ExplicacionCacheada.objects.filter(
    hash_codigo_fuente=codigo_hash,
    lenguaje=lenguaje
).first()

if cached:
    # Reutilizar explicación
    cached.contador_usos += 1
    cached.ultimo_uso = timezone.now()
    cached.save()
    return cached.explicacion_ia
else:
    # Llamar a IA y cachear
    explicacion = llamar_ia(codigo_fuente)
    ExplicacionCacheada.objects.create(
        hash_codigo_fuente=codigo_hash,
        lenguaje=lenguaje,
        explicacion_ia=explicacion
    )
    return explicacion
```

#### Ejemplo
```sql
INSERT INTO explicacion_cacheada (hash_codigo_fuente, lenguaje, explicacion_ia, contador_usos)
VALUES (
  'a3f5b8c2e1d4...',  -- SHA-256 de 'print("Hola mundo")'
  'python',
  '{"resumen": "...", "lineas": {...}}',
  1
);
```

---

### 5. FeedbackExplicacion

Almacena las valoraciones (👍👎) y comentarios de los usuarios sobre las explicaciones.

#### Campos

| Campo | Tipo | Restricciones | Descripción |
|-------|------|--------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO INCREMENT | Identificador único |
| `explicacion_id` | INTEGER | FOREIGN KEY → Explicacion(id), ON DELETE CASCADE | Explicación valorada |
| `usuario_id` | INTEGER | FOREIGN KEY → Usuario(id), ON DELETE CASCADE | Usuario que valora |
| `es_util` | BOOLEAN | NOT NULL | TRUE = 👍, FALSE = 👎 |
| `comentario` | TEXT | NULL | Comentario opcional del usuario |
| `fecha_creacion` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha del feedback |

#### Constraints
- `UNIQUE (explicacion_id, usuario_id)` - Un usuario solo puede valorar una vez

#### Índices
- `idx_feedback_explicacion` en `explicacion_id` (ver feedback de una explicación)
- `idx_feedback_es_util` en `es_util` (estadísticas generales)

#### Ejemplo
```sql
INSERT INTO feedback_explicacion (explicacion_id, usuario_id, es_util, comentario)
VALUES (42, 1, TRUE, 'Muy clara la explicación, me ayudó mucho')
ON CONFLICT (explicacion_id, usuario_id)
DO UPDATE SET 
  es_util = EXCLUDED.es_util,
  comentario = EXCLUDED.comentario;
```

---

## 🔗 Relaciones

### Relaciones principales
```
Usuario (1) ──────────< (N) Explicacion
  │
  ├─────────< (N) UsoDiario
  │
  └─────────< (N) FeedbackExplicacion

Explicacion (1) ──────< (N) FeedbackExplicacion

ExplicacionCacheada → Sin relaciones (tabla lookup independiente)
```

### Cascadas de eliminación

| Relación | Acción ON DELETE |
|----------|------------------|
| `Explicacion.usuario_id → Usuario.id` | **CASCADE** (si se borra usuario, borrar sus explicaciones) |
| `UsoDiario.usuario_id → Usuario.id` | **CASCADE** (si se borra usuario, borrar su historial de uso) |
| `FeedbackExplicacion.usuario_id → Usuario.id` | **CASCADE** (si se borra usuario, borrar su feedback) |
| `FeedbackExplicacion.explicacion_id → Explicacion.id` | **CASCADE** (si se borra explicación, borrar su feedback) |

---

## 📑 Índices

### Índices para rendimiento
```sql
-- Usuario
CREATE INDEX idx_usuario_correo ON usuario(correo);
CREATE INDEX idx_usuario_nombre ON usuario(nombre_usuario);

-- Explicacion
CREATE INDEX idx_explicacion_usuario_fecha ON explicacion(usuario_id, fecha_creacion DESC);
CREATE INDEX idx_explicacion_token ON explicacion(token_publico) WHERE token_publico IS NOT NULL;
CREATE INDEX idx_explicacion_lenguaje ON explicacion(lenguaje);

-- UsoDiario
CREATE UNIQUE INDEX idx_uso_diario_usuario_fecha ON uso_diario(usuario_id, fecha);

-- ExplicacionCacheada
CREATE UNIQUE INDEX idx_cache_hash_lenguaje ON explicacion_cacheada(hash_codigo_fuente, lenguaje);
CREATE INDEX idx_cache_ultimo_uso ON explicacion_cacheada(ultimo_uso);

-- FeedbackExplicacion
CREATE UNIQUE INDEX idx_feedback_unico ON feedback_explicacion(explicacion_id, usuario_id);
CREATE INDEX idx_feedback_explicacion ON feedback_explicacion(explicacion_id);
```

---

## 🔒 Constraints

### Constraints de integridad
```sql
-- Usuario
ALTER TABLE usuario ADD CONSTRAINT unique_correo UNIQUE (correo);
ALTER TABLE usuario ADD CONSTRAINT unique_nombre_usuario UNIQUE (nombre_usuario);
ALTER TABLE usuario ADD CONSTRAINT check_correo_formato 
  CHECK (correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- Explicacion
ALTER TABLE explicacion ADD CONSTRAINT check_lenguaje 
  CHECK (lenguaje IN ('python', 'javascript', 'java'));
ALTER TABLE explicacion ADD CONSTRAINT check_codigo_no_vacio 
  CHECK (LENGTH(codigo_fuente) > 0);

-- UsoDiario
ALTER TABLE uso_diario ADD CONSTRAINT unique_usuario_fecha 
  UNIQUE (usuario_id, fecha);
ALTER TABLE uso_diario ADD CONSTRAINT check_contadores_positivos 
  CHECK (contador_explicaciones >= 0 AND contador_ejecuciones >= 0);

-- FeedbackExplicacion
ALTER TABLE feedback_explicacion ADD CONSTRAINT unique_feedback_por_usuario 
  UNIQUE (explicacion_id, usuario_id);
```

---

## 🔄 Migraciones

### Orden de creación de tablas
```bash
# 1. Tabla independiente (sin FK)
python manage.py makemigrations usuarios  # Crea tabla Usuario

# 2. Tablas que dependen de Usuario
python manage.py makemigrations explicador  # Crea Explicacion, ExplicacionCacheada
python manage.py makemigrations estadisticas  # Crea UsoDiario

# 3. Tablas que dependen de Explicacion
python manage.py makemigrations feedback  # Crea FeedbackExplicacion

# 4. Aplicar todas las migraciones
python manage.py migrate
```

### Datos iniciales (fixtures)
```python
# scripts/seed_data.py
from apps.usuarios.models import Usuario

# Crear usuario de prueba
Usuario.objects.create_user(
    nombre_usuario='test_user',
    correo='test@example.com',
    contraseña='testpass123'
)
```

---

## 📊 Estadísticas y Queries Útiles

### Queries comunes
```sql
-- Top 10 códigos más explicados (caché)
SELECT 
  lenguaje,
  contador_usos,
  LEFT(explicacion_ia->>'resumen', 50) as resumen
FROM explicacion_cacheada
ORDER BY contador_usos DESC
LIMIT 10;

-- Usuarios más activos del mes
SELECT 
  u.nombre_usuario,
  SUM(ud.contador_explicaciones) as total_explicaciones,
  SUM(ud.contador_ejecuciones) as total_ejecuciones
FROM usuario u
JOIN uso_diario ud ON u.id = ud.usuario_id
WHERE ud.fecha >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY u.id, u.nombre_usuario
ORDER BY total_explicaciones DESC
LIMIT 20;

-- Explicaciones mejor valoradas
SELECT 
  e.id,
  e.lenguaje,
  COUNT(CASE WHEN f.es_util = TRUE THEN 1 END) as likes,
  COUNT(CASE WHEN f.es_util = FALSE THEN 1 END) as dislikes,
  LEFT(e.codigo_fuente, 100) as codigo
FROM explicacion e
LEFT JOIN feedback_explicacion f ON e.id = f.explicacion_id
GROUP BY e.id
HAVING COUNT(f.id) > 5  -- Al menos 5 valoraciones
ORDER BY likes DESC
LIMIT 10;

-- Tasa de acierto del caché
SELECT 
  COUNT(*) as total_explicaciones,
  SUM(contador_usos) as total_hits,
  ROUND(AVG(contador_usos), 2) as promedio_hits_por_codigo
FROM explicacion_cacheada;
```

---

## 🧹 Mantenimiento

### Limpieza de caché antiguo
```sql
-- Borrar entradas de caché no usadas en 90 días
DELETE FROM explicacion_cacheada
WHERE ultimo_uso < NOW() - INTERVAL '90 days'
  AND contador_usos < 5;
```

### Archivado de datos históricos
```sql
-- Mover UsoDiario de hace más de 1 año a tabla de archivo
CREATE TABLE uso_diario_historico AS
SELECT * FROM uso_diario
WHERE fecha < DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year';

DELETE FROM uso_diario
WHERE fecha < DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year';
```

---

## 📝 Notas Técnicas

### Tipos de datos JSONB

Se usa `JSONB` en lugar de `JSON` para:
- **Indexación**: Permite crear índices GIN para búsquedas rápidas
- **Rendimiento**: Búsquedas más eficientes en campos anidados
- **Flexibilidad**: Estructura de explicaciones puede evolucionar sin migraciones

### Escalabilidad

- **Particionamiento**: `UsoDiario` puede particionarse por año si crece mucho
- **Archivado**: Explicaciones antiguas pueden moverse a almacenamiento frío
- **Caché TTL**: Implementar expiración automática de caché

---

**Última actualización**: Diciembre 2024  
**Versión del esquema**: 1.0.0