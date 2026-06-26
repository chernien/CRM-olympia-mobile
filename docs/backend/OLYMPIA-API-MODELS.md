# Olympia API — Data Models Reference

**Version:** 1.0
**Date:** 2026-06-18
**Audience:** Backend developers building the Olympia `.NET 8` Web API.
**Companion document:** [OLYMPIA-API-ENDPOINTS.md](OLYMPIA-API-ENDPOINTS.md) — describes *how* these models are exposed over HTTP. This document describes *what the shapes are*.

---

## How to read this document

This is the single source of truth for **every data shape** in the Olympia backend. It is organized in the order you build them:

1. **Enums** — the controlled vocabularies (statuses, roles, types). Build these first; everything references them.
2. **Persistence entities** — the C# classes mapped to SQL Server tables. These are *internal* — they never leave the server as-is.
3. **DTOs** — the classes actually serialized to/from clients. Grouped by feature area.
4. **Divalto integration models** — internal shapes used only by the ERP client. Frontends never see these.

> **Golden rule:** Entities are for the database. DTOs are for the wire. **Never serialize an entity directly** — always map to a DTO. This keeps `PasswordHash` out of responses and lets the database schema evolve without breaking clients.

### Wire conventions (apply to every DTO)

| Concern | Rule |
|---------|------|
| **Casing** | JSON is `camelCase`. A C# property `CodeClient` becomes `"codeClient"`. Configure once: `options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase`. |
| **Dates/times** | ISO‑8601 UTC. `DateTime` → `"2026-06-18T09:30:00Z"`. `DateOnly` → `"2026-06-18"`. |
| **Money** | `decimal`, MAD, no currency symbol. `125000.50`. |
| **Enums** | Serialized as their **French business string** (see each enum), not as integers — except `DemandeType`, which is an `int 1..9`. |
| **Nulls** | Optional fields are nullable (`?`) and omitted or `null` in JSON. |
| **IDs** | `Guid` (UUID v4/sequential), serialized as a lowercase hyphenated string. |

---

## 1. Enums (controlled vocabularies)

These are the *business statuses* the mobile app and web admin already use for colour-coding and labels. **The wire strings below are a contract — do not rename them.**

Configure global string serialization with explicit values:

```csharp
// Program.cs — applies to all enums marked with [JsonConverter(typeof(JsonStringEnumConverter))]
builder.Services
    .AddControllers()
    .AddJsonOptions(o => o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
```

### 1.1 UserRole

Two roles. Drives authorization and dashboard scope.

```csharp
public enum UserRole
{
    Admin,        // web admin — validates demandes, manages team, sees company-wide data
    Commercial    // mobile field sales — sees only their own data
}
```
Wire values: `"Admin"`, `"Commercial"`.

### 1.2 TacheStatut

A task (tâche) has **3 states**. There is *no validation workflow* — the commercial moves it freely.

```csharp
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum TacheStatut
{
    [EnumMember(Value = "en_cours_traitement")] EnCoursTraitement, // default on creation (yellow)
    [EnumMember(Value = "realisee")]            Realisee,          // done after field visit (green)
    [EnumMember(Value = "annulee")]             Annulee            // cancelled (grey)
}
```

### 1.3 TachePriorite

```csharp
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum TachePriorite
{
    [EnumMember(Value = "normale")] Normale,
    [EnumMember(Value = "haute")]   Haute,
    [EnumMember(Value = "urgente")] Urgente
}
```

### 1.4 DemandeStatut

A demande has a **7-state lifecycle** with a validation gate. The allowed transitions are enforced server-side (see [Endpoints doc → Demandes](OLYMPIA-API-ENDPOINTS.md#demandes)).

```csharp
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum DemandeStatut
{
    [EnumMember(Value = "nouvelle")]            Nouvelle,          // just created (blue)
    [EnumMember(Value = "en_cours_validation")] EnCoursValidation, // submitted, awaiting admin (orange)
    [EnumMember(Value = "validee")]             Validee,           // admin approved (green)
    [EnumMember(Value = "refusee")]             Refusee,           // admin rejected — TERMINAL (red)
    [EnumMember(Value = "en_cours_traitement")] EnCoursTraitement, // being processed (yellow)
    [EnumMember(Value = "traitee")]             Traitee,           // processed (dark green)
    [EnumMember(Value = "cloturee")]            Cloturee           // closed — TERMINAL (grey)
}
```

**Lifecycle diagram:**
```
nouvelle ──► en_cours_validation ──► validee ──► en_cours_traitement ──► traitee ──► cloturee
                      │
                      └──► refusee
```

### 1.5 DemandeType

The kind of request. **Serialized as an integer 1–9**, not a string. The server also returns a `typeLabel` (French) in `DemandeDto` so clients don't hard-code the mapping.

```csharp
public enum DemandeType
{
    Echantillons                = 1, // Échantillons (up to 3 refs)
    EchantillonsAvecApplication = 2, // Échantillons avec application
    Reclamation                 = 3, // Réclamation (4-phase stepper)
    NouveauClient               = 4, // Nouveau client
    RenouvellementShowroom      = 5, // Renouvellement showroom
    Formation                   = 6, // Formation
    AssistanceChantier          = 7, // Assistance chantier
    MachineATeinter             = 8, // Machine à teinter
    AccessoiresMarketing        = 9  // Accessoires marketing
}
```

| Value | Label (`typeLabel`) |
|-------|---------------------|
| 1 | Échantillons |
| 2 | Échantillons avec application |
| 3 | Réclamation |
| 4 | Nouveau client |
| 5 | Renouvellement showroom |
| 6 | Formation |
| 7 | Assistance chantier |
| 8 | Machine à teinter |
| 9 | Accessoires marketing |

### 1.6 CaSegment

Revenue (chiffre d'affaires) is split into three commercial segments. Used in the dashboard breakdown.

```csharp
public enum CaSegment
{
    Intern,   // internal sales (blue)
    Extern,   // distributor sales (purple)
    Olybat    // specific product line (yellow)
}
```
Wire values: `"intern"`, `"extern"`, `"olybat"`.

---

## 2. Persistence Entities (SQL Server)

These classes map 1:1 to tables in **our own** SQL Server database. They hold the data Olympia *owns*: users, auth tokens, tasks, demandes, and their history. **CA stats and client records are NOT stored here** — they come live from Divalto.

> Entities are never returned directly from a controller. Map them to DTOs (§4).

### 2.1 User → table `Users`

```csharp
public class User
{
    public Guid    Id { get; set; }                 // PK, sequential GUID
    public string  Email { get; set; } = "";        // unique, login identity
    public string  PasswordHash { get; set; } = ""; // BCrypt (work factor 12) — NEVER serialized
    public string  Nom { get; set; } = "";          // last name
    public string  Prenom { get; set; } = "";       // first name
    public UserRole Role { get; set; }
    public string? Zone { get; set; }               // sales territory, e.g. "Casablanca Nord"
    public decimal? ObjectifCA { get; set; }        // annual revenue target (MAD)
    public string? DivaltoUserId { get; set; }      // links this user to a Divalto identity (for CA scope)
    public bool    IsActive { get; set; } = true;   // soft-disable without deleting
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public ICollection<RefreshToken> RefreshTokens { get; set; } = [];
}
```

| Column | Type | Constraints |
|--------|------|-------------|
| Id | `UNIQUEIDENTIFIER` | PK, `DEFAULT NEWSEQUENTIALID()` |
| Email | `NVARCHAR(256)` | UNIQUE, NOT NULL |
| PasswordHash | `NVARCHAR(512)` | NOT NULL |
| Nom | `NVARCHAR(100)` | NOT NULL |
| Prenom | `NVARCHAR(100)` | NOT NULL |
| Role | `NVARCHAR(20)` | NOT NULL — `Admin` \| `Commercial` |
| Zone | `NVARCHAR(100)` | NULL |
| ObjectifCA | `DECIMAL(18,2)` | NULL |
| DivaltoUserId | `NVARCHAR(100)` | NULL |
| IsActive | `BIT` | NOT NULL DEFAULT 1 |
| CreatedAt | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |
| UpdatedAt | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |

### 2.2 RefreshToken → table `RefreshTokens`

One row per issued refresh token. Rotation revokes the old row and inserts a new one.

```csharp
public class RefreshToken
{
    public Guid     Id { get; set; }
    public Guid     UserId { get; set; }
    public User?    User { get; set; }
    public string   Token { get; set; } = "";       // 256-bit random, unique
    public DateTime ExpiresAt { get; set; }         // creation + 30 days
    public bool     IsRevoked { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

| Column | Type | Constraints |
|--------|------|-------------|
| Id | `UNIQUEIDENTIFIER` | PK |
| UserId | `UNIQUEIDENTIFIER` | FK → `Users.Id`, CASCADE DELETE |
| Token | `NVARCHAR(512)` | UNIQUE, NOT NULL |
| ExpiresAt | `DATETIME2` | NOT NULL |
| IsRevoked | `BIT` | NOT NULL DEFAULT 0 |
| CreatedAt | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |

### 2.3 Tache → table `Taches`

A field task/visit. `Numero` is generated server-side (`T-{year}-{seq:D4}`).

```csharp
public class Tache
{
    public Guid     Id { get; set; }
    public string   Numero { get; set; } = "";        // e.g. "T-2026-0001"
    public string   CodeClient { get; set; } = "";    // Divalto client code (denormalized snapshot)
    public string   NomClient { get; set; } = "";
    public string?  Adresse { get; set; }
    public string   Description { get; set; } = "";
    public DateOnly DatePrevue { get; set; }          // planned visit date
    public TachePriorite Priorite { get; set; }
    public TacheStatut   Statut { get; set; }
    public string?  PieceJointeUrl { get; set; }      // optional attachment
    public Guid?    CommercialId { get; set; }        // owner (FK → Users)
    public string?  CommercialNom { get; set; }       // denormalized for display
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

| Column | Type | Constraints |
|--------|------|-------------|
| Id | `UNIQUEIDENTIFIER` | PK DEFAULT `NEWSEQUENTIALID()` |
| Numero | `NVARCHAR(20)` | UNIQUE, NOT NULL |
| CodeClient | `NVARCHAR(50)` | NOT NULL |
| NomClient | `NVARCHAR(200)` | NOT NULL |
| Adresse | `NVARCHAR(500)` | NULL |
| Description | `NVARCHAR(MAX)` | NOT NULL |
| DatePrevue | `DATE` | NOT NULL |
| Priorite | `NVARCHAR(20)` | NOT NULL |
| Statut | `NVARCHAR(30)` | NOT NULL |
| PieceJointeUrl | `NVARCHAR(1000)` | NULL |
| CommercialId | `UNIQUEIDENTIFIER` | FK → `Users.Id`, SET NULL |
| CommercialNom | `NVARCHAR(200)` | NULL |
| CreatedAt | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |
| UpdatedAt | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |

**Indexes:** `IX_Taches_CommercialId`, `IX_Taches_Statut`, `IX_Taches_DatePrevue`.

### 2.4 Demande → table `Demandes`

A business request of one of 9 types. Type-specific fields are stored as a **JSON blob** in `FormData` so the schema doesn't need 9 different column sets.

```csharp
public class Demande
{
    public Guid     Id { get; set; }
    public string   Numero { get; set; } = "";       // e.g. "D-2026-0001"
    public DemandeType   TypeDemande { get; set; }
    public DemandeStatut Statut { get; set; }
    public Guid?    CommercialId { get; set; }
    public string?  CommercialNom { get; set; }
    public string?  NomClient { get; set; }
    public string?  CodeClient { get; set; }
    public string?  FormData { get; set; }            // JSON: type-specific fields
    public string?  PiecesJointes { get; set; }       // JSON array of attachment URLs
    public string?  Commentaire { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public ICollection<DemandeHistorique> Historique { get; set; } = [];
}
```

| Column | Type | Constraints |
|--------|------|-------------|
| Id | `UNIQUEIDENTIFIER` | PK DEFAULT `NEWSEQUENTIALID()` |
| Numero | `NVARCHAR(20)` | UNIQUE, NOT NULL |
| TypeDemande | `INT` | NOT NULL — 1..9 |
| Statut | `NVARCHAR(40)` | NOT NULL |
| CommercialId | `UNIQUEIDENTIFIER` | FK → `Users.Id`, SET NULL |
| CommercialNom | `NVARCHAR(200)` | NULL |
| NomClient | `NVARCHAR(200)` | NULL |
| CodeClient | `NVARCHAR(50)` | NULL |
| FormData | `NVARCHAR(MAX)` | NULL (JSON) |
| PiecesJointes | `NVARCHAR(MAX)` | NULL (JSON array) |
| Commentaire | `NVARCHAR(MAX)` | NULL |
| CreatedAt | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |
| UpdatedAt | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |

**Indexes:** `IX_Demandes_CommercialId`, `IX_Demandes_Statut`, `IX_Demandes_TypeDemande`, `IX_Demandes_CreatedAt (DESC)`.

### 2.5 DemandeHistorique → table `DemandeHistorique`

An append-only audit trail per demande. One row is auto-inserted on creation, and one per status change.

```csharp
public class DemandeHistorique
{
    public Guid     Id { get; set; }
    public Guid     DemandeId { get; set; }
    public string   Action { get; set; } = "";        // e.g. "Demande créée", "Validée par admin"
    public string?  Auteur { get; set; }              // who performed it
    public DateTime DateAction { get; set; }
    public string?  Commentaire { get; set; }
}
```

| Column | Type | Constraints |
|--------|------|-------------|
| Id | `UNIQUEIDENTIFIER` | PK DEFAULT `NEWSEQUENTIALID()` |
| DemandeId | `UNIQUEIDENTIFIER` | FK → `Demandes.Id`, CASCADE DELETE |
| Action | `NVARCHAR(200)` | NOT NULL |
| Auteur | `NVARCHAR(200)` | NULL |
| DateAction | `DATETIME2` | NOT NULL DEFAULT `GETUTCDATE()` |
| Commentaire | `NVARCHAR(MAX)` | NULL |

**Index:** `IX_DemandeHistorique_DemandeId_Date (DemandeId, DateAction DESC)`.

### 2.6 Numéro generation

Use SQL sequences for collision-free numbering:

```sql
CREATE SEQUENCE TacheNumeroSeq   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE DemandeNumeroSeq START WITH 1 INCREMENT BY 1;
```
Format application-side: `T-{year}-{NEXT VALUE:D4}` → `T-2026-0001`; `D-{year}-{NEXT VALUE:D4}` → `D-2026-0001`. (v1: global sequences, no per-year reset.)

---

## 3. Envelope & shared DTOs

Every endpoint returns one of these two wrappers. This gives clients **one** parsing path for success and error.

```csharp
// Single resource → { "data": { … } }  OR  { "error": { … } }
public sealed class ApiResponse<T>
{
    public T?        Data  { get; init; }
    public ApiError? Error { get; init; }
}

// Paginated list → { "data": [ … ], "total": N, "page": P, "pageSize": S }
public sealed class PagedResult<T>
{
    public IReadOnlyList<T> Data     { get; init; } = [];
    public int              Total    { get; init; }   // total matching rows (not just this page)
    public int              Page     { get; init; }   // 1-based
    public int              PageSize { get; init; }
}

// The error object inside ApiResponse.Error
public sealed class ApiError
{
    public required string Message { get; init; }                 // human-readable, French
    public required int    Code    { get; init; }                 // mirrors HTTP status
    public IDictionary<string, string>? FieldErrors { get; init; } // present only on 400
}
```

---

## 4. Feature DTOs

DTOs are grouped by feature. Each maps to endpoints documented in [OLYMPIA-API-ENDPOINTS.md](OLYMPIA-API-ENDPOINTS.md).

### 4.1 Auth

```csharp
public sealed class LoginRequest
{
    [Required, EmailAddress] public string Email { get; init; } = "";
    [Required, MinLength(6)] public string Password { get; init; } = "";
}

public sealed class RefreshRequest
{
    [Required] public string RefreshToken { get; init; } = "";
}

public sealed class LoginResponse                  // returned by /login AND /refresh
{
    public required string  AccessToken  { get; init; }
    public required string  RefreshToken { get; init; }
    public required int     ExpiresIn    { get; init; }   // access token lifetime in seconds (3600)
    public required UserDto User         { get; init; }
}

public sealed class UserDto                        // safe projection of User — no PasswordHash
{
    public Guid     Id { get; init; }
    public string   Email { get; init; } = "";
    public string   Nom { get; init; } = "";
    public string   Prenom { get; init; } = "";
    public string   Role { get; init; } = "";          // "Admin" | "Commercial"
    public string?  Zone { get; init; }
    public decimal? ObjectifCA { get; init; }
}
```

### 4.2 Dashboard

A single rich DTO powers the whole dashboard. `Performers` is only filled for Admins.

```csharp
public sealed class DashboardStatsDto
{
    // Revenue
    public decimal Ca        { get; init; }   // total CA for the period
    public decimal CaIntern  { get; init; }
    public decimal CaExtern  { get; init; }
    public decimal CaOlybat  { get; init; }
    public double  CaTrend   { get; init; }   // % change vs previous period (e.g. 8.5 = +8.5%)

    // Activity counters
    public int     Demandes        { get; init; }
    public double  DemandesTrend   { get; init; }
    public int     Taches          { get; init; }
    public double  TachesTrend     { get; init; }
    public int     TachesEnCours   { get; init; }   // tasks currently en_cours_traitement
    public int     Visites         { get; init; }   // = tasks created (a visit is logged as a task)
    public double  VisitesTrend    { get; init; }
    public double  ObjectifPct     { get; init; }   // Ca / ObjectifCA * 100

    // Chart series
    public IReadOnlyList<CaPointDto>       CaPoints       { get; init; } = []; // CA over time
    public IReadOnlyList<DemandeByTypeDto> DemandesByType { get; init; } = []; // breakdown by type
    public IReadOnlyList<PerformerDto>     Performers     { get; init; } = []; // ADMIN ONLY — leaderboard
}

public sealed class CaPointDto
{
    public string  Label { get; init; } = "";   // "Jan", "Q1", "2026"…
    public decimal Value { get; init; }
}

public sealed class DemandeByTypeDto
{
    public string Type      { get; init; } = "";  // "1".."9" as string
    public string TypeLabel { get; init; } = "";  // "Échantillons"
    public int    Count     { get; init; }
    public double Perc      { get; init; }         // share of total, e.g. 19.0
}

public sealed class PerformerDto                   // one row in the admin leaderboard
{
    public string  Name     { get; init; } = "";
    public string  Zone     { get; init; } = "";
    public string  Ca       { get; init; } = "";   // pre-formatted display, "125 000 MAD"
    public decimal CaVal     { get; init; }         // raw numeric for sorting/bars
    public decimal Objectif  { get; init; }
}
```

### 4.3 Tâches

```csharp
public sealed class TacheDto                       // read model — mirrors Tache entity
{
    public Guid     Id { get; init; }
    public string   Numero { get; init; } = "";
    public string   CodeClient { get; init; } = "";
    public string   NomClient { get; init; } = "";
    public string?  Adresse { get; init; }
    public string   Description { get; init; } = "";
    public DateOnly DatePrevue { get; init; }
    public string   Priorite { get; init; } = "";   // normale|haute|urgente
    public string   Statut { get; init; } = "";      // en_cours_traitement|realisee|annulee
    public string?  PieceJointeUrl { get; init; }
    public Guid?    CommercialId { get; init; }
    public string?  CommercialNom { get; init; }
    public DateTime CreatedAt { get; init; }
    public DateTime UpdatedAt { get; init; }
}

public sealed class CreateTacheRequest
{
    [Required] public string   CodeClient { get; init; } = "";
    [Required] public string   NomClient { get; init; } = "";
    public string?  Adresse { get; init; }
    [Required] public string   Description { get; init; } = "";
    [Required] public DateOnly DatePrevue { get; init; }
    [Required] public string   Priorite { get; init; } = "";   // normale|haute|urgente
    public string?  PieceJointeUrl { get; init; }
    // SERVER SETS: Statut = en_cours_traitement, Numero (auto), CommercialId (from JWT)
}

public sealed class UpdateTacheRequest             // partial update — all optional
{
    public string?  NomClient { get; init; }
    public string?  Adresse { get; init; }
    public string?  Description { get; init; }
    public DateOnly? DatePrevue { get; init; }
    public string?  Priorite { get; init; }
    public string?  PieceJointeUrl { get; init; }
}

public sealed class UpdateStatutTacheRequest
{
    [Required] public string Statut { get; init; } = "";       // realisee | annulee
}
```

### 4.4 Demandes

```csharp
public sealed class DemandeDto
{
    public Guid     Id { get; init; }
    public string   Numero { get; init; } = "";
    public int      TypeDemande { get; init; }       // 1..9
    public string   TypeLabel { get; init; } = "";   // server-resolved French label
    public string   Statut { get; init; } = "";
    public Guid?    CommercialId { get; init; }
    public string?  CommercialNom { get; init; }
    public string?  NomClient { get; init; }
    public string?  CodeClient { get; init; }
    public JsonElement? FormData { get; init; }       // parsed type-specific fields
    public IReadOnlyList<string> PiecesJointes { get; init; } = []; // attachment URLs
    public string?  Commentaire { get; init; }
    public DateTime CreatedAt { get; init; }
    public DateTime UpdatedAt { get; init; }
    public IReadOnlyList<DemandeHistoriqueDto> Historique { get; init; } = []; // full on detail; may be empty on list
}

public sealed class DemandeHistoriqueDto
{
    public Guid     Id { get; init; }
    public string   Action { get; init; } = "";
    public string?  Auteur { get; init; }
    public DateTime DateAction { get; init; }
    public string?  Commentaire { get; init; }
}

public sealed class CreateDemandeRequest
{
    [Required, Range(1, 9)] public int TypeDemande { get; init; }
    public string?  NomClient { get; init; }
    public string?  CodeClient { get; init; }
    public JsonElement? FormData { get; init; }       // free-form, type-specific
    public IReadOnlyList<string>? PiecesJointes { get; init; }
    public string?  Commentaire { get; init; }
    // SERVER SETS: Statut = nouvelle, first Historique entry, Numero (auto), CommercialId (from JWT)
}

public sealed class UpdateStatutDemandeRequest
{
    [Required] public string Statut { get; init; } = "";       // target status — validated against transition rules
    public string? Commentaire { get; init; }                   // appended to the new historique entry
}
```

### 4.5 Clients (from Divalto, exposed read-only)

This is the **only** Divalto-sourced shape clients ever see. It is a *clean projection* — the messy raw Divalto fields are mapped away server-side (§5).

```csharp
public sealed class ClientDto
{
    public string  Code { get; init; } = "";        // Divalto client code — the primary key clients use
    public string  Nom { get; init; } = "";
    public string? Adresse { get; init; }
    public string? Ville { get; init; }
    public string? Telephone { get; init; }
    public string? Email { get; init; }
    public string? Segment { get; init; }            // intern|extern|olybat
}
```

### 4.6 Users (admin management)

```csharp
public sealed class CreateUserRequest
{
    [Required, EmailAddress] public string Email { get; init; } = "";
    [Required, MinLength(8)] public string Password { get; init; } = ""; // hashed server-side
    [Required] public string  Nom { get; init; } = "";
    [Required] public string  Prenom { get; init; } = "";
    [Required] public string  Role { get; init; } = "";   // Admin | Commercial
    public string?  Zone { get; init; }
    public decimal? ObjectifCA { get; init; }
    public string?  DivaltoUserId { get; init; }
}

public sealed class UpdateUserRequest              // partial — all optional
{
    public string?  Nom { get; init; }
    public string?  Prenom { get; init; }
    public string?  Role { get; init; }
    public string?  Zone { get; init; }
    public decimal? ObjectifCA { get; init; }
    public string?  DivaltoUserId { get; init; }
    public bool?    IsActive { get; init; }
    public string?  Password { get; init; }        // present only to reset the password
}
```
Reads return `UserDto` (§4.1).

### 4.7 Upload (stubbed in v1)

```csharp
public sealed class UploadResponse
{
    public string Url { get; init; } = "";          // v1 returns a placeholder URL
}
```

---

## 5. Divalto integration models (server-internal)

> **These never reach any frontend.** They exist only inside `Olympia.Infrastructure` so the ERP client can talk to Divalto and map the result into the clean DTOs above. When the real Divalto API contract is known, **only this section's mappings change** — the public DTOs (§4) stay stable, so frontends never break.

```csharp
public interface IDivaltoClient
{
    Task<List<ClientDto>> SearchClients(string q, CancellationToken ct = default);
    Task<ClientDto?>      GetClientByCode(string code, CancellationToken ct = default);
    Task<CaStatsDto>      GetCAStats(string? divaltoUserId, string periode, CancellationToken ct = default);
}

// CA figures returned by Divalto, mapped into DashboardStatsDto
public sealed class CaStatsDto
{
    public decimal Total  { get; init; }
    public decimal Intern { get; init; }
    public decimal Extern { get; init; }
    public decimal Olybat { get; init; }
    public IReadOnlyList<CaPointDto> Points { get; init; } = [];  // time buckets for the chart
}

// Raw Divalto client payload — ASSUMED shape. Adjust field names to the real ERP response.
internal sealed class DivaltoClientRaw
{
    public string  CodeTiers { get; init; } = "";     // → ClientDto.Code
    public string  RaisonSociale { get; init; } = ""; // → ClientDto.Nom
    public string? Adresse1 { get; init; }            // → ClientDto.Adresse
    public string? Ville { get; init; }               // → ClientDto.Ville
    public string? Tel { get; init; }                 // → ClientDto.Telephone
    public string? Mail { get; init; }                // → ClientDto.Email
    public string? Categorie { get; init; }           // → ClientDto.Segment (mapped)
}
```

**Mapping note:** keep the raw→DTO mapping in one place (e.g. a `DivaltoMapper`). The categorie→segment mapping (e.g. `"INT" → intern`) is the kind of thing that will be wrong until real Divalto data is in hand — isolate it so it's a one-line fix.

---

## 6. Build order checklist

1. ☐ Enums (§1)
2. ☐ Entities + EF Core configurations + migration (§2)
3. ☐ SQL sequences for `Numero` (§2.6)
4. ☐ Envelope DTOs (§3)
5. ☐ Feature DTOs (§4)
6. ☐ Divalto internal models + mapper (§5)
7. ☐ Wire up endpoints → see [OLYMPIA-API-ENDPOINTS.md](OLYMPIA-API-ENDPOINTS.md)
