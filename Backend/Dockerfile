# ============================================================
# STAGE 1: Base
# ============================================================
# Imagen base de Python 3.11 (versión slim para menor tamaño)
FROM python:3.11-slim as base

# Metadata del creador
LABEL maintainer="david@example.com"

# Variables de entorno para Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# ============================================================
# STAGE 2: Dependencies
# ============================================================
FROM base as dependencies

# Instalar dependencias del sistema necesarias para PostgreSQL
# y otras librerías Python
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar solo requirements.txt primero (optimización de caché)
COPY requirements.txt .

# Instalar dependencias Python
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# ============================================================
# STAGE 3: Application
# ============================================================
FROM dependencies as application

# Copiar todo el código de la aplicación
COPY . .

# Crear directorios para static y media files
RUN mkdir -p /app/static /app/media

# Exponer puerto 8000
EXPOSE 8000

# Script de entrada (ejecuta migraciones antes de iniciar)
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Comando por defecto (puede ser sobreescrito por docker-compose)
CMD ["/docker-entrypoint.sh"]