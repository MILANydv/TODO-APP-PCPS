# Integration Guide — Flutter ↔ Node/Express

This document explains how the Flutter MVVM app connects to the Node.js Express backend, end to end.

---

## 1. Network configuration

The base URL lives in a single constant:

**`flutter_app/lib/core/constants/app_constants.dart`**

```dart
static const String baseUrl = 'http://10.0.2.2:5001';
```

| Target | Value to use |
|--------|--------------|
| Android emulator | `http://10.0.2.2:5001` (default) |
| iOS simulator | `http://localhost:5001` |
| Physical device | Your computer's LAN IP, e.g. `http://192.168.1.42:5001` |

> `10.0.2.2` is the Android emulator's alias for the host machine's `localhost`.
> Make sure the backend is running on the same port before starting the app.

---

## 2. Dependency injection (wiring)

**`flutter_app/lib/main.dart`** assembles the entire object graph once:

```dart
final prefs = await SharedPreferences.getInstance();          // token storage
final apiClient = ApiClient(http.Client(), prefs);            // HTTP + Bearer token
final authRepository = AuthRepositoryImpl(apiClient, prefs);  // auth data source
final taskRepository = TaskRepositoryImpl(apiClient);         // task data source

runApp(MultiProvider(providers: [
  ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
  ChangeNotifierProvider(create: (_) => TaskViewModel(taskRepository)),
], child: const TaskManagerApp()));
```

This is the **Composition Root** — ViewModels depend on repository *interfaces*, so the implementation can be swapped (e.g. a mock repository for tests) without touching the UI.

---

## 3. Request flow (example: login)

1. **View** (`LoginScreen`) calls `viewModel.login(email, password)`.
2. **ViewModel** (`AuthViewModel.login`) sets `isLoading = true`, calls `_authRepository.login(...)`.
3. **Repository** (`AuthRepositoryImpl.login`) calls `_apiClient.post('/api/auth/login', body: {...})`.
4. **ApiClient** attaches headers, POSTs to the Express backend, throws typed `AppException` on non-2xx.
5. Repository parses JSON into `AuthResponse`, saves the JWT + user to `SharedPreferences`.
6. ViewModel sets `isLoading = false`, notifies listeners → UI rebuilds.
7. On success, the screen navigates to `/home`.

---

## 4. Authentication & the Bearer token

- After register/login, the JWT is stored in `SharedPreferences` under key `auth_token`.
- `ApiClient` reads the token on every request and sends `Authorization: Bearer <token>`.
- `AuthViewModel.isLoggedIn` reflects whether a token exists.
- `HomeScreen` redirects to `/login` if `!isLoggedIn`.
- `AuthViewModel.logout()` clears the token and navigates back to login.

---

## 5. MVVM data flow (tasks)

```
HomeScreen (View)
      │ listens to
      ▼
TaskViewModel (ChangeNotifier) ── isLoading / error / tasks
      │ calls
      ▼
TaskRepository (interface) ───────▶ TaskRepositoryImpl
      │                                  │
      ▼                                  ▼
ApiClient ◄────────────────────────── Express /api/tasks
      │
      ▼
HTTP response (JSON) → parsed to List<TaskModel>
```

The View never talks to the network directly — it only observes the ViewModel and triggers actions.

---

## 6. Error handling across the boundary

| Layer | Mechanism |
|-------|-----------|
| Express backend | `AppError` + global `errorHandler` middleware → consistent JSON `{ success:false, message }` |
| Flutter `ApiClient` | Maps status codes → typed exceptions (`BadRequestException`, `FetchDataException`, etc.) |
| Flutter Repository | Lets exceptions propagate to the ViewModel |
| Flutter ViewModel | Catches exceptions, calls `setError(message)` → UI shows the error |
| Flutter View | Reads `viewModel.error` and displays it |

Example error the user sees: "Invalid email or password", "Task not found", or "Network error: ...".

---

## 7. Running both together

```bash
# Terminal 1 — backend
cd backend
cp .env.example .env
npm install
npm run dev      # http://localhost:5001

# Terminal 2 — flutter
cd flutter_app
flutter pub get
flutter run      # ensure baseUrl matches backend port
```

Then register a user, add tasks, and verify they persist across app restarts (token is stored locally).

---

## 8. Swapping to a real database

The backend currently uses an in-memory store (`backend/models/store.js`). To use MongoDB:

1. Set `MONGODB_URI=mongodb://...` in `backend/.env`
2. Add Mongoose models for `User` and `Task`
3. Replace the store functions in `controllers/*` with Mongoose queries

No Flutter changes are required — the API contract stays the same.

---

## 9. File map (integration-relevant)

| File | Role |
|------|------|
| `backend/app.js` | Express middleware + route mounting |
| `backend/controllers/authController.js` | register/login/me handlers |
| `backend/controllers/taskController.js` | task CRUD handlers |
| `backend/middleware/auth.js` | JWT protect middleware |
| `flutter_app/lib/core/constants/app_constants.dart` | API base URL + endpoints |
| `flutter_app/lib/core/network/api_client.dart` | HTTP client + Bearer token + error mapping |
| `flutter_app/lib/data/repositories/auth_repository_impl.dart` | Auth API implementation |
| `flutter_app/lib/data/repositories/task_repository_impl.dart` | Task API implementation |
| `flutter_app/lib/presentation/viewmodels/auth_viewmodel.dart` | Auth UI state |
| `flutter_app/lib/presentation/viewmodels/task_viewmodel.dart` | Task UI state |
| `flutter_app/lib/presentation/screens/login_screen.dart` | Login UI |
| `flutter_app/lib/presentation/screens/home_screen.dart` | Task list UI |
