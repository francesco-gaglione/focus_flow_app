# Focus Flow

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

This is the official Flutter client for [FocusFlow Cloud](https://github.com/francesco-gaglione/focus_flow_cloud), a backend service for Pomodoro technique tracking. I built this application to manage my focus sessions and tasks across my devices, and I'm sharing it for others who might find it helpful.

## 🎯 What is Focus Flow?

Focus Flow is a mobile application designed to help you implement the Pomodoro technique for time management. It connects to the FocusFlow Cloud backend to track your work sessions and breaks, provide statistics on your productivity, and allow you to organize tasks into categories.

This is the app I use daily to manage my own focus time, and it's designed to be a clean, intuitive, and robust companion for the backend service.

## 🚀 Features

- **Clean Pomodoro Timer**: A beautiful and simple timer to manage your work and break cycles.
- **Task & Category Management**: Organize your tasks within colored categories to keep your work structured.
- **Real-time Sync**: Uses WebSockets to synchronize your session state across multiple clients instantly.
- **Productivity Statistics**: Visualize your focus patterns with charts and detailed stats.
- **Multi-language Support**: Available in English and Italian.
- **Light & Dark Mode**: Adapts to your system's theme for comfortable viewing.
- **Clean Architecture**: A well-structured and maintainable codebase.

## 📸 Screenshots

|                      Light Mode                      |                     Dark Mode                      |
| :--------------------------------------------------: | :------------------------------------------------: |
|      ![Timer light](screenshot/timer_light.png)      |      ![Timer dark](screenshot/timer_dark.png)      |
| ![Categories light](screenshot/categories_light.png) | ![Categories dark](screenshot/categories_dark.png) |
|      ![Stats light](screenshot/stats_light.png)      |      ![Stats dark](screenshot/stats_dark.png)      |

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Architecture**: Clean Architecture
- **State Management**: `flutter_bloc`
- **Navigation**: `go_router`
- **Dependency Injection**: `get_it`
- **HTTP Client**: `dio`
- **Localization**: `easy_localization`
- **Immutability**: `freezed`

## 🏗️ Architecture

The project follows Clean Architecture principles, separating concerns into distinct layers:

```
lib/
├── adapters/       # Data transfer objects (DTOs), repositories, and external service integrations
├── domain/         # Core business logic, entities, and repository interfaces
├── presentation/   # UI (screens/widgets) and state management (Blocs)
├── core/           # Shared utilities, dependency injection, and theme
└── main.dart       # Application entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- A running instance of the [FocusFlow Cloud](https://github.com/francesco-gaglione/focus_flow_cloud) backend.

### Quick Start

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/your-username/focus_flow_app.git
    cd focus_flow_app
    ```

2.  **Set up environment variables**:
    Create a `.env` file in the root of the project and add the following, pointing to your backend instance:

    ```
    BASE_URL=http://localhost:8080
    WS_URL=ws://localhost:8080/ws/
    ```

3.  **Install dependencies**:

    ```bash
    flutter pub get
    ```

4.  **Run code generation**:
    This is required to generate files for `freezed` and `json_serializable`.

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the application**:
    ```bash
    flutter run
    ```

## 🐳 Docker Compose

You can run the web application using Docker Compose for a consistent and isolated environment.

1.  **Set up environment variables**:
    Create a `.env` file in the root of the project. This file is used to configure the application at build time. Point the `BASE_URL` and `WS_URL` to your FocusFlow Cloud backend instance.

    For example, if your backend is running on the same machine and accessible at port 8080, you would use:

    ```env
    BASE_URL=http://<your-ip>:8080
    WS_URL=ws://<your-ip>:8080/ws/workspace/session
    ```

    If you are running the backend in a Docker container on the same Docker network, you can use the container name as the hostname:

    ```env
    # Example for backend container named 'focus_flow_cloud'
    BASE_URL=http://focus_flow_cloud:8080
    WS_URL=ws://focus_flow_cloud:8080/ws/workspace/session
    ```

2.  **Build and run the container**:
    Use Docker Compose to build and start the service in detached mode:

    ```bash
    docker-compose up -d --build
    ```

    The application will be built with the specified environment variables and will be accessible at `http://localhost:8080`.

## 🤝 Contributing

I'm happy to accept suggestions and improvements from the community! Feel free to open issues or submit pull requests if you find bugs or have ideas for enhancements.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- State management by [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- Navigation by [go_router](https://pub.dev/packages/go_router)
