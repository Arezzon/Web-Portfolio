pipeline {
    agent any 

    // Визначаємо змінні для локального використання
    environment {
        IMAGE_NAME = "web-portfolio-local"
        CONTAINER_NAME = "web-portfolio-app"
    }

    tools {
        nodejs 'node'
    }

    stages {
        stage('Checkout Project') {
            steps {
                echo "--------- 1. Отримання коду з GitHub ---------"
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[url: 'https://github.com/Arezzon/Web-Portfolio.git']]
                ])
            }
        }

        stage('Build') {
            steps {
                echo "--------- 2. Збірка проєкту (Build) ---------"
                // Збираємо статичний сайт через Node.js 
                sh npm install
                sh npm run build
                                
                echo "--------- Створення локального Docker-образу ---------"
                // Пакуємо зібраний сайт у Docker-образ 
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Test') {
            steps {
                echo "--------- 3. Запуск тестів (Test) ---------"
                // Для статичного сайту перевіряємо успішність генерації папки dist 
                sh '''
                    if [ -d "dist" ]; then
                        echo "Тести пройдено: папка 'dist' успішно згенерована."
                    else
                        echo "Помилка: папка 'dist' не знайдена. Білд провалився!"
                        exit 1
                    fi
                '''
            }
        }

        stage('Deploy (Local)') {
            steps {
                echo "--------- 4. Локальний деплой (Deploy) ---------"
                // Деплой на тестове середовище (локально на jenkins-server) 
                sh '''
                    # Зупиняємо і видаляємо старий контейнер, якщо він існує
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    
                    # Запускаємо новий контейнер на порту 8081
                    docker run -d --name ${CONTAINER_NAME} -p 8081:80 ${IMAGE_NAME}
                '''
            }
        }
    }
}
