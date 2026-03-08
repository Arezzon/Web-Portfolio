pipeline {
    agent any

    // Визначаємо змінні оточення для всього пайплайну
    environment {
        IMAGE_NAME = "web-portfolio-local"
        CONTAINER_NAME = "web-portfolio-app"
    }

    tools {
        // Підключаємо NodeJS (назва має збігатися з тією, що в Global Tool Configuration)
        nodejs 'node'
    }

    stages {
        stage('Checkout Project') {
            steps {
                echo "--------- 1. Отримання коду з GitHub ---------"
                // Клонуємо репозиторій з гілки main. Jenkins автоматично підтягне зміни
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/Arezzon/Web-Portfolio.git']]
                ])
            }
        }

        stage('Build') {
            steps {
                echo "--------- 2. Збірка проєкту (Build) ---------"
                // Встановлюємо залежності та компілюємо статичний Astro-сайт
                sh 'npm install'
                sh 'npm run build'

                echo "--------- Створення локального Docker-образу ---------"
                // Пакуємо зібраний сайт у Docker-образ і одразу даємо йому два теги: 
                // latest (найсвіжіший) та унікальний номер поточного білда
                sh "docker build -t ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Test') {
            steps {
                echo "--------- 3. Запуск тестів (Test) ---------"
                // Оскільки сайт статичний, перевіряємо, чи успішно згенерувалася папка dist
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
                sh '''
                    # Зупиняємо і видаляємо старий контейнер, якщо він існує, щоб уникнути конфлікту імен
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    # Запускаємо новий контейнер на порту 8081 з найновішого образу
                    docker run -d --name ${CONTAINER_NAME} -p 8081:80 ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    echo "--------- 5. Пуш у DockerHub ---------"
                    // Витягуємо логін і пароль з Jenkins Credentials (з ID 'dockerhub-cred')
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        
                        // Безпечно авторизуємося в DockerHub
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        
                        // Перетегуємо локальні образи під формат DockerHub (username/repository:tag)
                        // Використовуємо ${env.BUILD_NUMBER} для збереження історії версій
                        sh "docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKER_USER}/web-portfolio:v${env.BUILD_NUMBER}"
                        sh "docker tag ${IMAGE_NAME}:latest ${DOCKER_USER}/web-portfolio:latest"
                        
                        // Відправляємо обидві версії у хмару
                        sh "docker push ${DOCKER_USER}/web-portfolio:v${env.BUILD_NUMBER}"
                        sh "docker push ${DOCKER_USER}/web-portfolio:latest"
                    }
                }
            }
        }
    }

    // Блок post виконується завжди після завершення пайплайну
    post {
        always {
            echo "--------- Очищення сесії ---------"
            // Виходимо з акаунта DockerHub для безпеки
            sh "docker logout"
        }
    }
}
