# as-claude

System do zarządzania wieloma instancjami Claude Code pracującymi równolegle nad różnymi zadaniami.

## Idea

Gdy pracujesz z wieloma sesjami Claude Code jednocześnie, trudno śledzić co która sesja robi, gdzie skończyła i co zostało do zrobienia. **as-claude** rozwiązuje ten problem dzieląc instancje na **workerów** i **managera**:

- **Worker** — każda sesja Claude Code otwarta w projekcie (np. `nginx-servers`, `my-app`). Worker pracuje nad zadaniami i regularnie zapisuje swój status do pliku markdown.
- **Manager** — centralne repozytorium (`as-claude-manager/`) przechowujące pliki statusów wszystkich workerów. Pozwala szybko zobaczyć stan każdego zadania.

## Struktura

```
as-claude/                          # ten projekt — narzędzia i konfiguracja
├── worker/
│   ├── CLAUDE.md                   # instrukcje dla workerów (kopiowane do projektów)
│   ├── config/global-settings.json # template hooków
│   ├── hooks/
│   │   ├── session-start.sh        # wstrzykuje listę zadań na starcie sesji
│   │   └── update-status.sh        # przypomina o aktualizacji statusu
│   └── skills/status-update/
│       └── SKILL.md                # skill /status-update
└── manager/                        # (w przygotowaniu)

as-claude-manager/                  # osobne repo — pliki statusów
├── nginx-servers/
│   ├── audyt-konfiguracji-bugi.md              # status
│   ├── audyt-konfiguracji-bugi.plan.md         # plan + dziennik
│   └── audyt-konfiguracji-bugi.motivation.md   # log decyzji
├── my-app/
│   ├── fix-login-flow.md
│   ├── fix-login-flow.plan.md
│   └── fix-login-flow.motivation.md
└── ...
```

## Jak to działa

### 1. Start sesji

Gdy otwierasz Claude Code w projekcie-workerze, hook `session-start.sh` automatycznie:
- Ustala nazwę repozytorium (z `git remote` lub nazwy katalogu)
- Skanuje istniejące pliki statusów w `as-claude-manager/<repo>/`
- Wstrzykuje listę zadań i `session_id` do kontekstu Claude'a

Claude przedstawia Ci listę zadań i pyta:
- **Kontynuować istniejące?** — czyta status + plan, pokazuje gdzie przerwaliśmy
- **Nowe zadanie?** — podajesz nazwę, Claude tworzy 3 pliki zadania

### 2. Praca

Pracujesz normalnie. Claude regularnie aktualizuje plik statusu za pomocą skilla `/status-update` — za każdym razem gdy zachodzą istotne zmiany. Status ma być żywym snapshotem, nie raportem końcowym.

### 3. Przypomnienia

Hook `update-status.sh` odpala się po każdej odpowiedzi Claude'a. Jeśli żaden plik statusu w katalogu repozytorium nie był modyfikowany w ciągu ostatnich 5 minut, przypomina Claude'owi o aktualizacji. Claude sam ocenia czy zaszły istotne zmiany — jeśli nie, ignoruje przypomnienie.

### 4. Pliki zadań

Każde zadanie składa się z **trzech plików** w `as-claude-manager/<repo>/`:

#### Status (`<nazwa>.md`) — lekki snapshot

```markdown
---
task: Audyt konfiguracji nginx
repo: nginx-servers
status: in_progress
progress: 40
current_session: abc-123
updated: 2026-03-18T00:05:00Z
---

## Current task
Audyt konfiguracji nginx — poszukiwanie błędów

## Done
- Przegląd struktury repozytorium

## Next
- Naprawa krytycznych problemów SSL

## Problems
brak
```

#### Plan (`<nazwa>.plan.md`) — plan realizacji + dziennik pracy

```markdown
# Audyt konfiguracji nginx

## Cel
Przegląd konfiguracji nginx pod kątem błędów, luk bezpieczeństwa i best practices.

## Plan
1. [x] Przegląd struktury repozytorium
2. [x] Audyt plików .conf
3. [ ] Naprawa krytycznych problemów SSL
4. [ ] Security headers

## Dziennik pracy

### 2026-03-17 — sesja abc-123
- Zrobione: przegląd 61 plików .conf, raport z 23 problemami
- Problemy: brak dostępu do serwera produkcyjnego
- Wnioski: sd-proxy ma istotne luki SSL

## Ślepe uliczki
(brak)
```

#### Motivation (`<nazwa>.motivation.md`) — append-only log decyzji

```markdown
# Decyzje: Audyt konfiguracji nginx

- [2026-03-17T22:00Z] Utworzono plan z 4 krokami
- [2026-03-18T01:00Z] Punkt "migracja sd-proxy na brotli" odłożony — wymaga przebudowy obrazu Docker
```

## Instalacja

### Wymagania

- Claude Code v2.1+
- `jq` (do parsowania JSON w hookach)
- Git Bash na Windows (hooki napisane w bashu)

### Krok 1: Przygotuj katalog managera

```bash
mkdir -p E:/Repository/as-claude-manager
```

### Krok 2: Skonfiguruj projekt jako workera

W katalogu projektu, który ma być workerem:

**a) Dodaj hooki do `.claude/settings.json`:**

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
    ],
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
  }
}
```

Jeśli plik `.claude/settings.json` już istnieje, dopisz sekcję `hooks` do istniejącej konfiguracji.

**b) Skopiuj skill `/status-update`:**

```bash
cp -r E:/Repository/as-claude/worker/skills/status-update <projekt>/.claude/skills/status-update
```

Skill musi znajdować się w `.claude/skills/status-update/SKILL.md` w katalogu projektu.

**c) Dodaj instrukcje worker do `CLAUDE.md` projektu:**

Skopiuj zawartość `as-claude/worker/CLAUDE.md` na początek pliku `CLAUDE.md` w projekcie, oddzielając od reszty linią `---`.

### Krok 3: Gotowe

Otwórz Claude Code w skonfigurowanym projekcie. Claude powinien przywitać Cię listą istniejących zadań.
