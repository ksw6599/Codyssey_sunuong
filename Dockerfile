FROM nginx:alpine
LABEL org.opencontainers.image.title="Codyssey E1-1 Workbench"
COPY app/ /usr/share/nginx/html/
