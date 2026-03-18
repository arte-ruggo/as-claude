---
name: status-update
description: Creates or updates the worker status file for the current task
user_invocable: true
---

Zaktualizuj pliki zadania w systemie multi-agent. Każde zadanie składa się z trzech plików:

- `<nazwa>.md` — status (lekki snapshot)
- `<nazwa>.plan.md` — plan realizacji + dziennik pracy
- `<nazwa>.motivation.md` — append-only log decyzji

## Lokalizacja

`E:/Repository/as-claude-manager/<repo-name>/<nazwa-zadania>.*`

## Instrukcje

### Krok 1: Ustal nazwę repozytorium

Uruchom `git remote get-url origin` i wyciągnij nazwę repozytorium (ostatni segment bez `.git`). Jeśli brak git remote, użyj nazwy bieżącego folderu.

### Krok 2: Ustal pliki zadania

Jeśli wiesz nad jakim zadaniem pracujesz, użyj odpowiednich ścieżek:
- `E:/Repository/as-claude-manager/<repo>/<nazwa>.md`
- `E:/Repository/as-claude-manager/<repo>/<nazwa>.plan.md`
- `E:/Repository/as-claude-manager/<repo>/<nazwa>.motivation.md`

Jeśli nie wiesz — sprawdź jakie pliki `*.md` (nie `*.plan.md`, nie `*.motivation.md`) istnieją w katalogu repozytorium i zapytaj użytkownika.

### Krok 3: Zaktualizuj status (`<nazwa>.md`)

Utwórz folder jeśli nie istnieje. Zapisz/zaktualizuj plik:

```markdown
---
task: <krótki opis zadania, 1 linia>
repo: <nazwa-repo>
cwd: <ścieżka robocza>
status: in_progress | blocked | waiting_for_input | completed | error
progress: <0-100, szacunkowy procent ukończenia>
current_session: <twoje session_id z kontekstu sesji>
updated: <aktualny czas UTC, ISO 8601>
created: <czas utworzenia — zachowaj oryginalny jeśli aktualizujesz>
previous_names:
  - <poprzednia nazwa pliku, jeśli była zmiana>
session_history:
  - <session_id> | <data> | <co ta sesja robiła — 1 linia>
---

## Current task
<1-2 zdania: co aktualnie robisz>

## Done
- <ukończone kroki, zwięźle>

## Next
- <planowane następne kroki>

## Problems
<blokery, pytania do użytkownika — lub "brak">
```

### Krok 4: Zaktualizuj plan (`<nazwa>.plan.md`)

Przy **tworzeniu nowego zadania** — stwórz plik z początkowym planem:

```markdown
# <nazwa zadania>

## Cel
<po co robimy to zadanie, 1-3 zdania>

## Plan
1. [ ] Krok 1
2. [ ] Krok 2

## Dziennik pracy

### <data> — sesja <session_id>
- Zrobione: ...
- Problemy: ...
- Wnioski: ...

## Ślepe uliczki
(brak)
```

Przy **aktualizacji istniejącego zadania**:
- Oznacz zrealizowane kroki `[x]`
- Dodaj nowe kroki jeśli pojawiły się w trakcie pracy
- Dopisz nowy wpis do "Dziennik pracy" (na dole sekcji)
- Jeśli coś próbowałeś i nie wyszło — dopisz do "Ślepe uliczki"
- Plan ma być czytelny — bez tłumaczeń decyzji (od tego jest motivation.md)

### Krok 5: Dopisz do motivation (`<nazwa>.motivation.md`)

Przy **tworzeniu** — stwórz plik:

```markdown
# Decyzje: <nazwa zadania>

- [<czas UTC>] Utworzono zadanie i plan
```

Przy **aktualizacji** — dopisz na końcu pliku (append-only, nigdy nie usuwaj/edytuj starych wpisów):

```markdown
- [<czas UTC>] <co się zmieniło i dlaczego>
```

Dopisuj wpis gdy:
- Dodajesz/usuwasz/zmieniasz kroki w planie
- Zmieniasz podejście do realizacji
- Odkrywasz coś co wpływa na dalszą pracę
- Porzucasz ścieżkę (ślepa uliczka)

### Krok 6: Zmiana nazwy pliku (opcjonalnie)

Jeśli charakter zadania znacząco się zmienił:
1. Wymyśl nową nazwę.
2. Dodaj starą nazwę do `previous_names` w frontmatter statusu.
3. Przenieś wszystkie 3 pliki (status, plan, motivation).
4. Dopisz do motivation: zmiana nazwy i powód.

## Zasady

- **Czas UTC**: Zawsze pobieraj aktualny czas komendą `date -u +"%Y-%m-%dT%H:%M:%SZ"`. Nigdy nie zgaduj ani nie zaokrąglaj czasu.
- Status ma być czytelny w 5 sekund — to snapshot, nie raport.
- Plan ma być czytelny — czyste checkboxy, bez komentarzy "dlaczego".
- Motivation jest append-only — nigdy nie usuwaj/edytuj starych wpisów.
- Nie usuwaj historii z `session_history` — tylko dopisuj.
- `previous_names` to pełna historia nazw — nigdy nie usuwaj wpisów.
- Twoje session_id znajdziesz w kontekście wstrzykniętym na starcie sesji.
