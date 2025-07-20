# Gigs-App

A modern platform connecting gig posters and runners, featuring a microservices backend (Java/Spring Boot) and a cross-platform mobile frontend (Flutter).

---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Running the Project](#running-the-project)
- [Contributing](#contributing)
- [License](#license)

---

## Overview
Gigs-App is a platform that connects users who want to post gigs (tasks, events, or jobs) with runners who can complete them. The system is built with a scalable microservices architecture for the backend and a sleek, modern Flutter app for the frontend.

## Features
- User authentication and profile management
- Task posting and management
- Offer and event services
- Dispute resolution system
- Real-time chat
- Admin dashboard for user and dispute management
- Payment integration
- Microservices architecture for scalability

## Project Structure
```
Gigs-App/
  Backend/           # Java Spring Boot microservices
    api-gateway/     # API Gateway for routing
    Dispute_Service/ # Dispute management
    eureka-server/   # Service discovery
    event-service/   # Event management
    offer-service/   # Offer management
    payment_service/ # Payment processing
    task-service/    # Task management
    user-service/    # User management
  Frontend/
    my_app/          # Flutter mobile app
```

## Technologies Used
- **Backend:** Java, Spring Boot, Spring Cloud, Eureka, Maven, Docker
- **Frontend:** Flutter, Dart
- **Database:** (Configure as needed per service)
- **Other:** REST APIs, Microservices, Docker Compose

## Getting Started

### Backend Setup
1. **Prerequisites:**
   - Java 17+
   - Maven
   - Docker (for running services with Docker Compose)

2. **Service Configuration:**
   - Each service has its own `application.properties` or `application.yml` for configuration.
   - Eureka server must be started first for service discovery.

3. **Running Services Individually:**
   ```bash
   cd Backend/<service-name>
   ./mvnw spring-boot:run
   ```
   Replace `<service-name>` with the desired microservice directory.

4. **Running with Docker Compose:**
   - Some services provide a `docker-compose.yml` for easier orchestration.
   - Example:
     ```bash
     cd Backend/Dispute_Service
     docker-compose up --build
     ```

### Frontend Setup
1. **Prerequisites:**
   - Flutter SDK (latest stable)
   - Dart
   - Android Studio/Xcode (for mobile builds)

2. **Install Dependencies:**
   ```bash
   cd Frontend/my_app
   flutter pub get
   ```

3. **Run the App:**
   ```bash
   flutter run
   ```
   - Use `flutter run -d <device>` to specify a device/emulator.

## Running the Project
- Start the backend services (Eureka, API Gateway, and required microservices).
- Run the Flutter app on your emulator or device.
- Configure API endpoints in the Flutter app if needed (see `lib/utils/api.dart`).

## Contributing
1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License. 