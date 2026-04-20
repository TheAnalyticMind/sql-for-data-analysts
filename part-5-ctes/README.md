# SQL for Data Analysts — Part 5: CTEs

**Article:** [SQL for Data Analysts (Part 5): CTEs — Write SQL Like a Human]([https://soumyatripathy2101.medium.com/sql-for-data-analysts-part-5-ctes-write-sql-like-a-human-a492e258f0a6])
Subqueries work. CTEs communicate. This folder has everything you need to practice Common Table Expressions — from the basics to chained CTEs and recursive org charts.

---

## What's in here

```
part-5-ctes/
│
├── data/
│   └── setup.sql          ← Run this first. Creates tables + loads sample data.
│
├── examples/
│   ├── cte_basics.sql     ← CTE vs subquery — same result, different readability
│   ├── chained_ctes.sql   ← Multi-step reporting with chained CTEs
│   ├── null_pattern.sql   ← Finding reps with zero orders (LEFT JOIN + IS NULL)
│   └── recursive_cte.sql  ← Org chart hierarchy with a recursive CTE
│
└── practice/
    ├── questions.sql      ← 4 practice questions. Try these before looking at solutions.
    └── solutions.sql      ← Full solutions with explanations.
```

---

## Getting started

### Option 1 — DB Fiddle (no setup needed)
Go to [dbfiddle.uk](https://dbfiddle.uk), select **PostgreSQL 15**, paste in `data/setup.sql` and run it. Then write your queries in the right panel.

### Option 2 — Local PostgreSQL
```bash
psql -U your_username -d your_database -f data/setup.sql
```

### Option 3 — Any SQL editor
The setup file works with PostgreSQL, Snowflake, and BigQuery with minor adjustments (noted in the file).

---

## How to use this

1. Run `data/setup.sql` to create your tables
2. Open `examples/` — read through the queries in the same order as the article
3. Go to `practice/questions.sql` — try each one yourself
4. Check `practice/solutions.sql` when you're done

---

## The series so far

| Part | Topic | Repo |
|------|-------|------|
| Part 1 | Pulling data | [/part-1-select](../part-1-select) |
| Part 2 | Summarizing data | [/part-2-aggregates](../part-2-aggregates) |
| Part 3 | Combining data (JOINs) | [/part-3-joins](../part-3-joins) |
| Part 4 | Window functions | [/part-4-window-functions](../part-4-window-functions) |
| **Part 5** | **CTEs** | **You are here** |
| Part 6 | Coming soon | — |

---

## Questions or feedback?
Drop a comment on the Medium article or open an issue here. Always happy to explain something differently.
