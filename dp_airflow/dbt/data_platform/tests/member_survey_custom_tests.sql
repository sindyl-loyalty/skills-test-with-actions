-- singular data test for member survey questions dictionary to validate the structure of specified fields
-- return records where the field structure deviates from the expected format and make the test fail

WITH field_structure_check AS (
    SELECT
        field_name,
        section,
        question,
        sub_question,
        CASE
            WHEN field_name LIKE 's%' AND
                 section = REGEXP_SUBSTR(field_name, '^s[0-9]{1,2}') AND
                 question = REGEXP_SUBSTR(field_name, 'q[0-9]{1,2}[a-z]*') AND
                 (                  
                  REPLACE(sub_question, '_', '') = REPLACE(SUBSTRING(field_name, LENGTH(section) + LENGTH(question) + 1), '_', '')                  
                  OR sub_question IS NULL
                 ) THEN 'valid'
            WHEN field_name NOT LIKE 's%' AND
                 section = 'id' AND
                 question = field_name AND
                 (
                  sub_question = field_name
                  OR sub_question IS NULL
                 ) THEN 'valid'
            ELSE 'invalid?' --TO DO: to check with analysts if this is required and what is expected
        END AS structure_validity
    FROM {{ ref('published_member_survey_questions_dictionary') }}
)
SELECT *
FROM field_structure_check
WHERE structure_validity = 'invalid'
