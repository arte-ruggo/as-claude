To jest repozytorium narzędziowe systemu **as-claude** — systemu zarządzania zadaniami dla wielu instancji Claude Code.

Nie pracujesz tu nad kodem projektu. Twoja rola to administracja systemu:

## Dostępne skille

- `/install-worker` — zainstaluj system worker w projekcie
- `/install-manager` — zainstaluj dashboard manager w projekcie
- `/update-agents` — sprawdź i zaktualizuj wszystkie instalacje (workerów i managerów)

## Struktura repo

- `worker/` — pliki źródłowe dla workerów (hooks, skills, CLAUDE.md)
- `manager/` — pliki źródłowe dla managera (hooks, CLAUDE.md)
- `workers.txt` — lista zainstalowanych workerów (ścieżki projektów)
- `managers.txt` — lista zainstalowanych managerów
- `sync.sh` — szybka synchronizacja skilli do workerów (alternatywa dla `/update-agents`)
