---
name: workers-status
description: Scans all task files from disk and displays a fresh status dashboard
user_invocable: true
---

Wyświetl świeży dashboard zadań skanując pliki z dysku. **ZIGNORUJ dane z hooka SessionStart** — mogą być nieaktualne. Wszystkie dane pobierz bezpośrednio z plików.

## Instrukcje

### Krok 1: Odkryj repozytoria

Wylistuj wszystkie podkatalogi w swoim bieżącym katalogu roboczym (cwd). Każdy podkatalog (z wyjątkiem `.claude`, `.git`) to repozytorium.

### Krok 2: Skanuj aktywne zadania

Dla każdego repozytorium znajdź pliki `*.md` w katalogu repo. Pomiń:
- `*.plan.md`
- `*.motivation.md`
- pliki w podkatalogach (np. `archive/`)

Przeczytaj każdy znaleziony plik i wyciągnij z frontmattera (YAML między `---`):
- `task` — nazwa zadania
- `status` — status (in_progress, blocked, waiting_for_input, completed, error)
- `progress` — procent ukończenia (0-100)
- `updated` — data ostatniej aktualizacji

Przeczytaj też sekcję `## Problems` — jeśli zawiera coś innego niż "brak", zanotuj jako bloker.

### Krok 3: Skanuj archiwum

Dla każdego repozytorium sprawdź czy istnieje podkatalog `archive/`. Jeśli tak — znajdź pliki `*.md` (pomijając `*.plan.md`, `*.motivation.md`). Wyciągnij `task`, `status`, `updated`. Policz je.

### Krok 4: Wyświetl tabelę aktywnych zadań

```
| Repo | Zadanie | Status | Postęp | Ostatnia zmiana |
|------|---------|--------|--------|-----------------|
| ... | ... | ... | ...% | ... |
```

Jeśli brak aktywnych zadań — napisz "(brak aktywnych zadań)".

Jeśli zadanie ma bloker (sekcja Problems nie jest pusta/"brak") — dopisz ikonę blokera przy statusie.

### Krok 5: Podsumowanie

Pod tabelą pokaż:
```
X repozytoriów | Y aktywnych zadań | Z zarchiwizowanych
```

Jeśli są zarchiwizowane zadania, dodaj: `Archiwum: Z zadań. Napisz "archiwum" aby zobaczyć szczegóły.`
