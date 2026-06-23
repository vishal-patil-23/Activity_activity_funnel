# tap — Activity Funnel (BigQuery)

dbt-core project for TAP activity funnel analytics on BigQuery. Warehouse runs materialize all models into the **Activity_Funnel** demo dataset.

## Prerequisites

- Python 3.11+
- BigQuery service account JSON key
- Git

### Layer flow

```mermaid
flowchart LR
    subgraph sources [Sources]
        C[glific.contacts]
        M[glific.messages]
    end

    subgraph bronze [Bronze]
        GC[glific_contacts]
        GM[glific_messages]
    end

    subgraph silver [Silver]
        SC[student_contacts]
        TA[total_activities]
        AC[activity_catalog]
        A[activity]
        SA[student_access]
        SAR[student_access_rates]
    end

    subgraph gold [Gold]
        SAR2[school_access_rates]
    end

    C --> GC
    M --> GM
    GC --> SC
    GM --> TA
    TA --> AC
    AC --> A
    SC --> SA
    TA --> SA
    SA --> SAR
    A --> SAR
    SAR --> SAR2
```

## Project structure

```
tap/
├── dbt_project.yml
├── models/
│   ├── staging/glific-bigquery/   # Source definitions
│   ├── bronze/
│   ├── silver/
│   └── gold/
└── requirements.txt
```
