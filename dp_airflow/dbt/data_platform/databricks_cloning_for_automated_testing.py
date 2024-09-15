import os
import time

from databricks.sdk import WorkspaceClient
from databricks.sdk.service import sql

databricks_host_red = os.getenv('DATABRICKS_HOST_RED')
databricks_token_red = os.getenv('DATABRICKS_TOKEN_RED')
sql_warehouse_id = '86ea000000000'

red_w = WorkspaceClient(host=databricks_host_red,
                        token=databricks_token_red)

qual_srcs = red_w.data_sources.list()

source_catalog = 'prod'
source_schema = 'derived_surveys'
source_table = 'member_survey_questions_dictionary'

target_catalog = 'qual'
target_schema = 'derived_surveys'
target_table = 'member_survey_questions_dictionary'

# for testing a single table 
# source_ = f'{source_catalog}.{source_schema}.{source_table}'
# target_ = f'{target_catalog}.clone_{target_schema}.{target_table}'


list_source_schemas = red_w.schemas.list(catalog_name=source_catalog)
# to update source_schema
list_source_tables = red_w.tables.list(catalog_name=source_catalog,
                                       schema_name=source_schema)

# not use yet
for schema in list_source_schemas:
    source_schema_name = schema.name

# use clone as prefix or otherwise need to drop the table first that is in qual from dbt build with different table type
# to update source_schema
create_schema_statement = f"CREATE SCHEMA IF NOT EXISTS clone_{source_schema}" 
print(create_schema_statement)

schema_for_cloning = red_w.statement_execution.execute_statement(
                                warehouse_id=sql_warehouse_id,
                                catalog=target_catalog,
                                statement=create_schema_statement
)

def check_status(statement_sql=schema_for_cloning, wait_time=300, sleep_time=50):

# Hybrid mode (default) - wait_timeout=10s and on_wait_timeout=CONTINUE
    elapsed_time = 10

    while elapsed_time < wait_time:
        check_ = red_w.statement_execution.get_statement(statement_sql.statement_id)

        if check_.status.state == sql.StatementState.SUCCEEDED:
            print(f"{check_.status.state} {elapsed_time}s")
            break
        
        elif check_.status.state in [sql.StatementState.PENDING, sql.StatementState.RUNNING]:
            print(f"{check_.status.state} {elapsed_time}s")
            time.sleep(sleep_time)
            elapsed_time += sleep_time
        else:
            print(f"{check_.status} {elapsed_time}s")
            break
    else:
        print(f"exceeding {elapsed_time}s")
        # red_w.statement_execution.cancel_execution(statement_sql.statement_id)

check_status()


for table in list_source_tables:
    source_table_name = table.name
    # to update source_schema target_schema
    source_ = f'{source_catalog}.{source_schema}.{source_table_name}'
    target_ = f'{target_catalog}.clone_{target_schema}.{source_table_name}'

    shallow_clone_statement = f"CREATE OR REPLACE TABLE {target_} SHALLOW CLONE {source_}"
    print(shallow_clone_statement)

    cloning = red_w.statement_execution.execute_statement( 
                                warehouse_id=sql_warehouse_id,
                                catalog=target_catalog,
                                statement=shallow_clone_statement
    )
    
    check_status(statement_sql=cloning)

for src in qual_srcs:
    print(vars(src)) 
