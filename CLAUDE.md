# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dbt (Data Build Tool) project for product analytics at Frog Street Press. The project transforms raw data from multiple sources into analytical models for reporting and business intelligence.

## Commands

### dbt Development Commands
- `dbt deps` - Install dbt packages (run after cloning or when packages.yml changes)
- `dbt compile` - Compile SQL without running models
- `dbt run` - Run all models (builds staging, intermediate, and marts layers)
- `dbt run --models staging` - Run only staging models
- `dbt run --models intermediate` - Run only intermediate models  
- `dbt run --models marts` - Run only marts models
- `dbt run --models +model_name` - Run a specific model and its dependencies
- `dbt test` - Run all tests defined in .yml files
- `dbt test --models staging` - Run tests for staging models only
- `dbt docs generate` - Generate documentation
- `dbt docs serve` - Serve documentation locally

### Environment-Specific Development
- Development environment automatically limits large models (see `target.name == 'dev'` logic in models)
- Production environment uses custom schema names (staging, intermediate, marts)
- Development uses default schema for all models

## Architecture

### Data Sources
The project integrates three primary data sources:
- **Taco**: PostgreSQL database containing user management data (districts, users, enrollments, applications, programs)
- **Lilypad**: Event logging system capturing user interactions and behavior
- **Craft**: PostgreSQL database with program and resource information

### Model Structure

**Staging Layer** (`models/staging/`)
- Raw data cleaning and standardization
- Source-specific models prefixed by system (e.g., `stg_taco__users`, `stg_lilypad__events_log`)
- One-to-one relationship with source tables
- Basic data type casting and column renaming

**Intermediate Layer** (`models/intermediate/`)
- **Dimensions**: Slowly changing dimension tables (e.g., `dim_users_current`, `dim_districts_current`)
- **Facts**: Event-based fact tables (`fct_events`)
- **Intermediate Logic**: Complex transformations and enrichment (`int_events_enriched`)
- Business logic and joins between staging models

**Marts Layer** (`models/marts/`)
- Final analytical models for reporting
- Aggregated and denormalized for performance
- Example: `rpt_user_events_per_day` aggregates daily user activity metrics

### Key Patterns

**Event Processing**
- Events from Lilypad are enriched with dimensional information
- Complex regex parsing extracts IDs from event paths and values
- Boolean flags identify specific event types (login, planner open, app launch)
- Event value mapping determines join relationships (program_id, resource_id, etc.)

**Schema Management**
- Custom schema macro (`generate_custom_schema.sql`) manages environment-specific schema naming
- Production: uses schema suffixes (staging, intermediate, marts)
- Development: uses default schema for all models

**Testing Strategy**
- Primary key uniqueness and not-null tests on all staging models
- Custom business logic tests (e.g., unique district-program combinations)
- Source freshness monitoring configured but commented out

### Dependencies
- **dbt-utils** (v1.3.0): Utility macros for common transformations
- Uses dbt Cloud CLI (v0.40.5)

## Development Notes

### Code Conventions
- Follow [Frog Street naming conventions and SQL conventions](https://frogstreetpress-my.sharepoint.com/:w:/g/personal/dwixon_frogstreet_com/EXm03D8fpfhGnTTbCtjoqckBc9QV-JOj4ZJM6HRMc5fXoA?e=3eKJXt)
- Use CTE pattern with descriptive names
- Always include a `final` CTE before the final select
- Comment complex transformations and business logic
- Use consistent indentation (4 spaces)

### Data Quality
- All staging models have primary key tests
- Source relationships are documented in `_sources.yml` files
- Models exclude students (`user_role != 'student'`) from user dimensions
- Development environment uses row limits to manage data volume

### Event Analytics
- Event enrichment logic in `int_events_enriched.sql` requires ongoing maintenance as new event types are added
- Many join relationships are marked as "TAG TO DO" and need investigation
- Event path parsing uses regex to extract program_id and resource_id from URLs