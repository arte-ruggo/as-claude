To jest repozytorium narzędziowe systemu **as-claude** — systemu zarządzania zadaniami dla wielu instancji Claude Code.

**Przeczytaj `README.md`** jeśli potrzebujesz pełnego kontekstu (architektura, flow pracy, format plików zadań, instrukcja instalacji).

## Skrót

System dzieli instancje Claude Code na **workerów** (sesje w projektach, korzystają ze współdzielonych skilli i hooka SessionStart wstrzykującego session_id i nazwę repo) i **managera** (read-only dashboard zadań w `as-claude-manager/`). To repo zawiera źródła obu ról — hooki i skille — oraz narzędzia do instalacji i synchronizacji. Nie pracujesz tu nad kodem projektu. Twoja rola to administracja systemu:

## Dostępne skille

- `/install-worker` — zainstaluj system worker w projekcie
- `/install-manager` — zainstaluj dashboard manager w projekcie
- `/update-agents` — sprawdź i zaktualizuj wszystkie instalacje (workerów i managerów)

## Struktura repo

- `worker/` — pliki źródłowe dla workerów (hooks, skills)
- `manager/` — pliki źródłowe dla managera (hooks, skills, CLAUDE.md)
- `workers.txt` — lista zainstalowanych workerów (ścieżki projektów)
- `managers.txt` — lista zainstalowanych managerów
- `sync.sh` — szybka synchronizacja skilli do workerów i managerów (alternatywa dla `/update-agents`)
