# SQL for Data Analysts — SQL Interview Patterns Cheat Sheet

**Article:** [SQL for Data Analysts (Part 6): The Real Interview Questions](https://medium.com/@TheAnalyticMind)

The 10 SQL patterns that show up in analyst interviews at Meta, Amazon, Google, and most analytics teams that take SQL seriously. Each one maps to something you'll do on the job — the interview is just a test of whether you can do it on demand.

---

## What's in here

```
sql-interview-patterns/
│
├── data/
│   └── setup.sql              ← Same dataset as Parts 1–5. Run this first.
│
├── examples/
│   ├── 01_running_totals.sql
│   ├── 02_rank_within_group.sql
│   ├── 03_month_over_month.sql
│   ├── 04_deduplication.sql
│   ├── 05_anti_join.sql
│   ├── 06_top_n_per_group.sql
│   ├── 07_cohort_logic.sql
│   ├── 08_conditional_aggregation.sql
│   ├── 09_having_vs_where.sql
│   └── 10_chained_ctes.sql
│
└── practice/
    ├── questions.sql          ← 10 questions. Try before looking at solutions.
    └── solutions.sql          ← Full solutions with explanations + common traps.
```

---

## The 10 Patterns

| # | Pattern | Key function(s) | Tests |
|---|---------|----------------|-------|
| 1 | Running totals | `SUM() OVER (ORDER BY)` | Window function ordering |
| 2 | Rank within group | `DENSE_RANK() OVER (PARTITION BY)` | Tie handling |
| 3 | Month-over-month change | `LAG()` | Time-series partitioning |
| 4 | Deduplication | `ROW_NUMBER() OVER (PARTITION BY)` | One row per entity |
| 5 | Anti-join | `LEFT JOIN + IS NULL` | Null-safe gap finding |
| 6 | Top N per group | `DENSE_RANK()` + CTE filter | Two-step ranking |
| 7 | Cohort logic | `DATE_TRUNC()` + `GROUP BY` | Cohort definition order |
| 8 | Conditional aggregation | `SUM(CASE WHEN)` | Pivoting without PIVOT |
| 9 | HAVING vs WHERE | `HAVING COUNT(...) > N` | Pre vs post aggregation |
| 10 | Chained CTEs | `WITH a AS (...), b AS (...)` | Problem structuring |

---

## Getting started

**Option 1 — DB Fiddle (no install needed)**
Go to [dbfiddle.uk](https://dbfiddle.uk), select **PostgreSQL 15**, paste `data/setup.sql` and run. Write queries in the right panel.

**Option 2 — Local PostgreSQL**
```bash
psql -U your_username -d your_database -f data/setup.sql
```

---

## How to use this

1. Run `data/setup.sql`
2. Open any file in `examples/` — read it alongside the article section
3. Go to `practice/questions.sql` — write each query yourself
4. Check `practice/solutions.sql` after you've tried

---

## The full series

| Part | Topic | Repo |
|------|-------|------|
| Part 1 | Pulling data | [/part-1-select](../part-1-select) |
| Part 2 | Summarizing data | [/part-2-aggregates](../part-2-aggregates) |
| Part 3 | JOINs | [/part-3-joins](../part-3-joins) |
| Part 4 | Window functions | [/part-4-window-functions](../part-4-window-functions) |
| Part 5 | CTEs | [/part-5-ctes](../part-5-ctes) |
| **Part 6** | **Interview patterns** | **You are here** |

---

Questions or spot an error? Open an issue or drop a comment on the article.
