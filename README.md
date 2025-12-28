# Code DataLearn 🚀

Plataforma educativa web que permite a estudiantes y desarrolladores ejecutar código en múltiples lenguajes de programación y recibir explicaciones didácticas línea por línea generadas por Inteligencia Artificial.

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Características (MVP)](#características-mvp)
- [Stack Tecnológico](#stack-tecnológico)
- [Arquitectura](#arquitectura)
- [Modelo de Datos](#modelo-de-datos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Roadmap](#roadmap)
- [Contribuir](#contribuir)
- [Licencia](#licencia)
- [Contacto](#contacto)

## 🎯 Descripción

CodeExplainer es una herramienta educativa innovadora que combina:
- **Ejecución segura de código** en sandbox mediante Judge0 API
- **Explicaciones pedagógicas** generadas por IA (Claude/GPT)
- **Visualización de resultados** con soporte para entrada de usuario
- **Sistema de feedback** para mejorar continuamente las explicaciones

### Problema que resuelve

Los estudiantes de programación a menudo tienen dificultades para entender:
- ¿Por qué su código falla?
- ¿Qué hace exactamente cada línea?
- ¿Cuáles son las buenas prácticas?
- ¿Cómo funciona el código paso a paso?

**Code DataLearn** proporciona respuestas claras, didácticas y personalizadas en tiempo real.

## ✨ Características (MVP)

### Funcionalidades Principales

- ✅ **Ejecución de código en múltiples lenguajes**
  - Python 3
  - JavaScript (Node.js)
  - Java
  - Soporte para entrada de usuario (stdin)

- ✅ **Explicaciones inteligentes con IA**
  - Explicación línea por línea del código
  - Detección automática de malas prácticas
  - Sugerencias de mejora
  - Caché de explicaciones comunes (optimización de costos)

- ✅ **Gestión de usuarios**
  - Registro y autenticación
  - Límite gratuito: 10 explicaciones por día
  - Ejecuciones ilimitadas sin explicación

- ✅ **Historial personal**
  - Guardar explicaciones
  - Recuperar código anterior
  - Compartir explicaciones mediante links públicos

- ✅ **Sistema de feedback**
  - Valorar explicaciones (👍👎)
  - Comentarios opcionales
  - Mejora continua del sistema

## 🛠️ Stack Tecnológico

### Backend
- **Django 5.x** - Framework web
- **Django REST Framework** - API REST
- **PostgreSQL 16** - Base de datos
- **Judge0 API** - Ejecución segura de código
- **Claude API / OpenAI GPT** - Generación de explicaciones (por definir)

### Frontend
- **React 18** - Librería UI
- **TypeScript** - Tipado estático
- **Vite** - Build tool
- **Monaco Editor** - Editor de código (mismo de VS Code)
- **Axios** - Cliente HTTP

### DevOps
- **Docker & Docker Compose** - Containerización
- **Nginx** - Reverse proxy (producción)
- **Render / Railway** - Hosting (por definir)

## 🏗️ Arquitectura
```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  React Frontend     │
│  (TypeScript)       │
└──────┬──────────────┘
       │ API REST
       ▼
┌─────────────────────┐
│  Django Backend     │
│  - Autenticación    │
│  - Lógica negocio   │
└──┬────────┬─────────┘
   │        │
   │        ▼
   │   ┌──────────────┐
   │   │  PostgreSQL  │
   │   └──────────────┘
   │
   ├──────────────────┐
   │                  │
   ▼                  ▼
┌────────────┐   ┌──────────┐
│  Judge0    │   │  IA API  │
│  (Código)  │   │ (Claude) │
└────────────┘   └──────────┘
```

Para más detalles, ver [ARCHITECTURE.md](docs/ARCHITECTURE.md)

## 🗄️ Modelo de Datos

### Tablas Principales

1. **Usuario** - Autenticación y permisos
2. **Explicacion** - Código + explicación + resultados
3. **UsoDiario** - Control de límites diarios
4. **ExplicacionCacheada** - Caché de explicaciones comunes
5. **FeedbackExplicacion** - Valoraciones de usuarios

Para esquema completo, ver [DATABASE.md](docs/DATABASE.md)

## 🚀 Instalación

### Prerrequisitos

- Docker y Docker Compose instalados
- Git
- Variables de entorno configuradas (ver `.env.example`)

### Setup Rápido
```bash
# 1. Clonar repositorio
git clone https://github.com/tu-usuario/code-explainer.git
cd code-explainer

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus API keys

# 3. Levantar contenedores
docker-compose up --build

# 4. Aplicar migraciones (primera vez)
docker-compose exec backend python manage.py migrate

# 5. Crear superusuario (opcional)
docker-compose exec backend python manage.py createsuperuser
```

La aplicación estará disponible en:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **Admin Django**: http://localhost:8000/admin

### Variables de Entorno Requeridas
```env
# Django
SECRET_KEY=tu-secret-key-aqui
DEBUG=True

# Base de datos
POSTGRES_DB=codeexplainer
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db
POSTGRES_PORT=5432

# APIs externas
JUDGE0_API_KEY=tu-judge0-key
CLAUDE_API_KEY=tu-claude-key  # O OPENAI_API_KEY

# Frontend
VITE_API_URL=http://localhost:8000
```

## 📖 Uso

### Flujo Básico

1. **Registrarse** en la plataforma
2. **Escribir o pegar código** en el editor
3. **Seleccionar lenguaje** (Python/JavaScript/Java)
4. **(Opcional)** Proporcionar entrada de usuario
5. **Ejecutar** para ver solo el resultado
6. **Explicar** para obtener análisis de IA
7. **Guardar** explicación en historial
8. **Compartir** mediante link público

### Ejemplo
```python
# Usuario escribe este código
numeros = [1, 2, 3, 4, 5]
suma = sum(numeros)
print(f"La suma es: {suma}")
```

**CodeExplainer explica:**
- Línea 1: Crea una lista con 5 números enteros
- Línea 2: Usa función built-in `sum()` para calcular la suma
- Línea 3: Imprime resultado usando f-string (buena práctica)
- **Sugerencia**: Código limpio y eficiente ✅

## 🗺️ Roadmap

### ✅ Fase 1 - MVP (Mes 1-2)
- [x] Definición de arquitectura
- [x] Diseño de base de datos
- [ ] Setup Docker completo
- [ ] Backend API REST
- [ ] Frontend React + TypeScript
- [ ] Integración Judge0
- [ ] Integración IA
- [ ] Sistema de autenticación
- [ ] Deploy inicial

### 📋 Fase 2 - Optimización (Mes 3)
- [ ] Mejoras de UI/UX
- [ ] Optimización de caché
- [ ] Soporte para más lenguajes (C++, Go, Rust)
- [ ] Sistema de notificaciones
- [ ] Analytics básico

### 🎮 Fase 3 - Features Avanzados (Mes 4-5)
- [ ] Debugger visual paso a paso
- [ ] Comparador multi-lenguaje
- [ ] Modo refactorización gamificado
- [ ] Tests unitarios completos

### 💰 Fase 4 - Monetización (Mes 6)
- [ ] Plan Premium (explicaciones ilimitadas)
- [ ] Modos de explicación (Principiante/Avanzado)
- [ ] API pública para desarrolladores
- [ ] Modo empresa/educación

## 🤝 Contribuir

Este proyecto es parte de una tesis de investigación sobre educación con IA. Las contribuciones son bienvenidas.

### Cómo contribuir

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Estándares de código

- **Python**: PEP 8, formateado con Black
- **TypeScript**: ESLint + Prettier
- **Commits**: Conventional Commits

Ver [CONTRIBUTING.md](docs/CONTRIBUTING.md) para más detalles.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver [LICENSE](LICENSE) para detalles.

## 👤 Contacto

**David** - Desarrollador Full Stack

- GitHub: [@Danoviel](https://github.com/Danoviel)
- LinkedIn: [David Noe Carhuaz Vicaña](www.linkedin.com/in/david-carhuaz)
- Email: davidnoecarhuazvicana@gmail.com

---

**⭐ Si este proyecto te ayuda, considera darle una estrella en GitHub!**

## 🙏 Agradecimientos

- [Judge0](https://judge0.com/) - Sistema de ejecución de código
- [Anthropic](https://www.anthropic.com/) - Claude API
- [Monaco Editor](https://microsoft.github.io/monaco-editor/) - Editor de código
- TECSUP - Institución educativa

---

<p align="center">
  Hecho con ❤️ para estudiantes de programación
</p>
```

---

## ¿Qué incluye este README?

✅ **Descripción clara** del proyecto
✅ **Características** detalladas
✅ **Stack completo** documentado
✅ **Diagrama de arquitectura** (ASCII art)
✅ **Instrucciones de instalación** paso a paso
✅ **Ejemplo de uso** concreto
✅ **Roadmap** del proyecto
✅ **Guía para contribuir**
✅ **Información de contacto**

---
