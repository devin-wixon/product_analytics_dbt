{% docs generate_schema_name_description %}
This is a built-in dbt macro that changes the dataset name based on `target` and `+schema` config.

* If `target` == `prod`, then models will deploy to separate datasets based on `+schema` config set in `dbt_project.yml`. For example:
   * `staging`
   * `warehouse`
* For any non-`prod` deployment, all models will deploy to the default dataset as indicated in `profiles.yml`. For example:
   * `dev_mkahan`
   * `dev_jdoe`

More information can be found at the dbt docs site [here](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/using-custom-schemas#how-does-dbt-generate-a-models-schema-name)

{% enddocs %}