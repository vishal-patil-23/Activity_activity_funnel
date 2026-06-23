# tap — Activity Funnel (BigQuery)

dbt-core project for TAP activity funnel analytics on BigQuery. Warehouse runs materialize all models into the **Activity_Funnel** demo dataset.

## Prerequisites

- Python 3.11+
- BigQuery service account JSON key
- Git

## Setup

```bash
# Clone the repo
git clone https://github.com/vishal-patil-23/tap.git
cd tap

# Create virtual environment and install dependencies
python -m venv .dbtenv
source .dbtenv/bin/activate
pip install -r requirements.txt

# Install dbt packages
dbt deps
```

Configure BigQuery credentials in `~/.dbt/profiles.yml`:

```yaml
tap:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: central-phalanx-297915
      dataset: MEL_2025_26
      keyfile: /path/to/your-service-account.json
      location: US
      threads: 4
```

## Local development (no BigQuery execution)

For day-to-day work on models, macros, and tests, use **local validation only**. These commands compile and check the project on your machine without running queries or writing tables in BigQuery:

```bash
dbt parse
dbt compile --select tag:activity_funnel
```

The following commands **execute against BigQuery** and should only be run when you explicitly intend to build or test in the warehouse (e.g. scheduled jobs, approved manual runs):

| Command | Effect |
|---------|--------|
| `dbt debug` | Tests live BigQuery connection |
| `dbt run` | Creates/updates tables and views |
| `dbt test` | Runs data quality checks in BigQuery |
| `dbt build` | Runs models and tests |
| `dbt seed` / `dbt snapshot` | Writes data to BigQuery |

Do not run warehouse commands during local development unless you have approved access and intend to materialize results.

## Activity Funnel pipeline

All models are tagged `activity_funnel`. Warehouse runs build the full funnel into BigQuery:

| Layer | Dataset | Models |
|-------|---------|--------|
| Source | `918454812392` | `contacts`, `messages` (read-only) |
| Intermediate | `Activity_Funnel_intermediate` | `glific_contacts`, `glific_messages`, `student_contacts`, `total_activities`, `activity_catalog`, `activity`, `student_access`, `student_access_rates` |
| Prod | `Activity_Funnel` | `school_access_rates` |

### Model flow

```
glific.contacts ──► glific_contacts ──► student_contacts ──┐
glific.messages ──► glific_messages ──► total_activities ──┼──► student_access ──► student_access_rates ──► school_access_rates
                          │                                 │
                          └──► activity_catalog ──► activity ┘
```

Validate locally (no BigQuery):

```bash
dbt compile --select tag:activity_funnel
```

Run in BigQuery (approved warehouse runs only):

```bash
dbt build --select tag:activity_funnel
```

This creates/updates all Activity Funnel tables in the `Activity_Funnel` dataset family.

## Weekly sync (GitHub Actions)

The pipeline runs automatically every **Sunday at 12:05 AM IST** (Saturday 18:35 UTC) via `.github/workflows/weekly-sync.yml`.

It runs:

1. `dbt deps`
2. `dbt build --select tag:activity_funnel` (all Activity Funnel models + tests)

Output lands in BigQuery dataset **`Activity_Funnel`** (prod) and **`Activity_Funnel_intermediate`** (intermediate models).

### One-time GitHub setup

Add these repository secrets in GitHub → **Settings → Secrets and variables → Actions**:

| Secret | Value |
|--------|-------|
| `GCP_SA_KEY` | Full JSON contents of the BigQuery service account key |
| `BQ_PROJECT` | `central-phalanx-297915` |
| `BQ_DATASET` | `Activity_Funnel` (optional; defaults to this value) |

Trigger a run manually from **Actions → Weekly TAP sync → Run workflow**.

## Git workflow

```bash
# Check status
git status

# Stage and commit changes
git add models/
git commit -m "Describe your change"

# Push to GitHub
git push origin main
```

Remote: https://github.com/vishal-patil-23/tap

## Project structure

```
tap/
├── dbt_project.yml          # Project config (profile: tap, tag: activity_funnel)
├── models/
│   ├── staging/glific-bigquery/   # Source definitions
│   ├── intermediate/glific/       # Transformation models
│   └── prod/                      # Final reporting tables
├── tests/
└── packages.yml
```

Warehouse tables use dbt default schema naming: prod models in `Activity_Funnel`, intermediate models in `Activity_Funnel_intermediate`.
