# Product Analytics dbt Project

A dbt project for transforming product usage data from Taco (user management), Lilypad (event logging), and Craft (content metadata) into analytics-ready models for business intelligence and reporting.

## Table of Contents

- [Key Resources](#key-resources)
- [Getting Started](#getting-started)
  - [Session Settings](#session-settings)
- [Project Structure](#project-structure)
  - [Event Logic](#event-logic)
  - [Incremental Models](#incremental-models)
- [Development-Specific Commands](#development-specific-commands)
- [Data Governance](#data-governance)
- [Documentation](#documentation)
- [External Documentation](#external-documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Key Resources

### SQL structure and naming conventions
[Frog Street naming conventions and SQL conventions](https://frogstreetpress.sharepoint.com/:w:/s/DigitalProductInitiatives/EV-INo38NwBHgZcXYL1sL_sBRfTpPyxD-4D_kT9ojQVWNA?e=r7Xyen)

### BI architecture documentation
[Frog Street ELT architecture](https://docs.google.com/document/d/1PtDJjHb2N9-TiZ3PPz8zCkpQA0owPq8u2GB28p8TuE0/edit?usp=sharing)

## Getting Started

### Prerequisites

This is a dbt Cloud project.

- dbt Cloud access for: data catalog, job orchestration, job results
- dbt Cloud CLI; see dbt docs for installation instructions
- Access to Snowflake data warehouse
- Git for version control

### Initial Setup

   ```bash
   git clone <repository-url>
   cd product_analytics_dbt
   dbt debug # validates environment
   dbt deps # installs packages
   dbt compile
   ```

Packages include:
   - `dbt_utils`- Common utility macros
   - `elementary`  - Data observability and monitoring
   - `dbt_project_evaluator` - Project structure and best practices validation

In VS Code, install the dbt power user extension.

### Environment Configuration

The project uses environment-specific configurations:

- **Development (`dev`)**: Uses default schema, includes row limits on large tables; option to run project evaluator if specified
- **CI (`ci`)**: Runs full test suite and project evaluator with error severity
- **Production (`prod`)**: Uses custom schemas (staging, intermediate, warehouse, marts), skips project evaluator for performance

### Session Settings

**Timezone**
UTC timezone is enforced for all dbt runs:
```yaml
on-run-start:
  - "ALTER SESSION SET TIMEZONE = 'UTC'"
```

This is important for snapshots and other transformations, as timestamps in source data are stored in UTC.

## Project Structure

```
product_analytics_dbt/
├── models/
│   ├── staging/              # Source-conformed models (1:1 with source tables)
│   │   ├── craft/           # Content metadata from Craft system
│   │   ├── lilypad/         # Event logs from Lilypad tracking
│   │   └── taco/            # User management from Taco system
│   ├── intermediate/         # Business logic transformations
│   │   └── int_*.sql        # Intermediate models with enrichment
│   ├── warehouse/           # Dimensional warehouse models
│   │   ├── dimensions/      # Slowly changing dimensions (dim_*)
│   │   ├── facts/           # Event-level fact tables (fct_*)
│   │   └── aggregates/      # Pre-aggregated metrics (agg_*)
│   ├── marts/               # Analytics-ready reporting models (rpt_); the only schema exposed for BI & analytics
│   ├── semantic_models/     # MetricFlow semantic layer definitions
│   └── metrics/             # Business metric definitions
├── snapshots/               # SCD Type 2 snapshots of slowly changing data
├── seeds/                   # CSV reference data and configuration
├── tests/                   # Custom data tests
│   └── generic/            # Reusable test definitions
├── macros/                  # Custom SQL macros and utilities
└── analyses/               # Ad-hoc analytical queries
```


Models follow consistent naming patterns based on their layer; see [Frog Street ELT architecture](https://docs.google.com/document/d/1PtDJjHb2N9-TiZ3PPz8zCkpQA0owPq8u2GB28p8TuE0/edit?usp=sharing).

**Note:** In some cases, the `ip` prefix indicates "in progress" models under active development.

### Event Logic

The `int_events_enriched` model performs complex enrichment of raw events using the CSV `seed_event_log_metadata.csv`.

- Extracts IDs from event paths using pattern matching
- Maps events to dimensional entities (programs, resources, users)
- Classifies events into business categories (login, planner, app launch)
- Requires maintenance when new event names are added; a relationship test will warn if names are not in the metadata CSV

### Incremental Models

Event-based models use incremental materialization with an `append` strategy to optimize performance and reduce warehouse costs. This also maintains the `event_id` values, as they are created in the pipeline. Incremental models filter new data using date-based logic (typically on `server_event_date` or `server_timestamp`) and track batch processing via `dbt_row_batch_id` for pipeline observability.

To identify incremental models, search for `materialized='incremental'` in model configurations. To rebuild an incremental model from scratch when needed, use: `dbt build --full-refresh --models <model_name>`

## Development-Specific Commands

- Snapshots:  
Run on a schedule in production and should not be run manually in development. Consider using `favor-state` as needed; see [defer docs](https://docs.getdbt.com/reference/node-selection/defer) to avoid building snapshots in dev layer.

- Project evaluator:
Requires `--vars '{run_project_evaluator: true}'` in development. See [dbt Project Evaluator](#dbt-project-evaluator) section for details.
    - `dbt run --vars '{run_project_evaluator: true}'`
    - `dbt build --vars '{run_project_evaluator: true}'`

- Development limits:  
Some models limit rows in development. To override this for testing in dev, use the macro variable.
Example run of `fct_events` without a development limit:  
`dbt run -s fct_events --vars '{disable_dev_limit: true}'`


## Data Governance

### Data Quality Framework

The project uses a multi-layered testing strategy to ensure data quality:

1. **Source freshness checks**: Monitor data recency (configured in `_sources.yml` files)
2. **Model tests**: Unique keys, relationships, accepted values. 
3. **Relationship tests**: Foreign keys have testing to ensure only known prior orphans exist.
4. **dbt Project Evaluator**: Enforce project structure and best practices
5. **Elementary monitoring**: Track anomalies and data health (production only), including schema changes for all source models

### dbt Project Evaluator

The dbt Project Evaluator package validates project structure, naming conventions, and best practices.

Project evaluator rules are configured in `dbt_project.yml`, and exceptions are provided in the seed `dbt_project_evaluator_exceptions.csv`.

#### Key Validations

The project evaluator checks for issues including the below.

- **Naming conventions**: Models follow layer-specific prefixes
- **Documentation**: All models have minimal documentation
- **Testing**: All models have minimal tests
- **Structure**: Models are organized in correct directories
- **Dependencies**: No circular dependencies or inappropriate references
- **Sources**: Source freshness is configured

Project evaluator is configured in `dbt_project.yml` and exceptions are in a seed CSV.

## Documentation

### Documentation Standards

All models should include in their `.yml` files:

```yaml
models:
  - name: model_name
    description: |
        Purpose:
        Granularity:
        Filters:
        Notes:
    columns:
      - name: column_name
        description: "{{ doc('column_doc_block') }}"  # Use doc blocks; avoid repeating column name
```

**Documentation guidelines:**
- Prefer doc blocks over inline descriptions (exception: columns unique to one model)
- Descriptions should add information content, not repeat the column name
- Example: "a student's unique identifier" adds no value for `student_id`

### Macro documentation
- Comments within macro regarding expected behaviors and arguments
- Doc block in `macros_docs.md` with brief, high-level definition
- Doc block referenced in `macros_definitions.yml`

### Lineage and Dependencies

Use dbt Cloud Catalog to explore:
- **Lineage graph**: Visual representation of model dependencies
- **Source relationships**: See how source data flows through the project

Use dbt Power User to explore:
- **Column lineage**: Track specific columns through transformations


## External Documentation

- [dbt Documentation](https://docs.getdbt.com)
- [dbt Utils Package](https://hub.getdbt.com/dbt-labs/dbt_utils)
- [dbt Project Evaluator](https://dbt-labs.github.io/dbt-project-evaluator)
- [Elementary Data Observability](https://docs.elementary-data.com)
- [Snowflake Documentation](https://docs.snowflake.com)

## Troubleshooting

### Getting Help

1. Check dbt logs in `logs/dbt.log`
2. Review compiled SQL in `target/compiled/`
3. Consult project documentation: `dbt docs serve`
4. Review [dbt Discourse](https://discourse.getdbt.com) for community help

## Contributing

### Before Opening a PR

1. Build models locally: `dbt build --models <your_changes>`
2. Run project evaluator: `dbt run --vars '{run_project_evaluator: true}'`

The PR template contains detailed sections to complete for documenting changes.

---
**Project Version:** 1.0.0
**Last Updated:** 2025-11-20
**Maintainers:** Devin Wixon, dwixon@frogstreet.com
