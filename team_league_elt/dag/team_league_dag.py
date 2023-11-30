import airflow
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from jinja2 import Template

from team_league_elt.dag.settings import Settings

settings = Settings()


def get_jinja_template(file_path: str) -> Template:
    with open(f'{settings.queries_path}/{file_path}') as fp:
        return Template(fp.read())


with airflow.DAG(
        "team_league_elt",
        default_args=settings.dag_default_args,
        schedule_interval=None) as dag:
    load_team_stats_raw_to_bq = GCSToBigQueryOperator(
        task_id='load_team_stats_raw_to_bq',
        bucket=settings.variables['team_stat_input_bucket'],
        source_objects=[settings.variables['team_stat_source_object']],
        destination_project_dataset_table=f'{settings.project_id}.{settings.dataset}.{settings.team_stat_raw_table}',
        source_format='NEWLINE_DELIMITED_JSON',
        compression='NONE',
        create_disposition=settings.variables['team_stats_raw_create_disposition'],
        write_disposition=settings.variables['team_stats_raw_write_disposition'],
        autodetect=True
    )

    compute_and_insert_team_stats_domain_query = get_jinja_template('compute_and_insert_team_stats_data.sql').render(
        project_id=settings.project_id,
        dataset=settings.dataset,
        team_stat_table=settings.team_stat_table,
        team_stat_raw_table=settings.team_stat_raw_table
    )

    compute_and_insert_team_stats_domain = BigQueryInsertJobOperator(
        task_id='compute_team_stats_domain',
        configuration={
            "query": {
                "query": compute_and_insert_team_stats_domain_query,
                "useLegacySql": False
            }
        },
        location='EU'
    )

    load_team_stats_raw_to_bq >> compute_and_insert_team_stats_domain
