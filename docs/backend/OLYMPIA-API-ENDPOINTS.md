# Olympia API — Endpoints Reference

**Version:** 1.0
**Date:** 2026-06-18
**Audience:** Backend developers implementing the Olympia `.NET 8` Web API, and frontend developers integrating against it.
**Companion document:** [OLYMPIA-API-MODELS.md](OLYMPIA-API-MODELS.md) — the data shapes referenced here (every `XxxDto`, `XxxRequest`).

---

## How to read this document

This describes the **HTTP surface**: every route, who can call it, what it accepts, what it returns, and the business rules it enforces. For the exact JSON shape of any DTO named here, open the [models document](OLYMPIA-API-MODELS.md).

Each endpoint is documented as:

- **Method + path** and **access level**
- **Purpose** — one line
- **Request** — query params, route params, and body DTO
- **Response** — the wrapped DTO and status code
- **Rules** — validation, authorization scoping, side effects

---

## Global concepts

### Base URL

```
Production : https://api.olympia.ma/api
Local dev  : http://localhost:5000/api
```
Every path below is relative to `/api`.

### Authentication

All endpoints require a JWT **except** those marked **Public**.

```
Authorization: Bearer {accessToken}
```

- **Access token** — HS256 JWT, 60-minute lifetime. Claims: `sub` (userId), `email`, `role`, `zone`, `name`.
- **Refresh token** — opaque 256-bit string, 30-day lifetime, stored server-side.
- On a `401`, clients call [`POST /auth/refresh`](#post-authrefresh) to get a new pair, then retry the original request once.

### Authorization & role scoping

| Role | What they see |
|------|---------------|
| **Commercial** | Only **their own** tâches, demandes, and dashboard (data where `CommercialId == sub`). Filtering is enforced **server-side** — never trust a client-supplied filter for ownership. |
| **Admin** | **Everything** company-wide. Admin-only endpoints are marked `[Authorize(Roles = "Admin")]`. |

> Scoping rule: for list/detail endpoints, a Commercial requesting another user's resource gets **404** (not 403) — we don't reveal that the resource exists.

### Response envelopes

Everything is wrapped (see [models §3](OLYMPIA-API-MODELS.md#3-envelope--shared-dtos)):

```jsonc
// single resource
{ "data": { … } }

// paginated list
{ "data": [ … ], "total": 42, "page": 1, "pageSize": 20 }

// any error
{ "error": { "message": "…", "code": 404 } }
```

### Pagination

All list endpoints accept:

| Param | Default | Notes |
|-------|---------|-------|
| `page` | `1` | 1-based |
| `pageSize` | `20` | clamp to a max (e.g. 100) server-side |

`total` in the response is the **full count of matching rows**, not the page size — clients use it to compute "load more".

### Errors

`ExceptionMiddleware` converts exceptions to the error envelope:

| Exception thrown in service layer | HTTP | Body |
|-----------------------------------|------|------|
| `ValidationException` | **400** | `message` + `fieldErrors` |
| `UnauthorizedException` | **401** | `message` |
| `NotFoundException` | **404** | `message` |
| `BusinessRuleException` | **422** | `message` |
| anything else | **500** | generic "Erreur interne du serveur" |

---

## Endpoint summary

| # | Method | Path | Access |
|---|--------|------|--------|
| 1 | POST | `/auth/login` | Public |
| 2 | POST | `/auth/refresh` | Public |
| 3 | GET | `/auth/me` | JWT |
| 4 | POST | `/auth/logout` | JWT |
| 5 | GET | `/dashboard/stats` | JWT |
| 6 | GET | `/taches` | JWT |
| 7 | POST | `/taches` | JWT |
| 8 | GET | `/taches/{id}` | JWT |
| 9 | PUT | `/taches/{id}` | JWT |
| 10 | PUT | `/taches/{id}/statut` | JWT |
| 11 | DELETE | `/taches/{id}` | JWT |
| 12 | GET | `/demandes` | JWT |
| 13 | POST | `/demandes` | JWT |
| 14 | GET | `/demandes/{id}` | JWT |
| 15 | PUT | `/demandes/{id}/statut` | JWT (Admin for validation) |
| 16 | DELETE | `/demandes/{id}` | Admin |
| 17 | GET | `/clients/search` | JWT |
| 18 | GET | `/clients/{code}` | JWT |
| 19 | GET | `/users` | Admin |
| 20 | POST | `/users` | Admin |
| 21 | GET | `/users/{id}` | Admin |
| 22 | PUT | `/users/{id}` | Admin |
| 23 | DELETE | `/users/{id}` | Admin |
| 24 | POST | `/upload` | JWT |

---

## Auth

### POST /auth/login
**Public.** Exchange credentials for a token pair.

- **Request body:** `LoginRequest`
- **Response:** `200` → `LoginResponse` (access + refresh + `expiresIn` + `user`)
- **Rules:**
  - Look up user by `Email`; verify password with BCrypt.
  - Bad email/password → **401** `UnauthorizedException("Email ou mot de passe incorrect")`. Use the **same** message for both to avoid user enumeration.
  - Inactive user (`IsActive = false`) → **401**.
  - On success: issue access token, generate + persist a refresh token row.

```jsonc
// → 200
{ "data": {
    "accessToken": "eyJhbGciOi…",
    "refreshToken": "f3c1…",
    "expiresIn": 3600,
    "user": { "id": "…", "email": "admin@olympia.com", "role": "Admin", … }
}}
```

### POST /auth/refresh
**Public.** Rotate an existing refresh token for a fresh pair.

- **Request body:** `RefreshRequest`
- **Response:** `200` → `LoginResponse`
- **Rules:**
  - Token must exist, not be revoked, not be expired → else **401**.
  - **Rotation:** mark the old token `IsRevoked = true`, insert a new one, return the new pair. (One-time use; a replayed token is rejected.)

### GET /auth/me
**JWT.** Return the current user's profile.

- **Response:** `200` → `ApiResponse<UserDto>` (resolved from the `sub` claim).

### POST /auth/logout
**JWT.** Revoke the caller's active refresh token.

- **Request body:** `RefreshRequest` (the refresh token to revoke) — or revoke all for the user.
- **Response:** `204 No Content`.

---

## Dashboard

### GET /dashboard/stats
**JWT.** One call returns everything the dashboard renders.

- **Query:** `periode=month|quarter|year` (default `month`)
- **Response:** `200` → `ApiResponse<DashboardStatsDto>`
- **Rules:**
  - **Scope by role:** Commercial → only their own CA/tâches/demandes; Admin → company-wide.
  - `performers` (the leaderboard) is populated **only for Admin**; empty for Commercial.
  - CA figures come from **Divalto** via `IDivaltoClient.GetCAStats(divaltoUserId, periode)`, cached 5 min. Tâche/demande counters come from our SQL Server.
  - `objectifPct = ca / user.ObjectifCA * 100` (guard divide-by-zero → 0).
  - Trends are `% change vs the previous comparable period`.

```jsonc
// GET /dashboard/stats?periode=month  → 200 (Admin)
{ "data": {
    "ca": 125000, "caIntern": 45000, "caExtern": 55000, "caOlybat": 25000, "caTrend": 8.5,
    "demandes": 42, "demandesTrend": 12.0,
    "taches": 18, "tachesTrend": -3.0, "tachesEnCours": 5,
    "visites": 34, "visitesTrend": 6.0, "objectifPct": 67.5,
    "caPoints": [ { "label": "Jan", "value": 95000 } ],
    "demandesByType": [ { "type": "1", "typeLabel": "Échantillons", "count": 8, "perc": 19.0 } ],
    "performers": [ { "name": "Taha Mejdoub", "zone": "Casablanca Nord", "ca": "125 000 MAD", "caVal": 125000, "objectif": 500000 } ]
}}
```

---

## Tâches

A tâche is a field task/visit. **No validation workflow** — the owner moves the status freely. See lifecycle in [models §1.2](OLYMPIA-API-MODELS.md#12-tachestatut).

### GET /taches
**JWT.** Paginated list, scoped to the caller (Admin sees all).

- **Query:** `page`, `pageSize`, `statut` (optional filter: `en_cours_traitement|realisee|annulee`)
- **Response:** `200` → `PagedResult<TacheDto>`
- **Rules:** Commercial sees only `CommercialId == sub`. Newest first.

### POST /taches
**JWT.** Create a task.

- **Request body:** `CreateTacheRequest`
- **Response:** `201` → `ApiResponse<TacheDto>`
- **Rules:**
  - Server sets `Statut = en_cours_traitement`, generates `Numero` (`T-{year}-{seq:D4}`), sets `CommercialId`/`CommercialNom` from the JWT.
  - Validation failure → **400** with `fieldErrors`.

### GET /taches/{id}
**JWT.** Single task.

- **Response:** `200` → `ApiResponse<TacheDto>`; not found / not owned → **404**.

### PUT /taches/{id}
**JWT.** Update editable fields (partial).

- **Request body:** `UpdateTacheRequest` (all fields optional)
- **Response:** `200` → `ApiResponse<TacheDto>`
- **Rules:** only the owner (or Admin) may edit. `Numero`, `Statut`, `CommercialId` are **not** editable here.

### PUT /taches/{id}/statut
**JWT.** Change status only.

- **Request body:** `UpdateStatutTacheRequest` (`realisee` | `annulee`)
- **Response:** `200` → `ApiResponse<TacheDto>`
- **Rules:** invalid status value → **422**.

### DELETE /taches/{id}
**JWT.** Hard delete.

- **Response:** `204`; not found / not owned → **404**.

---

## Demandes

A demande is a typed business request with a **7-state validation lifecycle** and an audit trail. See [models §1.4](OLYMPIA-API-MODELS.md#14-demandestatut).

### GET /demandes
**JWT.** Paginated list, scoped to the caller.

- **Query:** `page`, `pageSize`, `statut` (optional), `typeDemande` (optional, 1–9)
- **Response:** `200` → `PagedResult<DemandeDto>`
- **Rules:** Commercial sees only their own. `historique` may be empty/omitted in the list payload (it's returned in full by the detail endpoint). Newest first.

### POST /demandes
**JWT.** Create a demande.

- **Request body:** `CreateDemandeRequest`
- **Response:** `201` → `ApiResponse<DemandeDto>`
- **Rules:**
  - Server sets `Statut = nouvelle`, generates `Numero` (`D-{year}-{seq:D4}`), sets owner from JWT.
  - **Auto-inserts the first `historique` entry** (e.g. `Action = "Demande créée"`, `Auteur = user name`).
  - `TypeDemande` must be 1–9 → else **400**. `FormData` is stored as JSON as-is.

### GET /demandes/{id}
**JWT.** Single demande **with full `historique[]`** (ordered newest-first).

- **Response:** `200` → `ApiResponse<DemandeDto>`; not found / not owned → **404**.

### PUT /demandes/{id}/statut
**JWT** (Admin required for validation transitions). Advance the lifecycle.

- **Request body:** `UpdateStatutDemandeRequest` (`statut` target + optional `commentaire`)
- **Response:** `200` → `ApiResponse<DemandeDto>`
- **Rules — transition matrix (enforced in `DemandeService`):**

  | Current | Allowed next | Who |
  |---------|--------------|-----|
  | `nouvelle` | `en_cours_validation` | Commercial (owner) |
  | `en_cours_validation` | `validee` \| `refusee` | **Admin** |
  | `validee` | `en_cours_traitement` | **Admin** |
  | `en_cours_traitement` | `traitee` | **Admin** |
  | `traitee` | `cloturee` | **Admin** |
  | `refusee`, `cloturee` | — (terminal) | — |

  - Any transition not in the matrix → **422** `BusinessRuleException("Statut invalide pour cette transition")`.
  - A Commercial attempting an Admin-only transition → **403** (or **422**, pick one and be consistent).
  - **Side effect:** every successful change appends a `historique` entry (action + auteur + optional commentaire).

### DELETE /demandes/{id}
**Admin only.** Hard delete (cascades `DemandeHistorique`).

- **Response:** `204`; not found → **404**.

---

## Clients (Divalto proxy)

Read-only lookup of ERP client data. The backend calls Divalto, caches, and returns the clean `ClientDto`. **Frontends never call Divalto directly.**

### GET /clients/search
**JWT.** Type-ahead client search.

- **Query:** `q` (search term, min length e.g. 2)
- **Response:** `200` → `ApiResponse<List<ClientDto>>`
- **Rules:** delegates to `IDivaltoClient.SearchClients(q)`, cached **30s** per `q`. Divalto unreachable (circuit open) → **422** `BusinessRuleException("Service Divalto temporairement indisponible")`.

### GET /clients/{code}
**JWT.** Fetch one client by Divalto code.

- **Response:** `200` → `ApiResponse<ClientDto>`; unknown code → **404**.
- **Rules:** cached **2 min** per `code`.

---

## Users (Admin only)

Team management. All endpoints require `[Authorize(Roles = "Admin")]`.

### GET /users
- **Query:** `page`, `pageSize`, `role` (optional `Admin|Commercial`), `status` (optional `active|inactive`)
- **Response:** `200` → `PagedResult<UserDto>`

### POST /users
- **Request body:** `CreateUserRequest`
- **Response:** `201` → `ApiResponse<UserDto>`
- **Rules:** `Email` must be unique → duplicate returns **400** `fieldErrors: { email: "Email déjà utilisé" }`. Password is BCrypt-hashed before storage. Never echo the password back.

### GET /users/{id}
- **Response:** `200` → `ApiResponse<UserDto>`; unknown → **404**.

### PUT /users/{id}
- **Request body:** `UpdateUserRequest` (partial; include `password` only to reset it; `isActive` to enable/disable)
- **Response:** `200` → `ApiResponse<UserDto>`

### DELETE /users/{id}
- **Response:** `204`; unknown → **404**.
- **Rule:** prevent an Admin from deleting their **own** account (→ **422**) to avoid lockout.

---

## Upload (stubbed in v1)

### POST /upload
**JWT.** Accepts a file, returns a URL.

- **Request:** `multipart/form-data`, field `file`.
- **Response:** `200` → `ApiResponse<UploadResponse>` with a **placeholder URL** (real storage is out of scope for v1).
- **Rule:** validate content-type/size even while stubbed, so the contract doesn't change when real storage lands.

---

## CORS

Native mobile HTTP does **not** trigger CORS — this policy is for the **web admin** only.

```csharp
builder.Services.AddCors(o => o.AddPolicy("OlympiaPolicy", p => p
    .WithOrigins("https://admin.olympia.ma", "http://localhost:5173")
    .AllowAnyHeader()
    .AllowAnyMethod()
    .AllowCredentials()));
```

---

## Integration notes for frontend developers

- **One parse path:** every success body has `data`; every failure has `error`. Branch on which key is present.
- **Refresh flow:** on `401`, call `/auth/refresh` once, store the new pair, retry the failed request. If refresh also fails → force re-login.
- **Status strings are the contract:** never translate statuses client-side from integers — use the exact strings (`en_cours_traitement`, etc.). For demande *types*, use the `typeLabel` the server provides.
- **Pagination:** use `total` (not the returned array length) to decide whether more pages exist.
- **Ownership is server-enforced:** a Commercial cannot widen their scope by tampering with query params — the server ignores client ownership claims and uses the JWT `sub`.
```
