{{
    config(
        alias='member_survey_questions_dictionary',            
        materialized='streaming_table',        
        schema = 'raw_surveys'
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
    right(cast(split(_metadata.file_path, '/',9)[5] as string) , 36 ) as survey_id ,
    right(cast(split(_metadata.file_path, '/',9)[6] as string) , 10) as load_date_nzt
FROM
    stream read_files(
    's3://nz-co-loyalty-production-raw/member_surveys/member.survey.questions.dictionary/',
    format => 'csv',
    header => 'true',
    sep => '|',
    lineSep => '\n',
    ignoreTrailingWhiteSpace => 'true'
  )
