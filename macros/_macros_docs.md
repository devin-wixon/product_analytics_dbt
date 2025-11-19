{% docs generate_schema_name_description %}
This is a built-in dbt macro that changes the dataset name based on `target` and `+schema` config.

* If `target` == `prod`, then models will deploy to separate datasets based on `+schema` config set in `dbt_project.yml`. For example:
   * `staging`
   * `warehouse`
* For any non-`prod` deployment, all models will deploy to the default dataset as indicated in `profiles.yml` or in the dbt Cloud user configuration. For example:
   * `dbt_devin`
   * `dbt_jdoe`

More information can be found at the dbt docs site [here](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/using-custom-schemas#how-does-dbt-generate-a-models-schema-name)

{% enddocs %}


{% docs is_distributed_demo_district_description %}
This macro identifies demo districts distributed to over 1,000 organizations to use during Back to School 2025 onboarding.

The macro takes a `district_id` as input and returns a boolean case statement that evaluates to `true` if the district is in a hardcoded list, such as:
* 7871 - bts2025demo - Frog Street Back to School 2025 [expires 9/30/2025]
* 7877 - bts2025tk - Back to School 2025 TK [expires 9/30/2025]
* 7870 - bts2025tx - Back to School 2025 Texas [expires 9/30/2025]

```

**Returns:** Boolean (true/false) indicating whether the district_id matches one of the distributed demo districts.
{% enddocs %}


{% docs dev_limit_description %}
Applies a row limit in Development to speed up model builds. Production and other environments always run with full data.

By default, limits to the number of rows specified in the macro call (default: 100). Can be disabled or overridden at runtime:
* To disable: `dbt run --vars '{disable_dev_limit: true}'`
* To override: `dbt run --vars '{dev_limit_rows: 500}'`
{% enddocs %}


{% docs assign_event_type_description %}
Assigns each `event_category` value a higher-level event type based on a hardcoded mapping for reporting.  
**Returns:** String value representing the event type, or NULL if the event_category doesn't have a defined mapping.
{% enddocs %}