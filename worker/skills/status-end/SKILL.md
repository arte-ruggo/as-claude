---
name: status-end
description: Archives a completed or abandoned task by moving its files to the archive directory
user_invocable: true
---

Przenieś zakończone lub porzucone zadanie do archiwum. Przenosi trio plików (`<nazwa>.md`, `<nazwa>.plan.md`, `<nazwa>.motivation.md`) do podkatalogu `archive/`.

## Lokalizacja

- Aktywne: `E:/Repository/as-claude-manager/<repo>/<nazwa>.*`
- Archiwum: `E:/Repository/as-claude-manager/<repo>/archive/<nazwa>.*`

## Instrukcje

### Krok 1: Ustal nazwę repozytorium

Uruchom `git remote get-url origin` i wyciągnij nazwę repozytorium (ostatni segment bez `.git`). Jeśli brak git remote, użyj nazwy bieżącego folderu.

### Krok 2: Wybierz zadanie do archiwizacji

Sprawdź jakie pliki `*.md` (nie `*.plan.md`, nie `*.motivation.md`, nie pliki w `archive/`) istnieją w `E:/Repository/as-claude-manager/<repo>/`.

- Jeśli jest jedno zadanie — potwierdź z użytkownikiem.
- Jeśli jest wiele — pokaż listę i zapytaj które archiwizować.
- Jeśli brak zadań — poinformuj użytkownika i zakończ.

### Krok 3: Zaktualizuj status przed archiwizacją

Przed przeniesieniem zaktualizuj `<nazwa>.md`:
- Ustaw `status: completed` lub `status: abandoned` (zapytaj użytkownika jeśli nie jest jasne)
- Ustaw `progress: 100` (jeśli completed) lub zostaw aktualny (jeśli abandoned)
- Zaktualizuj `updated:` na aktualny czas UTC

### Krok 4: Dopisz do motivation

Dopisz na końcu `<nazwa>.motivation.md`:

```markdown
- [<czas UTC>] Zadanie zarchiwizowane — status: <completed|abandoned>. Powód: <krótki powód od użytkownika lub "zakończone">
```

### Krok 5: Przenieś pliki

Utwórz katalog archiwum jeśli nie istnieje:
```bash
mkdir -p "E:/Repository/as-claude-manager/<repo>/archive"
```

Przenieś trio plików:
```bash
mv "E:/Repository/as-claude-manager/<repo>/<nazwa>.md" "E:/Repository/as-claude-manager/<repo>/archive/"
mv "E:/Repository/as-claude-manager/<repo>/<nazwa>.plan.md" "E:/Repository/as-claude-manager/<repo>/archive/"
mv "E:/Repository/as-claude-manager/<repo>/<nazwa>.motivation.md" "E:/Repository/as-claude-manager/<repo>/archive/"
```

### Krok 6: Potwierdź

Wyświetl użytkownikowi potwierdzenie:
```
Zarchiwizowano: <nazwa zadania>
Status: <completed|abandoned>
Pliki przeniesione do: E:/Repository/as-claude-manager/<repo>/archive/
```

## Zasady

- **Czas UTC**: Zawsze pobieraj aktualny czas komendą `date -u +"%Y-%m-%dT%H:%M:%SZ"`. Nigdy nie zgaduj ani nie zaokrąglaj czasu.
- Nigdy nie archiwizuj bez potwierdzenia użytkownika.
- Nigdy nie usuwaj plików — tylko przenoś do `archive/`.
- Zawsze aktualizuj status i motivation przed przeniesieniem.
- Jeśli katalog `archive/` nie istnieje — utwórz go.
