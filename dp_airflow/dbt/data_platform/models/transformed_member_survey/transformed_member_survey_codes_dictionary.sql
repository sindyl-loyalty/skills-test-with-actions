{{
    config(
        alias='member_survey_codes_dictionary',        
        materialized='incremental',
        incremental_strategy='append',
        tags = ["loyaltyHub_migration"],
        schema = 'transformed_surveys'
    )
}}


SELECT
    index ,
    field_name ,
    code ,
    code_label ,
    survey_id ,
    DATE(load_date_nzt) AS load_date_nzt
FROM
    {{ ref("derived_member_survey_codes_dictionary") }}
{% if is_incremental() %}
  where DATE(load_date_nzt) > (select max(load_date_nzt) from {{ this }})
{% endif %}
