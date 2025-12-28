#!/bin/bash
# Backend/docker-entrypoint.sh

# Salir si cualquier comando falla
set -e

echo "🔍 Esperando a que PostgreSQL esté listo..."

# Esperar a que PostgreSQL esté realmente listo para aceptar conexiones
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  sleep 0.1
done

echo "✅ PostgreSQL está listo!"

echo "🔄 Aplicando migraciones de base de datos..."
python manage.py migrate --noinput

echo "📦 Recolectando archivos estáticos..."
python manage.py collectstatic --noinput --clear

echo "🚀 Iniciando servidor Django..."
exec "$@"