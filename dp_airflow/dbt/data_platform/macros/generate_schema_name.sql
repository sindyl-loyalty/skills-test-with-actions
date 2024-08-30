@@ -1,14 +1,14 @@
-- This macro generates different schema name when running dbt in different environments.
-- If runs in Airflow, it will use the schema name in the dbt project yml file.
-- If runs in the local machine, it will add the default_schema as the prefix to the schema name.
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- elif target.name == 'local' and custom_schema_name is not none -%}
    {%- elif (target.name == 'local' or target.name == 'predeployment') and custom_schema_name is not none -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
