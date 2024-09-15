{{
    config(
        alias='member_survey_questions_dictionary',        
        materialized='incremental',
        incremental_strategy='append',        
        schema = 'published_surveys'
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
    {{ref("transformed_member_survey_questions_dictionary")}}
{% if is_incremental() %}
  where load_date_nzt > (select max(load_date_nzt) from {{ this }})
{% endif %}
