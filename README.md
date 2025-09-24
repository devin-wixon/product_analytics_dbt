## Naming and SQL conventions
[Frog Street naming conventions and SQL conventions](https://frogstreetpress.sharepoint.com/:w:/s/DigitalProductInitiatives/EV-INo38NwBHgZcXYL1sL_sBRfTpPyxD-4D_kT9ojQVWNA?e=r7Xyen)

## To run the exports
Functional requirements for Tableau BI:
* Flexibility to specify up to two levels of aggregation dimensions, while looking at daily, weekly or monthly grain
* Viz's should not take longer than 10 seconds to generate

This workflow allows for maximum flexbility for a BI tool while ensuring storng performance, because Tableau takes 30+ seconds to run a query when directly connected to the semantic layer.

It also limits query costs and avoids any metric calculation limits in the Starter plan.

When changes need to be made to the exports for BI
1. cd into scripts and run `python3 generate_saved_queries.py`. This builds
- `models/semantic_models/saved_queries_export_generated.yml`
Saved queries with all, single dimension, and 2 x dimension combinations, along with their export configurations

- /models/staging/query_exports/_sources_semantic_exports.yml
The created export names as sources for the rpt model

- /models/marts/bi_sl_exports_as_sources/rpt_exports_time_grains_dims.sql
The rpt model for BI

2. Run dbt commands (add them to jobs separately, or look for the specific job)

To return both the saved queries and their exports, run: 
`dbt build --select resource_type:saved_query`

To run the resulting model for BI reports, run
`dbt build --select rpt_exports_time_grains_dims`

Exports are built incrementally. If changes need to be run for all dates, run:
`dbt build --select resource_type:saved_query --full-refresh`


### Resources
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
