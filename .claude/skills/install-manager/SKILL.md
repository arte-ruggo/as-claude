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

### Krok 3: Skopiuj CLAUDE.md

```bash
cp "E:/Repository/as-claude/manager/CLAUDE.md" "<projekt>/CLAUDE.md"
```

### Krok 4: Skonfiguruj hooki i uprawnienia

Utwórz/zaktualizuj `.claude/settings.json`:

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

Jeśli `.claude/settings.json` już istnieje — dopisz sekcje `permissions` i `hooks`, nie nadpisuj.

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
