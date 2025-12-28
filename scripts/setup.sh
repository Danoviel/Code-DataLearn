#!/bin/bash
# scripts/setup.sh

set -e

echo "🚀 Iniciando setup de CodeExplainer..."

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Instálalo primero: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado."
    exit 1
fi

echo "✅ Docker y Docker Compose detectados"

# Crear .env si no existe
if [ ! -f .env ]; then
    echo "📝 Creando archivo .env desde .env.example..."
    cp .env.example .env
    echo "⚠️  IMPORTANTE: Edita .env con tus API keys reales"
else
    echo "✅ Archivo .env ya existe"
fi

# Build de imágenes
echo "🔨 Construyendo imágenes Docker..."
docker-compose build

# Iniciar servicios
echo "🚀 Iniciando servicios..."
docker-compose up -d

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que la base de datos esté lista..."
sleep 5

# Aplicar migraciones
echo "🔄 Aplicando migraciones..."
docker-compose exec backend python manage.py migrate

# Crear superusuario (opcional)
echo "👤 ¿Quieres crear un superusuario? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    docker-compose exec backend python manage.py createsuperuser
fi

echo ""
echo "✅ ¡Setup completado!"
echo ""
echo "📍 URLs disponibles:"
echo "   - Frontend:  http://localhost:3000"
echo "   - Backend:   http://localhost:8000"
echo "   - Admin:     http://localhost:8000/admin"
echo ""
echo "📝 Comandos útiles:"
echo "   - Ver logs:        docker-compose logs -f"
echo "   - Detener:         docker-compose down"
echo "   - Reiniciar:       docker-compose restart"
echo "   - Eliminar todo:   docker-compose down -v"
echo ""