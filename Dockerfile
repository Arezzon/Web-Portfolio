FROM nginx:alpine

# Створюємо потрібну структуру папок всередині Nginx
RUN mkdir -p /usr/share/nginx/html/Web-Portfolio

# Копіюємо файли не в корінь, а в підпапку
COPY dist/ /usr/share/nginx/html/Web-Portfolio/

EXPOSE 80
