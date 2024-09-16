-- testing toooooo
    
    {{
    config(
        alias='member_survey_questions_dictionary',        
        materialized='incremental',
        incremental_strategy='append',        
        schema = 'derived_surveys'
    )
}}


SELECT
    index ,
    field_name ,
    section ,
    question ,
    sub_question ,
    question_description ,
    sub_question_description ,
    data_type ,
    survey_id ,    
    load_date_nzt
FROM
    {{ ref("raw_member_survey_questions_dictionary") }}
{% if is_incremental() %}
  where DATE(load_date_nzt) > (select max(DATE(load_date_nzt)) from {{ this }})
{% endif %}
