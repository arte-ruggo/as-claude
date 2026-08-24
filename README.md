# as-claude

Repozytorium narzędziowe do zarządzania wieloma instancjami Claude Code — dystrybuuje współdzielone skille i hooki do projektów (workerów) oraz utrzymuje dashboard managera.

## Idea

Instancje Claude Code dzielą się na dwie role:

- **Worker** — sesja Claude Code otwarta w projekcie (np. `nginx-servers`, `my-app`). Dostaje z tego repo współdzielone skille (obecnie `codex-review2`) oraz hook SessionStart, który wstrzykuje do kontekstu `session_id` i nazwę repozytorium.
- **Manager** — sesja Claude Code w osobnym repozytorium `as-claude-manager/`, działająca jako read-only dashboard zadań: hook SessionStart skanuje pliki zadań ze wszystkich repozytoriów, a skill `/workers-status` wyświetla świeży stan z dysku.

> **Uwaga:** dawny system statusów po stronie workerów (skille `status-update` / `status-end` / `status-list`, hook Stop, automatyczne prowadzenie plików statusów przez workerów) został wycofany. Strona managera pozostała bez zmian i nadal czyta pliki zadań znajdujące się w `as-claude-manager/`.

## Struktura

```
as-claude/                          # ten projekt — narzędzia i konfiguracja
├── worker/
│   ├── config/global-settings.json # template referencyjny hooków workera
│   ├── hooks/
│   │   └── session-start.sh        # wstrzykuje session_id i nazwę repo
│   └── skills/
│       └── codex-review2/
│           └── SKILL.md            # skill /codex-review2
├── manager/
│   ├── CLAUDE.md                   # instrukcje dla managera (kopiowane do projektu)
│   ├── hooks/
│   │   └── session-start.sh        # skanuje wszystkie repo i zadania
│   └── skills/
│       └── workers-status/
│           └── SKILL.md            # skill /workers-status
├── .claude/skills/                 # skille administracyjne tego repo
│   ├── install-worker/SKILL.md     # /install-worker
│   ├── install-manager/SKILL.md    # /install-manager
│   └── update-agents/SKILL.md      # /update-agents
├── sync.sh                         # szybka synchronizacja skilli do workerów i managerów
├── workers.txt                     # lista zainstalowanych workerów (ścieżki)
└── managers.txt                    # lista zainstalowanych managerów (ścieżki)

as-claude-manager/                  # osobne repo — pliki zadań czytane przez managera
├── <repo-name>/
│   ├── <zadanie>.md                # status (frontmatter: task, status, progress, updated)
│   ├── <zadanie>.plan.md           # plan + dziennik pracy
│   ├── <zadanie>.motivation.md     # log decyzji
│   └── archive/                    # zakończone/porzucone zadania
└── ...
```

## Jak to działa

### Worker

Gdy otwierasz Claude Code w projekcie-workerze, hook `session-start.sh`:
- Ustala nazwę repozytorium (z `git remote` lub nazwy katalogu)
- Wstrzykuje `session_id` i nazwę repo do kontekstu Claude'a

Poza tym worker to zwykła sesja — pracujesz normalnie, korzystając ze współdzielonych skilli (np. `/codex-review2`).

### Manager

Sesja w `as-claude-manager/` dostaje na starcie pełną listę zadań ze wszystkich repozytoriów (hook `manager/hooks/session-start.sh`) i działa jako read-only dashboard. Skill `/workers-status` skanuje pliki z dysku i pokazuje świeży stan (statusy, postęp, blokery, archiwum).

## Instalacja i aktualizacja

### Wymagania

- Claude Code v2.1+
- `jq` (do parsowania JSON w hookach)
- Git Bash na Windows (hooki napisane w bashu)

### Skille administracyjne (zalecane)

Otwórz Claude Code w tym repo i użyj:

- `/install-worker` — instaluje workera w podanym projekcie (skille + hook SessionStart + rejestracja w `workers.txt`)
- `/install-manager` — instaluje dashboard managera
- `/update-agents` — porównuje wszystkie instalacje ze źródłami i aktualizuje przestarzałe

### Ręcznie

**a) Hook SessionStart w `.claude/settings.json` projektu:**

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

Jeśli plik `.claude/settings.json` już istnieje, dopisz sekcję `hooks` do istniejącej konfiguracji.

**b) Skopiuj skille:**

```bash
cp -r E:/Repository/as-claude/worker/skills/codex-review2 <projekt>/.claude/skills/codex-review2
```

**c) Zarejestruj projekt** — dodaj ścieżkę do `workers.txt` (jedna na linię).

### Szybka synchronizacja skilli

```bash
bash E:/Repository/as-claude/sync.sh
```

Kopiuje aktualne skille do wszystkich workerów z `workers.txt` i managerów z `managers.txt` (nie rusza `settings.json`).
