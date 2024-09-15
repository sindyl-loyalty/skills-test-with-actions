{{
    config(
        alias='member_survey_codes_dictionary',        
        materialized='incremental',
        incremental_strategy='append',        
        schema = 'published_surveys'
    )
}}


SELECT
    index ,
    field_name ,
    code ,
    code_label ,
    survey_id ,
    load_date_nzt
FROM
    {{ref("transformed_member_survey_codes_dictionary")}}
{% if is_incremental() %}
  where load_date_nzt > (select max(load_date_nzt) from {{ this }})
{% endif %}
