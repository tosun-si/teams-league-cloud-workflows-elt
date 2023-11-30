import os
from dataclasses import dataclass
from datetime import timedelta

from airflow.models import Variable
from airflow.utils.dates import days_ago

_variables = Variable.get("team_league_elt", deserialize_json=True)
_feature_name = _variables["feature_name"]


@dataclass
class Settings:
    dag_folder = os.getenv("DAGS_FOLDER")
    dag_default_args = {
        'depends_on_past': False,
        'email': ['airflow@example.com'],
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 0,
        'retry_delay': timedelta(minutes=5),
        "start_date": days_ago(1)
    }
    project_id = os.getenv("GCP_PROJECT")
    queries_path = os.path.join(
        dag_folder,
        _feature_name,
        'dag',
        'queries'
    )

    dataset = _variables["dataset"]
    team_stat_raw_table = _variables["team_stat_raw_table"]
    team_stat_table = _variables["team_stat_table"]

    variables = _variables
