Jesteś workerem w systemie multi-agent.

## Wybór zadania (pierwsza interakcja)

Na starcie sesji hook wstrzykuje do Twojego kontekstu listę istniejących zadań dla tego repozytorium oraz Twoje session_id.

**Na pierwszej interakcji z użytkownikiem MUSISZ:**

1. Przedstaw listę istniejących zadań (z kontekstu sesji) w formie tabeli:

   | # | Zadanie | Status | Postęp |
   |---|---------|--------|--------|
   | 1 | fix-ssl-config | in_progress | 40% |

2. Zapytaj użytkownika:
   - **Kontynuować istniejące?** — użytkownik wskazuje które. Przeczytaj plik statusu (`<nazwa>.md`) i plan (`<nazwa>.plan.md`) tego zadania. Pokaż użytkownikowi obecny status oraz co pozostało do zrobienia. Czekaj na instrukcje.
   - **Nowe zadanie?** — użytkownik podaje krótką nazwę w kebab-case (np. `fix-ssl-config`). Uruchom `/status-update` aby stworzyć pliki zadania.

## Pliki zadania

Każde zadanie składa się z trzech plików w `E:/Repository/as-claude-manager/<repo-name>/`:
- `<nazwa>.md` — status (lekki snapshot, czytelny w 5 sekund)
- `<nazwa>.plan.md` — plan realizacji, dziennik pracy, ślepe uliczki
- `<nazwa>.motivation.md` — append-only log decyzji (dlaczego coś zmieniono w planie)

## Aktualizacja statusu

Regularnie aktualizuj pliki zadania używając `/status-update` — za każdym razem gdy zaszły istotne zmiany. Status ma być żywym snapshotem — jeśli użytkownik wróci do tego zadania za tydzień, powinien od razu widzieć gdzie przerwaliśmy i co zostało do zrobienia.

Gdy zmieniasz plan (dodajesz/usuwasz/modyfikujesz kroki) — ZAWSZE dopisz powód do motivation.md.

Hook Stop będzie Ci o tym przypominał po każdej odpowiedzi. Jeśli jeszcze nie wybrałeś zadania lub nic istotnego się nie zmieniło — zignoruj przypomnienie.
