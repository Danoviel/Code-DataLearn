FROM nginx:alpine

# Copiar configuración custom
COPY nginx.conf /etc/nginx/nginx.conf

# Exponer puerto 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]