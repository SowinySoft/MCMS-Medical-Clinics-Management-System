# Frontend image: build the React SPA, serve it (and proxy /api) with nginx.
FROM node:20-slim AS build
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci || npm install
COPY frontend/ ./
# Relative API/WS base so nginx (same origin) proxies /api and /ws correctly.
ENV VITE_API_BASE=/api
ENV VITE_WS_BASE=/ws/events/
RUN npm run build

FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
