# as-claude

Repozytorium narzędziowe do zarządzania wieloma instancjami Claude Code — utrzymuje hooki
workerów i managera oraz rejestr instalacji. **Skille nie żyją w tym repo**: każdy skill istnieje
wyłącznie w `ar-skills` (model: `ar-skills/docs/2026-09-05-skills-target-model.md`) i jest w projekcie
włączany wpisem w `.claude/settings.json`, nigdy kopią pliku.

## Idea

Instancje Claude Code dzielą się na dwie role:

- **Worker** — sesja Claude Code otwarta w projekcie (np. `nginx-servers`, `my-app`). Dostaje hook
  SessionStart, który wstrzykuje do kontekstu `session_id` i nazwę repozytorium, oraz włączony skill
  `codex-review2` (w repo bez `build/codex/codex.sh` — `codex-review-pro`).
- **Manager** — sesja Claude Code w osobnym repozytorium `as-claude-manager/`, działająca jako
  read-only dashboard zadań: hook SessionStart skanuje pliki zadań ze wszystkich repozytoriów,
  a skill `/workers-status` wyświetla świeży stan z dysku.

> **Uwaga:** dawny system statusów po stronie workerów (skille `status-update` / `status-end` /
> `status-list`, hook Stop, automatyczne prowadzenie plików statusów przez workerów) został wycofany.
> Strona managera pozostała bez zmian i nadal czyta pliki zadań znajdujące się w `as-claude-manager/`.

## Struktura

```
as-claude/                          # ten projekt — hooki, rejestr instalacji
├── worker/
│   ├── config/global-settings.json # template referencyjny hooków workera
│   └── hooks/
│       └── session-start.sh        # wstrzykuje session_id i nazwę repo
├── manager/
│   ├── CLAUDE.md                   # instrukcje dla managera (kopiowane do projektu)
│   └── hooks/
│       └── session-start.sh        # skanuje wszystkie repo i zadania
├── .claude/settings.json           # włączenia skilli administracyjnych (install-worker, install-manager, update-agents)
├── workers.txt                     # lista zainstalowanych workerów (ścieżki)
└── managers.txt                    # lista zainstalowanych managerów (ścieżki)

ar-skills/                          # JEDYNE źródło skilli: codex-review2, workers-status, install-*, update-agents
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

Poza tym worker to zwykła sesja — pracujesz normalnie, korzystając ze skilli włączonych w repo
(np. `/codex-review2`).

### Manager

Sesja w `as-claude-manager/` dostaje na starcie pełną listę zadań ze wszystkich repozytoriów
(hook `manager/hooks/session-start.sh`) i działa jako read-only dashboard. Skill `/workers-status`
skanuje pliki z dysku i pokazuje świeży stan (statusy, postęp, blokery, archiwum).

## Instalacja i aktualizacja

### Wymagania

- Claude Code v2.1+
- lokalny klon `ar-skills` z założonymi dowiązaniami (`ar-skills\link.ps1`) — bez tego wpis
  w `enabledPlugins` nic nie włącza
- `jq` (do parsowania JSON w hookach)
- Git Bash na Windows (hooki napisane w bashu)

### Skille administracyjne (zalecane)

Otwórz Claude Code w korzeniu tego repo i użyj:

- `/install-worker` — instaluje workera w podanym projekcie (hook SessionStart + wpis `enabledPlugins`
  + rejestracja w `workers.txt`)
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

**b) Włącz skill workera** — w tym samym `.claude/settings.json` (plik śledzony w gicie):

```json
{ "enabledPlugins": { "codex-review2@skills-dir": true } }
```

(w repo bez `build/codex/codex.sh`: `codex-review-pro@skills-dir`). Nigdy nie twórz `.claude/skills/`
w projekcie — kopia skilla to złamanie modelu jednego źródła.

**c) Zarejestruj projekt** — dodaj ścieżkę do `workers.txt` (jedna na linię).

### Aktualizacja

Treść skilli aktualizuje się sama — dowiązanie w `~/.claude/skills` prowadzi do `ar-skills`, więc
`git pull` w `ar-skills` wystarcza. `/update-agents` sprawdza wyłącznie hooki i wpisy `enabledPlugins`.
