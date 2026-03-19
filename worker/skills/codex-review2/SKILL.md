---
name: codex-review2
description: Adversarial review of implementation plans or code using OpenAI Codex CLI - iterative loop with scoped review modes (bugs, architecture) until APPROVED or max rounds
user_invocable: true
allowed-tools: Bash, Read, Write, Glob, Grep, AskUserQuestion, Edit
---

# Codex Review

Adversarial review planu implementacji lub gotowego kodu przez OpenAI Codex CLI.

**Użycie:**

- `/codex-review2 bugs` - review pod kątem poprawności: błędy, edge cases, security
- `/codex-review2 architecture` - review pod kątem architektury: design, długofalowy rozwój, wzorce
- `/codex-review2` (bez argumentu) - zapytaj użytkownika o scope

**Wymaga:** `codex` CLI zainstalowane i w PATH.

**Koszt:** ~$0.05-0.15 za rundę, max 5 rund = do ~$0.75.

---

## 1. Ustal kontekst i scope

### Typ recenzji: plan vs implementacja

Ustal co recenzujesz - **plan** (kodu jeszcze nie ma) czy **implementacja** (kod istnieje w repo). To wpływa na instrukcje dla Codexa:

- **Plan** - Codex ocenia logikę, kompletność, potencjalne problemy. NIE szuka zmian w kodzie (bo ich nie ma).
- **Implementacja** - Codex czyta faktyczne pliki źródłowe i weryfikuje poprawność kodu.

### Scope review

Na podstawie argumentu (`bugs` / `architecture`) dobierz instrukcje:

**bugs** (poprawność):
> Find bugs, logic errors, unhandled edge cases, security vulnerabilities, race conditions, and incorrect assumptions. Verify that the approach will work correctly. Do NOT review architectural decisions or long-term maintainability.

**architecture** (architektura):
> Evaluate the design from a long-term software evolution perspective. Look for coupling issues, violation of SOLID principles, scalability bottlenecks, abstraction leaks, and decisions that will be costly to change later. Also check for bugs, but focus on whether this is the RIGHT approach, not just whether it works.

---

## 2. Przygotuj plik planu

### Nazwa pliku

Dynamiczna, opisowa, kebab-case:

```
PLAN_FILE=".claude/<slug>.codex-review.md"
```

Np. `auth-handler-refactor.codex-review.md`, `cart-api-validation.codex-review.md`.

**Dlaczego dynamiczna?** Może być uruchomionych kilka instancji CC równocześnie - statyczna nazwa powoduje nadpisywanie.

### Zawartość pliku

Wygeneruj plik z następującą strukturą:

#### Preambuła (generowana z Twojej wiedzy o projekcie)

Znasz kontekst projektu bo sam tworzyłeś plan lub implementację. Wygeneruj preambułę z pamięci - NIE czytaj ponownie README/csproj/package.json. Jeśli brakuje Ci szczegółów o konkretnym aspekcie - wtedy doczytujesz pojedynczy plik.

```markdown
You are an adversarial code reviewer.

## Review type
<"This is a PLAN review - code changes do not exist yet. Evaluate the plan's logic and completeness. Do not look for code diffs."
LUB
"This is an IMPLEMENTATION review - code changes exist in the repository. Read the source files to verify correctness.">

## Review scope
<instrukcje scope z sekcji 1 - bugs lub architecture>

## Project context
**Project:** <co to za projekt, do czego służy>
**Tech stack:** <technologie, frameworki, bazy danych>
**Structure:** <monolit/microservices, kluczowe projekty/moduły>

## Severity scale
Classify each finding as:
- CRITICAL: bug, security hole, data loss - must be fixed
- MAJOR: missing edge case, design flaw - should be fixed
- MINOR: style, naming, nice-to-have - optional

## Key files
<lista ścieżek do plików istotnych dla tego review - Codex je przeczyta>

## Instructions
Read the plan/analysis below, then read the referenced source files to verify claims. End your review with:
VERDICT: APPROVED
or
VERDICT: REVISE followed by numbered issues with severity.
```

#### Treść planu

Po preambule umieść:
- Cel i kontekst (issue/task reference jeśli istnieje)
- Lista plików do zmiany + opis zmian
- Potencjalne ryzyka które sam identyfikujesz
- Kluczowe fragmenty kodu (opcjonalne - Codex przeczyta pliki sam, ale inline snippets przyspieszają review)

**Przed zapisaniem:** upewnij się że plan nie zawiera sekretów, kluczy API, connection strings, danych klientów. Plan trafia do OpenAI API.

---

## 3. Uruchom review

Wygeneruj dynamiczny prompt i uruchom Codexa:

```bash
codex exec -s read-only "<wygenerowana_preambuła + krótkie podsumowanie z listą kluczowych plików>"
```

**WAŻNE:**
- Prompt jest generowany dynamicznie - NIE kopiuj hardcoded stringów
- Krótki prompt + referencja do pliku w repo. NIE używaj `$(cat file)` dla długich planów
- Jeśli plan jest krótki (< ~2000 znaków), możesz go osadzić bezpośrednio w prompcie. Jeśli dłuższy - zapisz do pliku i podaj referencję: "Read .claude/xyz.codex-review.md for the full plan."

---

## 4. Parsowanie wyniku

- Wyodrębnij **VERDICT** z końca odpowiedzi (`VERDICT: APPROVED` lub `VERDICT: REVISE`)
- Wyodrębnij **feedback** - lista numerowanych problemów z severity po REVISE
- Oceń każdy finding:
  - **Severity nadana przez Codexa** (CRITICAL / MAJOR / MINOR)
  - **Twoja ocena** - czy trafny, czy false positive

---

## 5. Pętla iteracyjna (REVISE)

Jeśli `VERDICT: REVISE`:

### 5.1 Przedstaw feedback użytkownikowi

Dla każdego finding pokaż:
- Numer i opis z review Codexa
- Severity (z review Codexa)
- Twoja ocena: trafny / częściowo trafny / false positive

### 5.2 Zaadresuj findings

Dla każdego finding podejmij jedno z działań:
- **FIXED** - napraw w kodzie/planie
- **REJECTED** - uznajesz za false positive
- **DEFERRED** - uzasadnij dlaczego nie teraz

### 5.3 Zaktualizuj plik planu

Dopisz do planu sekcję z rozwiązaniami. Format:

```markdown
## Round N Resolution

### FIXED
- Issue #1 (CRITICAL): <opis> -> Fixed in `path/file.cs`: <co zmieniono>
- Issue #3 (MAJOR): <opis> -> Fixed in `path/other.cs`: <co zmieniono>

### REJECTED (false positive)
- Issue #2 (MINOR): <opis>
  **Argumentation:** <dlaczego to nie jest problem - konkretna argumentacja>

### DEFERRED
- Issue #4 (MINOR): <opis>
  **Reason:** <dlaczego nie teraz>
```

### 5.4 Uruchom kolejną rundę

Nowa sesja Codexa (resume nie przekazuje promptu poprawnie):

```bash
codex exec -s read-only "<preambuła z kontekstem rundy>"
```

Prompt kolejnej rundy musi zawierać:
- Oryginalną preambułę (review type, scope, project context)
- Informację o rundzie: "This is ROUND N. Previous round found X issues (VERDICT: REVISE)."
- Instrukcję: "Read the Round N-1 Resolution section in the plan file. For FIXED items - verify the fix in source files. For REJECTED items - if the argumentation is weak, raise the issue again with a counterargument. If the argumentation is valid, accept the rejection."

### 5.5 Obsługa uporczywych disagreements

Jeśli Codex podnosi ten sam issue po raz 3. mimo argumentacji REJECTED:
- CC MOŻE zakończyć pętlę wcześniej
- CC MUSI oznaczyć ten finding w podsumowaniu jako **UNRESOLVED DISAGREEMENT**
- Decyzja należy do użytkownika

Powtarzaj aż do `VERDICT: APPROVED` lub **max 5 rund**.

---

## 6. Finalizacja

### Podsumowanie (ZAWSZE wyświetl na końcu)

Niezależnie od wyniku (APPROVED, REVISE po 5 rundach, wcześniejsze zakończenie) - **ZAWSZE** wyświetl użytkownikowi pełne podsumowanie:

```
## Codex Review Summary

**Rounds:** N
**Final verdict:** APPROVED / REVISE (round limit) / REVISE (early exit - disagreement)
**Scope:** bugs / architecture
**Review type:** plan / implementation

### All findings:

| # | Severity | Description | Resolution |
|---|----------|-------------|------------|
| 1 | CRITICAL | ...         | FIXED in `path/file.cs` |
| 2 | MAJOR    | ...         | REJECTED - <powód> |
| 3 | MINOR    | ...         | DEFERRED - <powód> |
| 4 | MAJOR    | ...         | UNRESOLVED DISAGREEMENT - <opis sporu> |
```

### Cleanup

Usuń plik planu: `rm -f <PLAN_FILE>`

---

## Ważne

- **`-s read-only`** - Codex NIE modyfikuje plików, tylko czyta i reviewuje
- **Nowa sesja na każdą rundę** - `codex exec resume <id>` nie przekazuje promptu poprawnie
- **Codex CZYTA pliki** z repo w read-only sandbox - nie trzeba wklejać całego kodu źródłowego, ale podaj listę kluczowych plików w preambule
- **Nie wysyłaj sekretów** - plan trafia do OpenAI API

## Gotchas (Windows)

- Codex używa PowerShell jako sandbox - ścieżki z `/` działają, `rg` musi być zainstalowany
- Output >30KB jest obcinany - sprawdzaj pełny plik z tool-results
- Duże repozytoria - w preambule wskazuj konkretne projekty/ścieżki
