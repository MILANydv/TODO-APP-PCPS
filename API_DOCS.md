# Task Manager API — Reference

Base URL: `http://localhost:5001` (configured via `PORT` in `backend/.env`)

All JSON bodies. Errors return:
```json
{ "success": false, "message": "..." }
```
Validation errors return an `errors` array.

---

## Auth

### POST /api/auth/register
Register a new user.

**Body**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | ✅ | max 50 chars |
| email | string | ✅ | valid email |
| password | string | ✅ | min 6 chars |

**Success (201)**
```json
{ "success": true, "token": "<JWT>", "user": { "id": "...", "name": "...", "email": "..." } }
```

**Example**
```bash
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Milan","email":"milan@test.com","password":"password123"}'
```

---

### POST /api/auth/login
Log in and receive a JWT.

**Body**
| Field | Type | Required |
|-------|------|----------|
| email | string | ✅ |
| password | string | ✅ |

**Success (200)** — same shape as register.

---

### GET /api/auth/me
Get the logged-in user profile. Requires `Authorization: Bearer <token>`.

**Success (200)**
```json
{ "success": true, "user": { "id": "...", "name": "...", "email": "..." } }
```

---

## Tasks

All task routes require authentication (`Authorization: Bearer <token>`). Tasks are scoped to the logged-in user.

### GET /api/tasks
List all tasks for the current user.

**Success (200)**
```json
{ "success": true, "count": 1, "data": [ { ...task } ] }
```

### POST /api/tasks
Create a task.

**Body**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| title | string | ✅ | max 100 chars |
| description | string | ❌ | max 500 chars |

**Success (201)** — `{ "success": true, "data": { ...task } }`

### PATCH /api/tasks/:id
Partially update a task. Only fields you send are changed.

**Body** (all optional)
| Field | Type |
|-------|------|
| title | string (max 100) |
| description | string (max 500) |
| isCompleted | boolean |

**Success (200)** — updated task.

### DELETE /api/tasks/:id
Delete a task.

**Success (200)** — `{ "success": true, "message": "Task deleted" }`

---

## Task object

```json
{
  "id": 1,
  "userId": "1795270989099",
  "title": "Learn Flutter",
  "description": "Build MVVM app",
  "isCompleted": false,
  "createdAt": "2026-11-21T14:23:09.280Z"
}
```

---

## Status codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 400 | Validation / bad request |
| 401 | Unauthorized (missing/invalid token) |
| 404 | Not found |
| 500 | Server error |

---

## Environment variables (`backend/.env`)

| Variable | Default | Notes |
|----------|---------|-------|
| PORT | 5001 | Backend HTTP port |
| NODE_ENV | development | logging level |
| JWT_SECRET | super-secret-dev-key-change-me | **change in production** |
| JWT_EXPIRES_IN | 7d | token expiry |
| MONGODB_URI | (none) | optional; in-memory store used if omitted |
