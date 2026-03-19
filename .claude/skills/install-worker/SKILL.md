---
name: install-worker
description: Installs the as-claude worker system into a project
user_invocable: true
---

Zainstaluj system worker w projekcie. Worker to sesja Claude Code, która śledzi swoje zadania w centralnym repozytorium managera.

## Instrukcje

### Krok 1: Ustal ścieżkę projektu

Zapytaj użytkownika o ścieżkę do projektu, w którym chce zainstalować workera. Ścieżka musi być absolutna (np. `E:/Repository/my-app`).

Sprawdź czy katalog istnieje. Jeśli nie — poinformuj użytkownika i zakończ.

### Krok 2: Sprawdź istniejącą konfigurację

Sprawdź czy projekt ma już:
- `.claude/settings.json` — jeśli tak, przeczytaj go. Będziesz dopisywał hooki, nie nadpisywał całego pliku.
- `.claude/skills/status-update/SKILL.md` — jeśli tak, instalacja może być aktualizacją.
- `CLAUDE.md` — jeśli tak, zapytaj użytkownika czy nadpisać czy dopisać na początku.

Poinformuj użytkownika o stanie projektu i zapytaj czy kontynuować.

### Krok 3: Skopiuj skille

```bash
mkdir -p "<projekt>/.claude/skills/status-update"
mkdir -p "<projekt>/.claude/skills/status-end"
cp "E:/Repository/as-claude/worker/skills/status-update/SKILL.md" "<projekt>/.claude/skills/status-update/SKILL.md"
cp "E:/Repository/as-claude/worker/skills/status-end/SKILL.md" "<projekt>/.claude/skills/status-end/SKILL.md"
```

### Krok 4: Skopiuj CLAUDE.md

Jeśli projekt nie ma `CLAUDE.md`:
```bash
cp "E:/Repository/as-claude/worker/CLAUDE.md" "<projekt>/CLAUDE.md"
```

Jeśli projekt ma `CLAUDE.md` — dopisz zawartość `worker/CLAUDE.md` na początku pliku, oddzielając od reszty linią `---`.

### Krok 5: Skonfiguruj hooki

Zapytaj użytkownika:
> Chcesz hook Stop (przypomnienie o /status-update po każdej odpowiedzi)? Zalecane: nie — instrukcje w CLAUDE.md wystarczą.

**Bez Stop hooka** — dodaj do `.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash E:/Repository/as-claude/worker/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Ze Stop hookiem** — dodaj również sekcję `"Stop"`:
```json
"Stop": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "bash E:/Repository/as-claude/worker/hooks/update-status.sh"
      }
    ]
  }
]
```

Jeśli `.claude/settings.json` już istnieje z inną konfiguracją — dopisz sekcję `hooks` do istniejącego JSON-a, nie nadpisuj.

### Krok 6: Zarejestruj workera

Dodaj ścieżkę projektu do `E:/Repository/as-claude/workers.txt` (jedna ścieżka na linię). Nie dodawaj duplikatów — sprawdź czy ścieżka już tam jest.

### Krok 7: Potwierdzenie

Wyświetl użytkownikowi podsumowanie:
```
Zainstalowano worker w: <ścieżka>
  - skills: status-update, status-end
  - CLAUDE.md: skopiowany/dopisany
  - hooks: SessionStart [+ Stop]
  - Zarejestrowany w workers.txt
```
