---
name: install-manager
description: Installs the as-claude manager dashboard into a project
user_invocable: true
---

Zainstaluj dashboard managera w projekcie. Manager to sesja Claude Code, która daje interaktywny przegląd wszystkich zadań ze wszystkich repozytoriów.

## Instrukcje

### Krok 1: Ustal ścieżkę projektu

Zapytaj użytkownika o ścieżkę do projektu managera. Domyślna: `E:/Repository/as-claude-manager`.

Sprawdź czy katalog istnieje. Jeśli nie — utwórz go (`mkdir -p`).

### Krok 2: Sprawdź istniejącą konfigurację

Sprawdź czy projekt ma już:
- `.claude/settings.json` — jeśli tak, przeczytaj go.
- `CLAUDE.md` — jeśli tak, zapytaj użytkownika czy nadpisać.

Poinformuj użytkownika o stanie projektu i zapytaj czy kontynuować.

### Krok 3: CLAUDE.md

Przeczytaj źródłowy `E:/Repository/as-claude/manager/CLAUDE.md`.

- **Brak `CLAUDE.md`** — skopiuj `manager/CLAUDE.md` jako nowy plik.
- **`CLAUDE.md` istnieje** — porównaj z aktualnym `manager/CLAUDE.md`. Jeśli się różni — zapytaj użytkownika czy nadpisać. Jeśli identyczny — pomiń.

### Krok 4: Skonfiguruj hooki i uprawnienia

Przeczytaj `.claude/settings.json` (jeśli istnieje).

**Nowa instalacja** (brak hooków i uprawnień):

Utwórz `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Read(<projekt>/**)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash E:/Repository/as-claude/manager/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

Jeśli plik istnieje z inną konfiguracją — dopisz sekcje `permissions` i `hooks`, nie nadpisuj reszty.

**Aktualizacja** (hook/permissions już istnieją):

Sprawdź czy:
- Hook SessionStart wskazuje na `bash E:/Repository/as-claude/manager/hooks/session-start.sh`
- `permissions.allow` zawiera `Read(<projekt>/**)`

Zaktualizuj co trzeba, nie ruszaj pozostałych ustawień.

### Krok 5: Zarejestruj managera

Dodaj ścieżkę projektu do `E:/Repository/as-claude/managers.txt` (jedna ścieżka na linię). Nie dodawaj duplikatów. Utwórz plik jeśli nie istnieje.

### Krok 6: Potwierdzenie

Wyświetl użytkownikowi podsumowanie:
```
Zainstalowano manager w: <ścieżka>
  - CLAUDE.md: skopiowany
  - hooks: SessionStart
  - permissions: Read(<projekt>/**)
  - Zarejestrowany w managers.txt
```
