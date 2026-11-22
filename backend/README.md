# Backend — Node.js + Express Task Manager API

A lightweight, extensible REST API with JWT authentication and user-scoped tasks. Designed to integrate with the Flutter MVVM app in `flutter_app/`.

## Structure

```
backend/
├── app.js            # Express app: middleware, routes, error handlers
├── server.js         # Entry point: starts HTTP server
├── .env.example      # Copy to .env and adjust
├── package.json
├── controllers/
│   ├── authController.js   # register, login, getMe
│   └── taskController.js   # task CRUD (user-scoped)
├── middleware/
│   ├── auth.js         # JWT protect
│   ├── validate.js     # express-validator rules + result handler
│   └── errorHandler.js # 404 + global error handler
├── models/
│   └── store.js        # in-memory users/tasks (swap for MongoDB)
├── routes/
│   ├── authRoutes.js
│   └── taskRoutes.js
├── services/
│   └── tokenService.js # JWT sign/verify
└── utils/
    ├── AppError.js     # operational error class
    └── asyncHandler.js # async route wrapper
```

## Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | No | Health check |
| POST | `/api/auth/register` | No | Create account |
| POST | `/api/auth/login` | No | Get JWT token |
| GET | `/api/auth/me` | Yes | Current user profile |
| GET | `/api/tasks` | Yes | List my tasks |
| POST | `/api/tasks` | Yes | Create task |
| PATCH | `/api/tasks/:id` | Yes | Update task (partial) |
| DELETE | `/api/tasks/:id` | Yes | Delete task |

See `API_DOCS.md` for full request/response schemas.

## Install & run

```bash
npm install
cp .env.example .env
npm run dev      # nodemon (auto-reload)
# or
npm start        # plain node
```

Default port: `5001` (set `PORT` in `.env`).

## Database

By default the app uses an **in-memory store** (`models/store.js`), so it runs out of the box with no database.

To use **MongoDB**:
1. Set `MONGODB_URI=mongodb://localhost:27017/taskmanager` in `.env`
2. Add Mongoose `User` and `Task` models
3. Replace store calls in the controllers with Mongoose queries

## Scripts

- `npm start` — production start
- `npm run dev` — development with nodemon
