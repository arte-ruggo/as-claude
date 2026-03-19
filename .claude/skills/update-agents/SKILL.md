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

| Plik w projekcie | Źródło |
|---|---|
| `.claude/skills/status-update/SKILL.md` | `worker/skills/status-update/SKILL.md` |
| `.claude/skills/status-end/SKILL.md` | `worker/skills/status-end/SKILL.md` |
| `CLAUDE.md` | `worker/CLAUDE.md` |

Dla każdego pliku uruchom `diff -q` aby sprawdzić czy są różnice. Jeśli plik w projekcie nie istnieje — oznacz jako `MISSING`.

**Uwaga o CLAUDE.md:** Projekt może mieć własne treści w CLAUDE.md dopisane po sekcji workera. Porównuj tylko zawartość do pierwszego `---` separatora (lub do końca jeśli brak separatora). Użyj `diff` na pierwszych N liniach odpowiadających długości źródłowego worker/CLAUDE.md.

### Krok 3: Sprawdź managerów

Dla każdego managera z `managers.txt`:

1. Sprawdź czy katalog istnieje. Jeśli nie — oznacz jako `MISSING`.
2. Porównaj:

| Plik w projekcie | Źródło |
|---|---|
| `CLAUDE.md` | `manager/CLAUDE.md` |

### Krok 4: Raport

Wyświetl tabelę:

```
## Workerzy

| Projekt | status-update | status-end | CLAUDE.md | Status |
|---------|--------------|------------|-----------|--------|
| E:/Repository/nginx-servers | OK | OK | OUTDATED | wymaga aktualizacji |
| E:/Repository/my-app | MISSING | MISSING | OK | wymaga aktualizacji |

## Managerzy

| Projekt | CLAUDE.md | Status |
|---------|-----------|--------|
| E:/Repository/as-claude-manager | OK | aktualny |
```

Statusy plików: `OK` (identyczny), `OUTDATED` (różni się), `MISSING` (brak pliku).

### Krok 5: Aktualizacja

Jeśli są przestarzałe instalacje, zapytaj użytkownika:
> Zaktualizować wszystkie przestarzałe pliki? (tak/nie/wybierz)

- **tak** — zaktualizuj wszystkie `OUTDATED` i `MISSING` pliki kopiując ze źródeł
- **nie** — zakończ bez zmian
- **wybierz** — pozwól użytkownikowi wskazać które projekty zaktualizować

Przy aktualizacji `CLAUDE.md` workera: jeśli projekt ma dodatkowe treści poniżej sekcji workera (po `---`), zachowaj je — nadpisz tylko sekcję workera na początku.

### Krok 6: Potwierdzenie

```
Zaktualizowano X plik(ów) w Y projekt(ach).
```
