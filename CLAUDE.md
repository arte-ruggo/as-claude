To jest repozytorium narzędziowe systemu **as-claude** — systemu zarządzania zadaniami dla wielu instancji Claude Code.

**Przeczytaj `README.md`** jeśli potrzebujesz pełnego kontekstu (architektura, flow pracy, format plików zadań, instrukcja instalacji).

## Skrót

System dzieli instancje Claude Code na **workerów** (sesje w projektach, korzystają z hooka SessionStart wstrzykującego session_id i nazwę repo oraz ze skilli włączonych w repo) i **managera** (read-only dashboard zadań w `as-claude-manager/`). To repo zawiera hooki obu ról i rejestr instalacji. **Skille nie żyją tutaj** — każdy skill (także `install-worker`, `install-manager`, `update-agents`, `codex-review2`, `workers-status`) istnieje wyłącznie w `ar-skills` i jest włączany wpisem `"<skill>@skills-dir": true` w `.claude/settings.json` projektu. Nigdy nie kopiuj skilla do `.claude/skills/` żadnego repo. Nie pracujesz tu nad kodem projektu. Twoja rola to administracja systemu:

## Dostępne skille

- `/install-worker` — zainstaluj system worker w projekcie
- `/install-manager` — zainstaluj dashboard manager w projekcie
- `/update-agents` — sprawdź i zaktualizuj wszystkie instalacje (workerów i managerów)

## Struktura repo

- `worker/` — hooki workerów (`hooks/session-start.sh`, template `config/global-settings.json`)
- `manager/` — hooki managera i `CLAUDE.md` kopiowany do projektu managera
- `workers.txt` — lista zainstalowanych workerów (ścieżki projektów)
- `managers.txt` — lista zainstalowanych managerów
- `.claude/settings.json` — włączenia skilli administracyjnych tego repo
