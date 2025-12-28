# Arquitectura del Sistema - Code DataLearn

Este documento describe la arquitectura técnica completa del proyecto, incluyendo la estructura de carpetas, componentes principales y flujo de datos.

## 📋 Tabla de Contenidos

- [Visión General](#visión-general)
- [Diagrama de Arquitectura](#diagrama-de-arquitectura)
- [Estructura de Carpetas](#estructura-de-carpetas)
- [Backend (Django)](#backend-django)
- [Frontend (React)](#frontend-react)
- [Servicios Externos](#servicios-externos)
- [Flujo de Datos](#flujo-de-datos)
- [Patrones de Diseño](#patrones-de-diseño)
- [Seguridad](#seguridad)
- [Deployment](#deployment)

---

## 🎯 Visión General

CodeExplainer sigue una arquitectura **cliente-servidor** con separación completa entre frontend y backend, comunicándose mediante una API REST.

### Principios arquitectónicos

- **Separación de responsabilidades**: Backend (lógica) vs Frontend (presentación)
- **Modularidad**: Cada feature es una app Django independiente
- **Escalabilidad**: Componentes desacoplados que pueden escalar independientemente
- **Containerización**: Todo corre en Docker para consistencia
- **API-First**: Backend expone API REST consumible por cualquier cliente

---

## 🏗️ Diagrama de Arquitectura

### Arquitectura de Alto Nivel
```
┌─────────────────────────────────────────────────────────────┐
│                        USUARIO                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     NGINX (Reverse Proxy)                   │
│                  - SSL/TLS Termination                      │
│                  - Static Files Serving                     │
│                  - Load Balancing                           │
└──────────────┬──────────────────────┬───────────────────────┘
               │                      │
               │ /api/*               │ /*
               ▼                      ▼
┌──────────────────────┐    ┌─────────────────────┐
│   BACKEND (Django)   │    │  FRONTEND (React)   │
│   Port: 8000         │    │  Port: 3000         │
│                      │    │                     │
│  ┌────────────────┐  │    │  ┌───────────────┐ │
│  │ Django REST    │  │    │  │ React Router  │ │
│  │ Framework      │  │    │  │               │ │
│  └────────────────┘  │    │  └───────────────┘ │
│                      │    │                     │
│  ┌────────────────┐  │    │  ┌───────────────┐ │
│  │ Apps:          │  │    │  │ Components    │ │
│  │ - usuarios     │  │    │  │ - Editor      │ │
│  │ - ejecutor     │  │    │  │ - Results     │ │
│  │ - explicador   │  │    │  │ - History     │ │
│  │ - estadisticas │  │    │  └───────────────┘ │
│  │ - feedback     │  │    │                     │
│  └────────────────┘  │    └─────────────────────┘
│                      │
│  ┌────────────────┐  │
│  │ Services:      │  │
│  │ - Judge0       │──┼───► Judge0 API
│  │ - IA (Claude)  │──┼───► Anthropic API
│  │ - Cache        │  │
│  └────────────────┘  │
└──────────┬───────────┘
           │
           ▼
┌─────────────────────┐
│  PostgreSQL 16      │
│  Port: 5432         │
│                     │
│  ┌───────────────┐  │
│  │ Tables:       │  │
│  │ - usuario     │  │
│  │ - explicacion │  │
│  │ - uso_diario  │  │
│  │ - cache       │  │
│  │ - feedback    │  │
│  └───────────────┘  │
└─────────────────────┘
```

---

## 📁 Estructura de Carpetas

### Estructura Completa del Proyecto
```
CODE DATALEARN/
│
├── docker-compose.yml              # Orquestación de servicios
├── .env                            # Variables de entorno (NO commitear)
├── .env.example                    # Ejemplo de variables
├── .gitignore                      # Archivos ignorados por Git
├── README.md                       # Documentación principal
│
├── docs/                           # Documentación del proyecto
│   ├── ARCHITECTURE.md            # Este archivo
│   ├── DATABASE.md                # Esquema de base de datos
│   ├── API.md                     # Documentación de endpoints
│   └── CONTRIBUTING.md            # Guía para contribuir
│
├── Backend/                        # Aplicación Django
│   ├── Dockerfile                 # Imagen Docker del backend
│   ├── requirements.txt           # Dependencias Python
│   ├── .dockerignore             # Archivos ignorados en build
│   ├── manage.py                  # CLI de Django
│   ├── pytest.ini                 # Configuración de tests
│   │
│   ├── config/                    # Configuración principal
│   │   ├── __init__.py
│   │   ├── settings/
│   │   │   ├── __init__.py
│   │   │   ├── base.py           # Settings comunes
│   │   │   ├── development.py    # Settings de desarrollo
│   │   │   └── production.py     # Settings de producción
│   │   ├── urls.py               # URLs principales
│   │   ├── wsgi.py               # WSGI para deployment
│   │   └── asgi.py               # ASGI para async
│   │
│   ├── apps/                      # Aplicaciones Django (features)
│   │   │
│   │   ├── usuarios/              # Autenticación y usuarios
│   │   │   ├── __init__.py
│   │   │   ├── admin.py          # Configuración admin
│   │   │   ├── apps.py           # Configuración app
│   │   │   ├── models.py         # Modelo Usuario
│   │   │   ├── serializers.py    # Serializers DRF
│   │   │   ├── views.py          # Vistas de API
│   │   │   ├── urls.py           # URLs de la app
│   │   │   ├── permissions.py    # Permisos custom
│   │   │   ├── tests/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── test_models.py
│   │   │   │   ├── test_views.py
│   │   │   │   └── test_serializers.py
│   │   │   └── migrations/       # Migraciones de DB
│   │   │
│   │   ├── ejecutor/              # Ejecución de código
│   │   │   ├── __init__.py
│   │   │   ├── apps.py
│   │   │   ├── models.py         # Sin modelos (solo lógica)
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   ├── services/         # Lógica de negocio
│   │   │   │   ├── __init__.py
│   │   │   │   ├── judge0_service.py    # Integración Judge0
│   │   │   │   └── code_validator.py    # Validación de código
│   │   │   └── tests/
│   │   │
│   │   ├── explicador/            # Explicaciones con IA
│   │   │   ├── __init__.py
│   │   │   ├── apps.py
│   │   │   ├── models.py         # Explicacion, ExplicacionCacheada
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   ├── services/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── ia_service.py         # Integración Claude/GPT
│   │   │   │   ├── cache_service.py      # Gestión de caché
│   │   │   │   └── prompt_templates.py   # Prompts para IA
│   │   │   └── tests/
│   │   │
│   │   ├── estadisticas/          # Límites y uso diario
│   │   │   ├── __init__.py
│   │   │   ├── apps.py
│   │   │   ├── models.py         # UsoDiario
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   ├── services/
│   │   │   │   ├── __init__.py
│   │   │   │   └── limite_service.py     # Verificación de límites
│   │   │   └── tests/
│   │   │
│   │   └── feedback/              # Sistema de feedback
│   │       ├── __init__.py
│   │       ├── apps.py
│   │       ├── models.py         # FeedbackExplicacion
│   │       ├── serializers.py
│   │       ├── views.py
│   │       ├── urls.py
│   │       └── tests/
│   │
│   ├── core/                      # Utilidades compartidas
│   │   ├── __init__.py
│   │   ├── middleware.py         # Middlewares custom
│   │   ├── permissions.py        # Permisos reutilizables
│   │   ├── exceptions.py         # Excepciones custom
│   │   ├── pagination.py         # Paginación custom
│   │   ├── utils.py              # Funciones helper
│   │   └── validators.py         # Validadores reutilizables
│   │
│   ├── static/                    # Archivos estáticos (admin)
│   ├── media/                     # Archivos subidos (futuro)
│   │
│   └── locale/                    # Traducciones (i18n)
│       ├── es/
│       └── en/
│
├── Frontend/                      # Aplicación React
│   ├── Dockerfile                # Imagen Docker del frontend
│   ├── package.json              # Dependencias Node.js
│   ├── package-lock.json
│   ├── tsconfig.json             # Configuración TypeScript
│   ├── vite.config.ts            # Configuración Vite
│   ├── .eslintrc.json            # Configuración ESLint
│   ├── .prettierrc               # Configuración Prettier
│   ├── .dockerignore
│   │
│   ├── public/                   # Archivos públicos
│   │   ├── index.html
│   │   ├── favicon.ico
│   │   └── robots.txt
│   │
│   └── src/
│       ├── main.tsx              # Entry point
│       ├── App.tsx               # Componente raíz
│       ├── vite-env.d.ts         # Types de Vite
│       │
│       ├── pages/                # Páginas de la aplicación
│       │   ├── Home.tsx          # Página principal
│       │   ├── Login.tsx         # Login
│       │   ├── Register.tsx      # Registro
│       │   ├── Editor.tsx        # Editor principal
│       │   ├── History.tsx       # Historial de usuario
│       │   ├── PublicView.tsx    # Vista de links públicos
│       │   └── NotFound.tsx      # 404
│       │
│       ├── components/           # Componentes reutilizables
│       │   │
│       │   ├── common/           # Componentes genéricos
│       │   │   ├── Button.tsx
│       │   │   ├── Input.tsx
│       │   │   ├── Select.tsx
│       │   │   ├── Modal.tsx
│       │   │   ├── Loading.tsx
│       │   │   ├── ErrorBoundary.tsx
│       │   │   ├── Toast.tsx
│       │   │   └── Navbar.tsx
│       │   │
│       │   ├── layout/           # Componentes de layout
│       │   │   ├── Header.tsx
│       │   │   ├── Footer.tsx
│       │   │   ├── Sidebar.tsx
│       │   │   └── Container.tsx
│       │   │
│       │   ├── editor/           # Componentes del editor
│       │   │   ├── CodeEditor.tsx          # Monaco Editor wrapper
│       │   │   ├── LanguageSelector.tsx    # Dropdown de lenguajes
│       │   │   ├── InputPanel.tsx          # Panel de stdin
│       │   │   ├── ActionButtons.tsx       # Botones ejecutar/explicar
│       │   │   └── EditorToolbar.tsx       # Barra de herramientas
│       │   │
│       │   ├── results/          # Componentes de resultados
│       │   │   ├── OutputPanel.tsx         # Resultado de ejecución
│       │   │   ├── ExplanationPanel.tsx    # Explicación IA
│       │   │   ├── LineExplanation.tsx     # Explicación por línea
│       │   │   ├── SuggestionsPanel.tsx    # Panel de sugerencias
│       │   │   ├── FeedbackWidget.tsx      # Botones 👍👎
│       │   │   └── ShareButton.tsx         # Botón compartir
│       │   │
│       │   ├── history/          # Componentes de historial
│       │   │   ├── HistoryList.tsx
│       │   │   ├── HistoryItem.tsx
│       │   │   ├── HistoryFilter.tsx
│       │   │   └── HistorySearch.tsx
│       │   │
│       │   └── auth/             # Componentes de autenticación
│       │       ├── LoginForm.tsx
│       │       ├── RegisterForm.tsx
│       │       └── ProtectedRoute.tsx
│       │
│       ├── services/             # Comunicación con API
│       │   ├── api.ts            # Configuración Axios
│       │   ├── authService.ts    # Endpoints de auth
│       │   ├── codeService.ts    # Endpoints de código
│       │   ├── explanationService.ts  # Endpoints de explicaciones
│       │   └── feedbackService.ts     # Endpoints de feedback
│       │
│       ├── store/                # Estado global (Redux/Zustand)
│       │   ├── index.ts
│       │   ├── authSlice.ts      # Estado de autenticación
│       │   ├── editorSlice.ts    # Estado del editor
│       │   └── uiSlice.ts        # Estado UI (modales, toasts)
│       │
│       ├── hooks/                # Custom React Hooks
│       │   ├── useAuth.ts        # Hook de autenticación
│       │   ├── useCodeExecution.ts    # Hook ejecutar código
│       │   ├── useExplanation.ts      # Hook explicaciones
│       │   ├── useFeedback.ts         # Hook feedback
│       │   └── useDebounce.ts         # Hook debounce
│       │
│       ├── types/                # TypeScript Types/Interfaces
│       │   ├── auth.ts
│       │   ├── code.ts
│       │   ├── explanation.ts
│       │   ├── feedback.ts
│       │   └── api.ts
│       │
│       ├── utils/                # Funciones helper
│       │   ├── constants.ts      # Constantes globales
│       │   ├── formatters.ts     # Formateo de datos
│       │   ├── validators.ts     # Validaciones
│       │   └── storage.ts        # LocalStorage helpers
│       │
│       ├── styles/               # Estilos globales
│       │   ├── global.css
│       │   ├── variables.css     # Variables CSS
│       │   └── tailwind.css      # Tailwind imports
│       │
│       └── assets/               # Assets estáticos
│           ├── images/
│           ├── icons/
│           └── fonts/
│
├── nginx/                         # Configuración Nginx
│   ├── Dockerfile
│   ├── nginx.conf                # Configuración principal
│   └── ssl/                      # Certificados SSL (producción)
│
└── scripts/                       # Scripts de utilidad
    ├── setup.sh                  # Setup inicial del proyecto
    ├── deploy.sh                 # Script de deployment
    ├── backup_db.sh              # Backup de base de datos
    └── seed_data.py              # Datos de prueba
```

---

## 🔧 Backend (Django)

### Apps Django - Responsabilidades

#### 1. **usuarios/**
**Responsabilidad**: Autenticación y gestión de usuarios

**Modelos**:
- `Usuario` (extends Django User)

**Endpoints**:
- `POST /api/auth/register/` - Registro
- `POST /api/auth/login/` - Login
- `POST /api/auth/logout/` - Logout
- `GET /api/auth/me/` - Usuario actual
- `PUT /api/auth/me/` - Actualizar perfil

**Servicios**: Ninguno (usa Django auth)

---

#### 2. **ejecutor/**
**Responsabilidad**: Ejecutar código de forma segura

**Modelos**: Ninguno (stateless)

**Endpoints**:
- `POST /api/code/execute/` - Ejecutar código

**Servicios**:
- `judge0_service.py`: Integración con Judge0 API
- `code_validator.py`: Validación de sintaxis básica

**Flujo**:
```python
# views.py
def execute_code(request):
    # 1. Validar código
    validator.validate(codigo)
    
    # 2. Enviar a Judge0
    resultado = judge0_service.execute(codigo, lenguaje, stdin)
    
    # 3. Incrementar contador de ejecuciones
    estadisticas_service.incrementar_ejecuciones(usuario)
    
    # 4. Retornar resultado
    return Response(resultado)
```

---

#### 3. **explicador/**
**Responsabilidad**: Generar explicaciones con IA

**Modelos**:
- `Explicacion`
- `ExplicacionCacheada`

**Endpoints**:
- `POST /api/code/explain/` - Explicar código
- `GET /api/explanations/` - Historial
- `GET /api/explanations/{id}/` - Detalle
- `DELETE /api/explanations/{id}/` - Borrar
- `GET /api/explanations/{id}/share/` - Vista pública

**Servicios**:
- `ia_service.py`: Llamadas a Claude/GPT API
- `cache_service.py`: Gestión de caché
- `prompt_templates.py`: Templates de prompts

**Flujo**:
```python
# views.py
def explain_code(request):
    # 1. Verificar límite diario
    limite_service.verificar_limite(usuario)
    
    # 2. Buscar en caché
    cached = cache_service.buscar(codigo_hash)
    if cached:
        return Response(cached)
    
    # 3. Ejecutar código (opcional)
    resultado = ejecutor_service.execute(codigo)
    
    # 4. Llamar a IA
    explicacion = ia_service.explicar(codigo, resultado)
    
    # 5. Guardar en caché y DB
    cache_service.guardar(codigo_hash, explicacion)
    Explicacion.objects.create(...)
    
    # 6. Incrementar contador
    limite_service.incrementar(usuario)
    
    return Response(explicacion)
```

---

#### 4. **estadisticas/**
**Responsabilidad**: Control de límites y estadísticas

**Modelos**:
- `UsoDiario`

**Endpoints**:
- `GET /api/user/stats/` - Estadísticas del usuario

**Servicios**:
- `limite_service.py`: Verificar y actualizar límites

**Lógica**:
```python
# limite_service.py
def verificar_limite(usuario):
    uso_hoy = UsoDiario.objects.get_or_create(
        usuario=usuario,
        fecha=date.today()
    )[0]
    
    if uso_hoy.contador_explicaciones >= 10 and not usuario.es_premium:
        raise LimiteExcedido()
    
    return True

def incrementar(usuario, tipo='explicacion'):
    uso_hoy = UsoDiario.objects.get(usuario=usuario, fecha=date.today())
    
    if tipo == 'explicacion':
        uso_hoy.contador_explicaciones += 1
    else:
        uso_hoy.contador_ejecuciones += 1
    
    uso_hoy.save()
```

---

#### 5. **feedback/**
**Responsabilidad**: Gestionar valoraciones de usuarios

**Modelos**:
- `FeedbackExplicacion`

**Endpoints**:
- `POST /api/explanations/{id}/feedback/` - Dar feedback
- `GET /api/explanations/{id}/feedback/` - Ver feedback

---

### Core - Utilidades Compartidas

**core/middleware.py**:
- `RateLimitMiddleware`: Rate limiting por IP
- `CorsMiddleware`: CORS personalizado

**core/permissions.py**:
- `IsOwnerOrReadOnly`: Solo propietario puede editar
- `IsPremiumUser`: Solo usuarios premium

**core/exceptions.py**:
- `LimiteExcedido`
- `CodigoInvalido`
- `ServicioNoDisponible`

---

## ⚛️ Frontend (React)

### Páginas Principales

#### 1. **Editor.tsx** (Página principal)
```typescript
// Estructura del componente
<EditorPage>
  <EditorToolbar>
    <LanguageSelector />
    <ActionButtons />
  </EditorToolbar>
  
  <EditorLayout>
    <LeftPanel>
      <CodeEditor />
      <InputPanel />
    </LeftPanel>
    
    <RightPanel>
      <Tabs>
        <OutputPanel />
        <ExplanationPanel />
        <SuggestionsPanel />
      </Tabs>
      <FeedbackWidget />
    </RightPanel>
  </EditorLayout>
</EditorPage>
```

#### 2. **History.tsx**
- Lista de explicaciones guardadas
- Filtros por lenguaje y fecha
- Búsqueda de código

#### 3. **PublicView.tsx**
- Vista read-only de explicación compartida
- Sin autenticación requerida
- Botón "Copiar código"

---

### Gestión de Estado

**Redux/Zustand Store**:
```typescript
// authSlice.ts
interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
}

// editorSlice.ts
interface EditorState {
  code: string;
  language: 'python' | 'javascript' | 'java';
  stdin: string;
  output: ExecutionOutput | null;
  explanation: Explanation | null;
  isExecuting: boolean;
  isExplaining: boolean;
}
```

---

### Hooks Personalizados

**useCodeExecution.ts**:
```typescript
export const useCodeExecution = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [output, setOutput] = useState(null);
  
  const execute = async (code: string, language: string, stdin: string) => {
    setIsLoading(true);
    try {
      const result = await codeService.execute({ code, language, stdin });
      setOutput(result);
      return result;
    } catch (error) {
      toast.error('Error al ejecutar código');
    } finally {
      setIsLoading(false);
    }
  };
  
  return { execute, isLoading, output };
};
```

---

## 🌐 Servicios Externos

### 1. Judge0 API
**Propósito**: Ejecución segura de código

**Configuración**:
```python
# Backend - judge0_service.py
import requests

JUDGE0_URL = "https://judge0-ce.p.rapidapi.com"
HEADERS = {
    "X-RapidAPI-Key": os.getenv("JUDGE0_API_KEY"),
    "Content-Type": "application/json"
}

LANGUAGE_IDS = {
    'python': 71,
    'javascript': 63,
    'java': 62
}
```

**Flujo**:
1. Enviar código + stdin
2. Recibir token de submission
3. Polling hasta completar
4. Retornar resultado

---

### 2. Claude/OpenAI API
**Propósito**: Generar explicaciones

**Configuración**:
```python
# Backend - ia_service.py
import anthropic  # o openai

client = anthropic.Anthropic(api_key=os.getenv("CLAUDE_API_KEY"))

def explicar_codigo(codigo: str, resultado_ejecucion: dict) -> dict:
    prompt = prompt_templates.generar_prompt(codigo, resultado_ejecucion)
    
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1000,
        messages=[{"role": "user", "content": prompt}]
    )
    
    return parsear_respuesta(response.content[0].text)
```

---

## 🔄 Flujo de Datos

### Flujo Completo: "Explicar Código"
```
1. USUARIO escribe código en Monaco Editor
   ↓
2. FRONTEND valida código básico (no vacío)
   ↓
3. FRONTEND hace POST /api/code/explain/
   ↓
4. BACKEND (Django):
   a. Middleware de autenticación (JWT)
   b. View: explicador/views.py
   c. Verificar límite diario (estadisticas_service)
   d. Calcular hash del código
   e. Buscar en ExplicacionCacheada
      ├─ Si existe → retornar caché
      └─ Si NO existe ↓
   f. Llamar a Judge0 (ejecutor_service)
   g. Llamar a Claude/GPT (ia_service)
   h. Parsear respuesta de IA
   i. Guardar en ExplicacionCacheada
   j. Crear registro en Explicacion
   k. Incrementar UsoDiario.contador_explicaciones
   l. Serializar y retornar JSON
   ↓
5. FRONTEND recibe respuesta
   ↓
6. Redux actualiza editorSlice.explanation
   ↓
7. ExplanationPanel re-renderiza con datos
   ↓
8. Usuario ve explicación línea por línea
```

---

## 🎨 Patrones de Diseño

### Backend

**1. Service Layer Pattern**
- Lógica de negocio en `services/`
- Views solo orquestan
- Reutilizable en management commands

**2. Repository Pattern** (implícito con Django ORM)
- Modelos abstraen acceso a DB
- Querysets encapsulan consultas complejas

**3. Factory Pattern**
```python
# ia_service.py
class IAServiceFactory:
    @staticmethod
    def crear(tipo: str):
        if tipo == 'claude':
            return ClaudeService()
        elif tipo == 'openai':
            return OpenAIService()
```

---

### Frontend

**1. Container/Presentational Pattern**
- Containers: `pages/` (lógica + estado)
- Presentational: `components/` (solo UI)

**2. Custom Hooks Pattern**
- Lógica reutilizable en hooks
- Componentes se enfocan en UI

**3. Compound Components**
```tsx
<Editor>
  <Editor.Toolbar />
  <Editor.CodeArea />
  <Editor.Results />
</Editor>
```

---

## 🔒 Seguridad

### Autenticación
- **JWT tokens** en headers
- Refresh tokens para renovación
- Logout invalida tokens

### Validación
- **Backend**: Serializers DRF + validators custom
- **Frontend**: Validación en formularios + TypeScript

### Sanitización
- Judge0 ejecuta en sandbox aislado
- No ejecución directa en servidor Django
- Rate limiting por IP y usuario

### CORS
```python
# settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",  # Dev
    "https://codeexplainer.com"  # Prod
]
```

---

## 🚀 Deployment

### Contenedores Docker

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  db:
    image: postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  
  backend:
    build: ./Backend
    command: gunicorn config.wsgi:application --bind 0.0.0.0:8000
    volumes:
      - ./Backend:/app
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
  
  frontend:
    build: ./Frontend
    volumes:
      - ./Frontend:/app
      - /app/node_modules
  
  nginx:
    build: ./nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
```

### Estrategia de Deploy

**Desarrollo**:
- `docker-compose up`
- Hot reload en backend y frontend

**Producción**:
- Render/Railway para backend
- Vercel/Netlify para frontend
- PostgreSQL como servicio (Render/Supabase)

---

## 📊 Monitoreo y Logs

### Logs
```python
# settings.py
LOGGING = {
    'version': 1,
    'handlers': {
        'file': {
            'class': 'logging.FileHandler',
            'filename': 'django.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
        },
        'apps': {
            'handlers': ['file'],
            'level': 'DEBUG',
        },
    },
}
```

### Métricas importantes
- Tiempo de respuesta de Judge0
- Costo de llamadas a IA
- Tasa de acierto de caché
- Errores de ejecución

---

**Última actualización**: Diciembre 2024  
**Versión**: 1.0.0