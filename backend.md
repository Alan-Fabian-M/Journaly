# Backend Spec — Journaly

Documento de referencia que traduce los modelos Dart ya implementados (hoy servidos por `MockJournalRepository` / `MockPsychologistRepository`) a un diseño de base de datos y endpoints REST reales. No es código ejecutable — es el contrato que debería cumplir un futuro `ApiJournalRepository` / `ApiPsychologistRepository`.

## 1. Overview

La app Flutter ya está preparada para esto: `JournalRepository` y `PsychologistRepository` ([lib/features/journal/data/journal_repository.dart](lib/features/journal/data/journal_repository.dart), [lib/features/psychologists/data/psychologist_repository.dart](lib/features/psychologists/data/psychologist_repository.dart)) son interfaces abstractas; hoy las implementa una versión mock en memoria. El día que exista backend, basta con:

1. Crear `ApiJournalRepository implements JournalRepository` y `ApiPsychologistRepository implements PsychologistRepository`, usando el cliente `Dio` ya scaffoldeado en [lib/shared/data/api_client.dart](lib/shared/data/api_client.dart).
2. Inyectarlas en `main.dart` en vez de las mocks.

Ningún provider ni pantalla necesita cambiar.

La transcripción de voz **no** pasa por el backend (corre on-device vía `speech_to_text`, ver `SpeechRecognitionService`) — el backend solo recibe texto ya transcrito.

## 2. Modelo de datos

### `users`
Mínima, solo para asociar journals a alguien. Auth completa queda fuera de este documento (ver sección 5), pero el resto del schema asume que existe.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| email | text, unique | |
| created_at | timestamptz | |

### `journals`
Mapea 1:1 a `Journal` ([journal.dart](lib/features/journal/models/journal.dart)).

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK → users.id) | |
| entry_type | enum('voz','texto') | de `JournalEntryType` |
| transcript | text | texto completo (ya transcrito) |
| short_summary | text | podría generarse en backend en vez de truncar en cliente |
| duration_seconds | int, nullable | solo si entry_type = 'voz' |
| created_at | timestamptz | reemplaza `date` |

### `emotion_results`
Mapea 1:1 a `EmotionResult` ([emotion_result.dart](lib/features/journal/models/emotion_result.dart)). Relación 1:1 con `journals` (cada journal analizado tiene exactamente un resultado).

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| journal_id | uuid (FK → journals.id, unique) | |
| emotion_type | enum('estres','ansiedad','tristeza','calma','alegria') | de `EmotionType` |
| feedback_text | text | |
| intensity | float (0.0–1.0) | confianza/intensidad del modelo |
| created_at | timestamptz | |

### `emotion_suggestions` (tabla hija de `suggestions: List<String>`)

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| emotion_result_id | uuid (FK → emotion_results.id) | |
| suggestion | text | |
| position | int | para preservar el orden mostrado en UI |

### `emotion_keywords` (tabla hija de `keywords: List<String>`)

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| emotion_result_id | uuid (FK → emotion_results.id) | |
| keyword | text | |

### `coping_actions`
Catálogo reutilizable de acciones/técnicas de afrontamiento — independiente de cualquier journal puntual. Es la pieza que falta hoy para que las sugerencias dejen de ser texto suelto y se puedan matchear/rankear/medir.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| title | text | ej. "Respiración 4-7-8" |
| description | text | |
| category | enum('respiracion','cognitivo','fisico','social','ayuda_profesional') | |
| embedding | vector, nullable | opcional, ver sección 3.1 (matching por embeddings) |
| created_at | timestamptz | |

### `coping_action_emotion_tags`
Tabla puente N:M entre `coping_actions` y `EmotionType`, con peso y rango de intensidad aplicable — es la que permite el filtrado por reglas.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| coping_action_id | uuid (FK → coping_actions.id) | |
| emotion_type | enum('estres','ansiedad','tristeza','calma','alegria') | mismo enum que `emotion_results.emotion_type` |
| weight | float | relevancia de esta acción para esta emoción |
| min_intensity | float (0.0–1.0) | |
| max_intensity | float (0.0–1.0) | |

### `journal_action_recommendations`
Snapshot histórico de qué acciones del catálogo se recomendaron a qué journal y con qué score. `emotion_suggestions` (arriba) sigue siendo el texto libre que ve el usuario; esta tabla es la capa estructurada detrás, la que hace posible medir y mejorar el matching con el tiempo.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| journal_id | uuid (FK → journals.id) | |
| coping_action_id | uuid (FK → coping_actions.id) | |
| score | float | resultado del matching (peso de regla o similitud de embedding) |
| rank | int | posición mostrada al usuario |
| created_at | timestamptz | |

### `action_feedback`
El feedback loop: si el usuario marca que una recomendación le sirvió o no. Sin esto no hay forma de mejorar el matching con datos reales.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| journal_action_recommendation_id | uuid (FK → journal_action_recommendations.id) | |
| user_id | uuid (FK → users.id) | |
| was_helpful | boolean, nullable | null = sin responder |
| created_at | timestamptz | |

### `psychologists`
Mapea a `Psicologo` ([psicologo.dart](lib/features/psychologists/models/psicologo.dart)).

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| name | text | |
| photo_url | text, nullable | `initials` se puede derivar en cliente a partir de `name` |
| specialty | text | |
| rating | float | |
| bio | text | |

### `psychologist_availability_slots` (tabla hija de `availability: List<String>`)

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| psychologist_id | uuid (FK → psychologists.id) | |
| start_time | timestamptz | reemplaza el string libre ("Lun 10:00") |
| label | text | valor legible para mostrar tal cual en UI |
| is_booked | boolean, default false | |

### `appointments` — Fase 2 (hoy "Agendar consulta" es un botón sin funcionalidad)

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK → users.id) | |
| psychologist_id | uuid (FK → psychologists.id) | |
| slot_id | uuid (FK → psychologist_availability_slots.id) | |
| status | enum('pending','confirmed','cancelled') | |
| created_at | timestamptz | |

### Relaciones

```
users 1───* journals 1───1 emotion_results 1───* emotion_suggestions
                       │                    └──* emotion_keywords
                       └──* journal_action_recommendations *───1 coping_actions
                                                   │
                                                   └──* action_feedback

coping_actions 1───* coping_action_emotion_tags

psychologists 1───* psychologist_availability_slots

users 1───* appointments *───1 psychologists
                          *───1 psychologist_availability_slots
```

## 3. Motor de matching emoción → acción

Dos enfoques, de más simple a más avanzado — el primero alcanza para tener recomendaciones reales desde el día uno del backend:

1. **Basado en reglas + personalización por usuario (implementado).** Al analizar un journal: tomar `emotion_results.emotion_type` + `intensity`, filtrar `coping_action_emotion_tags` donde `emotion_type` coincida y `intensity` caiga entre `min_intensity`/`max_intensity`. A cada candidato se le suma un ajuste por usuario calculado a partir de su propio `action_feedback` histórico con esa misma `coping_action` (`+0.15` por cada 👍, `-0.15` por cada 👎, acumulable), se ordena por ese score ajustado y se toma el top-N — guardado en `journal_action_recommendations` con el score ya personalizado. Implementación: `app/services/matching.py`. Es determinístico, fácil de depurar, y mejora con el uso sin necesitar reentrenar nada.
2. **Basado en embeddings (evolución posterior, no implementado).** Comparar el embedding del journal/keywords contra `coping_actions.embedding` por similitud coseno (ej. Postgres + `pgvector`), para capturar matches semánticos que las reglas fijas no cubren (ej. un journal sobre "conflicto con mi pareja" matcheando con una acción etiquetada "social" aunque las palabras no coincidan literalmente). Requiere generar embeddings tanto del journal como del catálogo con el mismo modelo.

### Contexto histórico en la detección de emoción (implementado)

`POST /journals` ya no analiza cada journal aislado: antes de llamar a `emotion_analysis.analyze()`, el router junta los últimos 5 journals del usuario (fecha + emoción + resumen) y se los pasa como contexto al LLM (solo cuando hay `OPENROUTER_API_KEY` configurada — la heurística de iteración 1 ignora este contexto, no lo necesita). Esto le permite al modelo notar patrones ("este usuario reporta estrés seguido los lunes") en vez de tratar cada entrada como si no supiera nada de la persona. Implementación: `analyze(text, history=...)` en `app/services/emotion_analysis.py`.

## 4. Endpoints REST

### Journals — consumidos por `JournalRepository`

**`GET /journals`**
Reemplaza `JournalRepository.fetchJournals()`. Historial del usuario autenticado, más reciente primero.

Response `200`:
```json
[
  {
    "id": "j1",
    "date": "2026-09-16T10:30:00Z",
    "entryType": "voz",
    "transcript": "...",
    "shortSummary": "...",
    "durationSeconds": 96,
    "emotionResult": {
      "emotion": "ansiedad",
      "feedbackText": "...",
      "intensity": 0.58,
      "keywords": ["llamada de trabajo", "respiración"],
      "suggestions": ["...", "..."]
    }
  }
]
```

**`POST /journals`**
Reemplaza `JournalRepository.submitJournal({text, entryType})`. El cliente manda el texto ya transcrito (voz on-device o escrito); el backend corre el análisis de emoción (hoy mockeado por `AiJournalService`, acá pasaría a ser una llamada real a un LLM) y persiste todo.

Request:
```json
{ "text": "...", "entryType": "voz", "durationSeconds": 96 }
```
Response `201`: mismo shape que un item de `GET /journals`, más `recommendedActions` (resultado del motor de matching de la sección 3):
```json
{
  "id": "j9",
  "...": "...",
  "recommendedActions": [
    { "id": "ca1", "recommendationId": "jar1", "title": "Respiración 4-7-8", "score": 0.91 },
    { "id": "ca7", "recommendationId": "jar2", "title": "Escribir 3 prioridades para mañana", "score": 0.76 }
  ]
}
```
`id` es el id del `coping_action` (catálogo); `recommendationId` es el id de `journal_action_recommendations` — el que espera `POST /recommendations/{id}/feedback` más abajo. Son distintos a propósito: sin `recommendationId` el cliente no tendría forma de dar feedback sobre una recomendación puntual.

**`GET /journals/{id}`**
Detalle de un journal puntual (útil para el bottom sheet de detalle sin depender de que ya esté en memoria).

### Coping actions — catálogo y feedback del matching

**`GET /coping-actions`**
Catálogo completo (uso administrativo/debug, para mantener el contenido sin tocar el motor de matching).

**`POST /recommendations/{id}/feedback`**
Body: `{ "wasHelpful": true }`. `id` es el `journal_action_recommendations.id`. Alimenta `action_feedback`.

### Psychologists — consumidos por `PsychologistRepository`

**`GET /psychologists?q=&specialty=`**
Reemplaza `PsychologistRepository.fetchPsicologos()`. Los query params habilitan el buscador que hoy es solo visual en `PsychologistsScreen`.

Response `200`:
```json
[
  {
    "id": "p1",
    "name": "Dra. Camila Reyes",
    "specialty": "Ansiedad y estrés",
    "rating": 4.8,
    "bio": "...",
    "availability": ["Lun 10:00", "Mié 15:00", "Vie 09:00"]
  }
]
```

**`GET /psychologists/{id}`**
Detalle (usado por `PsychologistDetailScreen`).

**`GET /psychologists/{id}/slots`**
Response `200`: `[{ "id": "s1", "label": "Lun 10:00", "isBooked": false }]`. No documentado originalmente, pero necesario: `GET /psychologists` solo expone `availability` como texto (para calzar con `Psicologo.availability: List<String>` del cliente Flutter), así que sin este endpoint no habría forma de conseguir un `slotId` real para reservar. Se agrega aparte en vez de cambiar el shape de `GET /psychologists`, para no romper el modelo Dart existente.

### Appointments — Fase 2

**`POST /appointments`**
Body: `{ "psychologistId": "p1", "slotId": "s1" }` — `slotId` sale de `GET /psychologists/{id}/slots`. Le daría funcionalidad real al botón "Agendar consulta". Responde `409` si el slot ya está reservado.

**`GET /appointments`**
Citas del usuario autenticado.

### Auth — prerequisito, fuera de alcance inmediato

Necesario únicamente para que `user_id` tenga sentido en el resto del schema. No se diseña el flujo completo acá.

- `POST /auth/register`
- `POST /auth/login` → retorna token (JWT o similar) que el cliente adjuntaría en `ApiClient` como header `Authorization`.

## 5. Integración con el cliente Flutter

**Ya conectado** (`main.dart` inyecta las implementaciones reales en vez de las mocks):

| Backend | Cliente |
|---|---|
| `GET /journals`, `POST /journals` | [lib/features/journal/data/api_journal_repository.dart](lib/features/journal/data/api_journal_repository.dart) — `ApiJournalRepository implements JournalRepository` |
| `GET /psychologists` | [lib/features/psychologists/data/api_psychologist_repository.dart](lib/features/psychologists/data/api_psychologist_repository.dart) — `ApiPsychologistRepository implements PsychologistRepository` |
| Ambas | usan `ApiClient.instance` (Dio) de [lib/shared/data/api_client.dart](lib/shared/data/api_client.dart); `baseUrl` apunta a `http://127.0.0.1:8000` — ver comentarios en ese archivo para emulador/dispositivo físico/Wi-Fi |
| `POST /journals` (análisis de emoción) | ya no corre en el cliente — `AiJournalService` mock quedó sin usar, el análisis lo hace el backend (heurística u OpenRouter/gpt-4o-mini) |
| — | `SpeechRecognitionService` (transcripción) **no cambia** — sigue corriendo on-device, el backend nunca recibe audio |
| `MockJournalRepository`/`MockPsychologistRepository` | siguen existiendo en el código (no se borraron), pero ya no están wireadas en `main.dart` — útiles si querés volver a modo mock (ej. para UI sin backend corriendo) |
| `recommendedActions` en `POST /journals` | `Journal.recommendedActions: List<RecommendedAction>` ([recommended_action.dart](lib/features/journal/models/recommended_action.dart)), mostrado en `SummaryScreen` y en el bottom sheet de detalle vía `RecommendedActionsSection` |
| `POST /recommendations/{id}/feedback` | botones 👍/👎 en `RecommendedActionsSection`, vía `JournalProvider.submitActionFeedback` → `JournalRepository.submitActionFeedback` |

**Todavía no conectado**:

| Backend | Nota |
|---|---|
| `GET /journals/{id}` | sin uso en el cliente por ahora (las pantallas trabajan con la lista completa en memoria) |
| `GET /coping-actions` | sin contraparte en el cliente todavía (no hay pantalla de catálogo) |
| `GET/POST /appointments`, `GET /psychologists/{id}/slots` | el botón "Agendar consulta" de `PsychologistDetailScreen` sigue siendo un `SnackBar` placeholder, no llama al backend |

`JournalProvider` y `PsychologistProvider` no necesitaron cambios de forma — ya recibían el repositorio por constructor, solo cambió qué implementación se inyecta en `main.dart`. Ambos envuelven su carga inicial en try/catch para no romper la UI si el backend no está corriendo.

## 6. Stack tecnológico recomendado

| Pieza | Recomendación | Por qué |
|---|---|---|
| Backend framework | **Python + FastAPI** | Liviano para levantar rápido los endpoints ya documentados; el ecosistema Python (numpy, sentence-transformers, clientes de OpenAI/Anthropic) es el más directo si el análisis de emoción o el matching por embeddings se implementan in-house en vez de solo consumir una API externa. |
| Base de datos | **PostgreSQL** | Encaja con el schema relacional (FKs, enums) ya diseñado arriba; con la extensión **pgvector** soporta directamente las columnas `embedding` de `coping_actions`/journals cuando se pase al matching semántico (sección 3, enfoque 2), sin migrar de motor de base de datos. |
| Alternativa | Node.js + NestJS | Razonable si el equipo prefiere TypeScript end-to-end por consistencia; pierde un poco de fricción en la parte de embeddings/ML frente a Python. |
| Auth (cuando se implemente) | JWT vía `POST /auth/login`, verificado en cada endpoint que dependa de `user_id` | Estándar, compatible con `Authorization: Bearer <token>` desde `ApiClient` (Dio) en el cliente. |

Este stack es una recomendación, no una decisión cerrada — el schema y los endpoints documentados arriba no dependen de esta elección específica.

## 7. Fuera de alcance explícito

- Diseño completo de autenticación (OAuth, recuperación de contraseña, roles).
- El modelo de IA en sí (qué LLM, prompts, fine-tuning) — el backend solo se documenta como el punto que **orquesta** esa llamada.
- Pagos/facturación de consultas con psicólogos.
- Notificaciones push para recordatorios de journaling o citas.
- Implementación del feedback UI (👍/👎) en el cliente Flutter — solo se documentó el endpoint que lo recibiría.
