# Використовуємо легкий Nginx
FROM nginx:alpine

# Копіюємо зібраний сайт (папку dist) у стандартну директорію Nginx
COPY dist/ /usr/share/nginx/html/

# Відкриваємо 80 порт
EXPOSE 80
