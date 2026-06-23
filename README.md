# tap — BigQuery analytics pipeline

dbt-core project for TAP school activity access reporting on BigQuery.

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
dbt compile --select +school_access_rates
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

## School access rate pipeline

Your SQL query is split into layered dbt models:

| Layer | Model | Purpose |
|-------|-------|---------|
| Source | `glific.contacts`, `glific.messages` | Raw BigQuery tables |
| Intermediate | `glific_contacts` | Incremental contact extract |
| Intermediate | `glific_messages` | Incremental message extract |
| Intermediate | `student_contacts` | Filtered TLM25 students with school name |
| Intermediate | `total_activities` | Activity flow labels (Jul 2025–Jun 2026) |
| Intermediate | `activity_catalog` | Activities excluding access/submission/complete |
| Intermediate | `activity` | Total activities sent per student |
| Intermediate | `student_access` | Activities accessed per student |
| Intermediate | `student_access_rates` | Per-student access rate |
| Prod | `school_access_rates` | Final school-level rollup (top 50 schools) |

Validate locally (no BigQuery):

```bash
dbt compile --select +school_access_rates
```

Run in BigQuery (approved warehouse runs only):

```bash
dbt run --select +school_access_rates
dbt test --select school_access_rates
```

## Weekly sync (GitHub Actions)

The pipeline runs automatically every **Sunday at 12:05 AM IST** (Saturday 18:35 UTC) via `.github/workflows/weekly-sync.yml`.

It runs:

1. `dbt deps`
2. `dbt run --select +school_access_rates`
3. `dbt test --select school_access_rates`

### One-time GitHub setup

Add these repository secrets in GitHub → **Settings → Secrets and variables → Actions**:

| Secret | Value |
|--------|-------|
| `GCP_SA_KEY` | Full JSON contents of the BigQuery service account key |
| `BQ_PROJECT` | `central-phalanx-297915` |
| `BQ_DATASET` | `MEL_2025_26` (optional; defaults to this value) |

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
├── dbt_project.yml          # Project config (profile: tap)
├── models/
│   ├── staging/glific-bigquery/   # Source definitions
│   ├── intermediate/glific/       # Transformation models
│   ├── intermediate/crm/          # CRM models
│   └── prod/                      # Final reporting tables
├── macros/
├── tests/
└── packages.yml
```

Built tables use dbt's default schema naming from your `profiles.yml` target and per-model `schema` config.
