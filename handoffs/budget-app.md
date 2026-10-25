# budget-app
Updated: 2026-10-25 · from Linux (raphael-System-Product-Name) · project dir: none yet (planned: ~/projects/budget-app)

## Goal
A good-looking **local web app** for monthly budgeting. Each month the user imports a CSV of expenses and gets:
- every expense of the month sorted into categories (Food, Life, Subscriptions, …)
- income − expenses − savings = **what's left**
- a comparison with the previous month

## Decisions made (and why)
- **Web app, not a CLI or Claude skill.** The user wants a nice visual dashboard in the browser.
- **Browser-only stack: React + TypeScript + Vite + Tailwind CSS + Recharts.** There's no server or database to maintain, data stays local (IndexedDB), and it runs the same on Linux and macOS (Node only).
- **JSON export/import** for backups and for moving data between the two machines.
- **Money as integer cents** so totals have no floating-point drift.
- **Keyword rules + click to fix** for categorization. Unknown expenses go to "Other". Picking a category offers to save a rule. Claude API suggestions are an optional extra for later.
- **Income:** taken from positive rows in the CSV, otherwise a monthly income set in settings, plus an optional savings goal.
- The user's real CSV format is unknown, so build a column-mapping step on the first import.

## Current plan
### Features
1. **CSV import** (drag and drop, PapaParse): `,` or `;` separators, `DD/MM/YYYY` or ISO dates, `12,50` or `12.50` amounts, column mapping saved for later imports, and duplicate detection (date + description + amount).
2. **Categorization**: default categories are Food, Housing/Life, Transport, Subscriptions, Leisure, Health, Shopping, Income, Other. Editable keyword rules. "Always categorize X as Y?" offered when recategorizing.
3. **Monthly dashboard** (month picker ◀ ▶):
   - KPI cards: Income, Spent, Savings goal, Left, and the change vs the previous month.
   - Category donut chart.
   - This month vs last month bars per category, with a ▲/▼ %.
   - 6–12 month trend line.
   - Transaction table with search, filter and inline recategorization.
4. **Settings**: income, savings goal, categories and colors, rules.

### Layout (`~/projects/budget-app/`)
```
src/lib/csv.ts         parse + column mapping + normalize
src/lib/categorize.ts  rule matching
src/lib/stats.ts       monthly totals, left-over, month-over-month diff
src/lib/db.ts          IndexedDB (idb-keyval) + JSON export/import
src/components/        ImportDialog, KpiCards, CategoryDonut, CompareBars,
                       TrendChart, TransactionTable, RulesEditor, Settings
src/App.tsx
docs/LEARNING.md       running glossary/cheat sheet, grows each stage
examples/sample.csv    2 months of fake data for testing
```

### Stages (each ends with something visible in the browser, plus one small TODO(human))
1. **Toolchain**: install Node (`brew install node` / `sudo apt install nodejs npm`, or nvm), then `npm create vite` (React + TS). Tour every generated file, run `npm run dev`, and open DevTools. *User: edit the page and see the hot reload.*
2. **TS types + pure logic + Vitest tests.** *User: `categorize()` (case sensitivity, which rule wins when two match).*
3. **CSV parsing + tests.** *User: amount parsing (`"1 234,50"` → cents).*
4. **First React UI**: components, props, `useState`, a transaction table from a file input. *User: the category filter.*
5. **Tailwind styling, KPI card layout.** *User: color for a positive/negative "Left".*
6. **Stats + Recharts charts.** *User: the % delta and the case with no previous month.*
7. **IndexedDB persistence, dedupe, JSON export/import.** *User: the duplicate key.*
8. **Rules editor, settings, polish.**

### Verification
- `npm test` runs Vitest on csv, categorize and stats.
- Import `examples/sample.csv` and check the KPIs and comparison against hand-computed totals.
- Check that data survives a reload and that a JSON export/import round-trip works.

## Progress / done
- The plan is agreed. No code yet.
- Infrastructure: the `/handoff` skill was created in `~/claude-config` to resume on the Mac.

## Next step
Start **stage 1**: check whether Node is installed (`node -v`, `npm -v`) and give both install commands if it isn't. Explain what Node, npm and Vite are, then scaffold `~/projects/budget-app` with `npm create vite@latest` (React + TypeScript) and tour the files.

## Open questions
- What the user's bank CSV actually looks like (columns, separator, sign of expenses). Ask for the header line and a fake/anonymized row when we reach stage 3.
- Whether the project should be a git repo pushed to GitHub (so it can move between machines), and whether that repo is private.

## User preferences learned
- Knows C/C++ well but **knows nothing about web development** (Node, npm, React…). Be as educational as possible about the web tech: map concepts to C/C++ equivalents, keep `docs/LEARNING.md` updated, and request a small TODO(human) per stage.
- Use the Learn-by-Doing method **only for the app's technology**, not for tooling (Claude skills, config).
- Prefers making decisions after short explanations, not long lists of multiple-choice questions.
