---
name: update-agents
description: Checks and updates all worker and manager installations
user_invocable: true
---

Sprawdź wszystkie zainstalowane workery i managery, porównaj ich pliki ze źródłami w tym repo i zaktualizuj przestarzałe.

## Instrukcje

### Krok 1: Wczytaj listy instalacji

Przeczytaj:
- `E:/Repository/as-claude/workers.txt` — ścieżki workerów
- `E:/Repository/as-claude/managers.txt` — ścieżki managerów

Pomiń puste linie i komentarze (`#`). Jeśli plik nie istnieje — pomiń (0 instalacji tego typu).

### Krok 2: Sprawdź workerów

Dla każdego workera z `workers.txt`:

1. Sprawdź czy katalog istnieje. Jeśli nie — oznacz jako `MISSING`.
2. Porównaj pliki ze źródłem:

| Plik w projekcie | Źródło / oczekiwana wartość |
|---|---|
| `.claude/skills/status-update/SKILL.md` | `worker/skills/status-update/SKILL.md` |
| `.claude/skills/status-end/SKILL.md` | `worker/skills/status-end/SKILL.md` |
| `.claude/skills/codex-review2/SKILL.md` | `worker/skills/codex-review2/SKILL.md` |
| `CLAUDE.md` | `worker/CLAUDE.md` |
| `.claude/settings.json` (hook SessionStart) | command: `bash E:/Repository/as-claude/worker/hooks/session-start.sh` |

Dla skilli i CLAUDE.md: uruchom `diff -q` aby sprawdzić różnice. Jeśli plik nie istnieje — oznacz jako `MISSING`.

**Uwaga o CLAUDE.md:** Projekt może mieć własne treści w CLAUDE.md dopisane po sekcji workera. Porównuj tylko zawartość do pierwszego `---` separatora (lub do końca jeśli brak separatora). Użyj `diff` na pierwszych N liniach odpowiadających długości źródłowego worker/CLAUDE.md.

**Uwaga o settings.json:** Nie porównuj całego pliku — sprawdź tylko czy hook SessionStart wskazuje na prawidłową ścieżkę. Inne hooki i ustawienia projektu mogą się różnić i to jest OK.

### Krok 3: Sprawdź managerów

Dla każdego managera z `managers.txt`:

1. Sprawdź czy katalog istnieje. Jeśli nie — oznacz jako `MISSING`.
2. Porównaj:

| Plik w projekcie | Źródło / oczekiwana wartość |
|---|---|
| `CLAUDE.md` | `manager/CLAUDE.md` |
| `.claude/skills/workers-status/SKILL.md` | `manager/skills/workers-status/SKILL.md` |
| `.claude/settings.json` (hook SessionStart) | command: `bash E:/Repository/as-claude/manager/hooks/session-start.sh` |
| `.claude/settings.json` (permissions) | `Read(<projekt>/**)` w `permissions.allow` |

**Uwaga o settings.json:** Sprawdź tylko hook SessionStart i permissions — nie porównuj reszty pliku.

### Krok 4: Raport

Wyświetl tabelę:

```
## Workerzy

| Projekt | status-update | status-end | codex-review2 | CLAUDE.md | settings.json | Status |
|---------|--------------|------------|---------------|-----------|---------------|--------|
| E:/Repository/nginx-servers | OK | OK | OK | OUTDATED | OK | wymaga aktualizacji |
| E:/Repository/my-app | MISSING | MISSING | MISSING | OK | OK | wymaga aktualizacji |

## Managerzy

| Projekt | workers-status | CLAUDE.md | settings.json | Status |
|---------|----------------|-----------|---------------|--------|
| E:/Repository/as-claude-manager | OK | OK | OK | aktualny |
```

Statusy plików: `OK` (identyczny), `OUTDATED` (różni się), `MISSING` (brak pliku).

### Krok 5: Aktualizacja

Jeśli są przestarzałe instalacje, zapytaj użytkownika:
> Zaktualizować wszystkie przestarzałe pliki? (tak/nie/wybierz)

- **tak** — zaktualizuj wszystkie `OUTDATED` i `MISSING` pliki
- **nie** — zakończ bez zmian
- **wybierz** — pozwól użytkownikowi wskazać które projekty zaktualizować

Zasady aktualizacji:
- **Skille workerów** — kopiuj ze źródeł (nadpisz).
- **Skille managerów** — kopiuj ze źródeł (nadpisz).
- **CLAUDE.md workera** — jeśli projekt ma dodatkowe treści po `---`, zachowaj je — nadpisz tylko sekcję workera na początku.
- **CLAUDE.md managera** — nadpisz całość (manager nie ma treści projektu).
- **settings.json** — zaktualizuj tylko ścieżkę hooka SessionStart (i permissions dla managera). Nie ruszaj pozostałych ustawień projektu.

### Krok 6: Potwierdzenie

```
Zaktualizowano X plik(ów) w Y projekt(ach).
```
