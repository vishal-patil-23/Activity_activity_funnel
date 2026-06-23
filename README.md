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

Verify the connection:

```bash
dbt debug
```

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

Run only the school access pipeline:

```bash
dbt run --select +school_access_rates
```

Run tests:

```bash
dbt test --select school_access_rates
```

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

Built tables land in BigQuery datasets prefixed with `dalgo_` (see `macros/generate_schema_name.sql`).
