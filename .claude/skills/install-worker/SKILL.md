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
- `.claude/skills/codex-review2/SKILL.md` — jeśli tak, instalacja może być aktualizacją.
- `CLAUDE.md` — jeśli tak, zapytaj użytkownika czy nadpisać czy dopisać na początku.

Poinformuj użytkownika o stanie projektu i zapytaj czy kontynuować.

### Krok 3: Skopiuj skille

```bash
mkdir -p "<projekt>/.claude/skills/status-update"
mkdir -p "<projekt>/.claude/skills/status-end"
mkdir -p "<projekt>/.claude/skills/codex-review2"
cp "E:/Repository/as-claude/worker/skills/status-update/SKILL.md" "<projekt>/.claude/skills/status-update/SKILL.md"
cp "E:/Repository/as-claude/worker/skills/status-end/SKILL.md" "<projekt>/.claude/skills/status-end/SKILL.md"
cp "E:/Repository/as-claude/worker/skills/codex-review2/SKILL.md" "<projekt>/.claude/skills/codex-review2/SKILL.md"
```

### Krok 4: CLAUDE.md

Przeczytaj źródłowy `E:/Repository/as-claude/worker/CLAUDE.md`.

- **Brak `CLAUDE.md`** — skopiuj `worker/CLAUDE.md` jako nowy plik.
- **`CLAUDE.md` bez sekcji workera** — dopisz zawartość `worker/CLAUDE.md` na początku pliku, oddzielając od reszty linią `---`.
- **`CLAUDE.md` z sekcją workera** (aktualizacja) — porównaj sekcję workera (treść przed pierwszym `---` separatorem) z aktualnym źródłem `worker/CLAUDE.md`. Jeśli się różni — zastąp sekcję workera aktualną wersją, zachowując treść projektu po `---`. Jeśli identyczna — pomiń.

### Krok 5: Skonfiguruj hooki

Przeczytaj `.claude/settings.json` (jeśli istnieje).

**Nowa instalacja** (brak hooków SessionStart):

Dodaj do `.claude/settings.json`:

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

Jeśli plik istnieje z inną konfiguracją — dopisz sekcję `hooks`, nie nadpisuj reszty.

**Aktualizacja** (hook SessionStart już istnieje):

Sprawdź czy command hooka SessionStart wskazuje na `bash E:/Repository/as-claude/worker/hooks/session-start.sh`. Jeśli ścieżka jest inna — zaktualizuj. Nie ruszaj pozostałych hooków ani ustawień.

### Krok 6: Zarejestruj workera

Dodaj ścieżkę projektu do `E:/Repository/as-claude/workers.txt` (jedna ścieżka na linię). Nie dodawaj duplikatów — sprawdź czy ścieżka już tam jest.

### Krok 7: Potwierdzenie

Wyświetl użytkownikowi podsumowanie:
```
Zainstalowano worker w: <ścieżka>
  - skills: status-update, status-end, codex-review2
  - CLAUDE.md: skopiowany/dopisany
  - hooks: SessionStart
  - Zarejestrowany w workers.txt
```
