# Task Manager — Node.js Express + Flutter (MVVM)

A full-stack task-manager demo with a **Node.js/Express REST API backend** and a **Flutter mobile app** built in **MVVM architecture**, wired together with JWT authentication.

```
integrations/
├── backend/                 # Node.js + Express REST API
│   ├── app.js               # Express app (middleware + routes)
│   ├── server.js            # Entry point (starts HTTP server)
│   ├── .env / .env.example  # Environment config
│   ├── package.json
│   ├── controllers/         # Route handlers (auth, tasks)
│   ├── middleware/          # auth, validation, error handling
│   ├── models/              # in-memory data store (+ optional MongoDB)
│   ├── routes/              # authRoutes, taskRoutes
│   ├── services/            # JWT token service
│   └── utils/               # AppError, asyncHandler
├── flutter_app/             # Flutter mobile app (MVVM)
│   ├── lib/
│   │   ├── main.dart            # DI setup + runApp
│   │   ├── app.dart             # MaterialApp + routes
│   │   ├── core/                # constants, network client, exceptions
│   │   ├── data/                # models + repository implementations
│   │   ├── presentation/        # viewmodels, views (screens/widgets), routes
│   │   └── ...
│   ├── test/
│   ├── pubspec.yaml
│   └── ...
├── INTEGRATION.md           # How frontend ↔ backend connect
├── API_DOCS.md              # REST API reference
└── README.md                # this file
```

---

## Features

- **Authentication**: Register, login, JWT-based sessions, `/auth/me` profile
- **Tasks**: Create, list, toggle complete, update, delete
- **MVVM (Flutter)**: Clean separation — View (UI) ←→ ViewModel (state) ←→ Repository (data) ←→ API Client (network)
- **Token persistence**: JWT stored in `SharedPreferences`, restored on app relaunch
- **Error handling**: Typed exceptions on the Dart side; consistent JSON errors on the Node side
- **Validation**: `express-validator` on backend; form validation in Flutter

---

## Quick Start

### 1. Backend (Node.js + Express)

```bash
cd backend
cp .env.example .env      # review PORT (default 5001)
npm install
npm run dev               # nodemon, or: npm start
```

The server runs on `http://localhost:5001` (change `PORT` in `.env` if needed).

Verify:
```bash
curl http://localhost:5001/health
# => {"status":"ok","timestamp":"..."}
```

### 2. Flutter app

```bash
cd flutter_app
flutter pub get
flutter run               # Android emulator / iOS simulator / device
```

> **Important:** The API base URL is configured in
> `flutter_app/lib/core/constants/app_constants.dart`.
> - Android **emulator**: `http://10.0.2.2:5001`  (default)
> - iOS **simulator**:   `http://localhost:5001`
> - Physical device:     use your computer's LAN IP, e.g. `http://192.168.x.x:5001`

Make sure the backend is running before launching the app.

### 3. End-to-end flow

1. Open the app → Splash screen → Login/Register
2. Register a new account (or login)
3. You land on **Home** with your task list
4. Add tasks, tap a task to edit, swipe to delete, checkbox to toggle
5. Logout from the top-right icon → returns to Login

---

## Architecture

### Backend (Layered)

```
Routes  →  Controllers  →  Model (in-memory store / MongoDB)
   ↑           ↑
Middleware (auth, validation, error handling)
```

- `controllers/authController.js` — register, login, getMe
- `controllers/taskController.js` — CRUD for tasks (user-scoped)
- `middleware/auth.js` — JWT protect
- `middleware/validate.js` — express-validator rules
- `models/store.js` — in-memory users/tasks (swap for MongoDB via `MONGODB_URI`)

### Flutter (MVVM)

```
View (Screen)  →  ViewModel (ChangeNotifier)  →  Repository  →  ApiClient  →  REST API
```

- `presentation/viewmodels/` — `AuthViewModel`, `TaskViewModel` (hold UI state, `isLoading`, `error`)
- `presentation/views/screens/` — `LoginScreen`, `RegisterScreen`, `HomeScreen`, `SplashScreen`
- `data/repositories/` — `AuthRepositoryImpl`, `TaskRepositoryImpl` (implement abstract repos)
- `core/network/api_client.dart` — attaches Bearer token, throws typed exceptions

State management: **Provider** (`ChangeNotifierProvider`).

---

## Tech Stack

| Layer | Tech |
|-------|------|
| Backend | Node.js, Express, JWT (jsonwebtoken), bcryptjs, express-validator, CORS, Morgan |
| Database | In-memory store (default) — optional MongoDB via Mongoose |
| Frontend | Flutter, Dart |
| State mgmt | Provider |
| Networking | http |
| Local storage | shared_preferences |
| Date formatting | intl |

---

## Scripts

Backend (`backend/`):
- `npm start` — production start
- `npm run dev` — nodemon auto-reload

Flutter (`flutter_app/`):
- `flutter run` — run on connected device/emulator
- `flutter build apk --debug` — build debug APK
- `flutter analyze` — lint
- `flutter test` — run tests

---

## Next Steps / Production Hardening

- Connect a real database (uncomment `MONGODB_URI` and add Mongoose models)
- Add password reset / email verification
- Add refresh-token rotation
- Add input sanitization and rate-limiting (`express-rate-limit`)
- Add unit/widget tests for ViewModels and screens
- Add CI/CD (GitHub Actions) and deploy backend to Render/Railway/Heroku

---

## License

MIT