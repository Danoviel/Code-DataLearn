# ============================================================
# STAGE 1: Development
# ============================================================
FROM node:20-alpine as development

WORKDIR /app

# Copiar package files primero (caché de Docker)
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Exponer puerto de Vite dev server
EXPOSE 3000

# Comando de desarrollo
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ============================================================
# STAGE 2: Build (para producción)
# ============================================================
FROM node:20-alpine as build

WORKDIR /app

# Build args (variables en tiempo de compilación)
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

COPY package*.json ./
RUN npm ci

COPY . .

# Construir aplicación para producción
RUN npm run build

# ============================================================
# STAGE 3: Production (servidor nginx ligero)
# ============================================================
FROM nginx:alpine as production

# Copiar build de React a nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Copiar configuración custom de nginx (opcional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]