{{ config(materialized='table',tags=["quality"]) }}

WITH histo_anomalies AS (
    SELECT *
    FROM {{ ref('l02_histo_anomalies') }}
)

SELECT
    id_anomaly
    ,id_run
    ,nam_test
    ,id_context
    ,id_session
    ,anomaly_column_value
    ,value_date
    ,value_numeric
    ,value_string
    ,id_anomaly_first_apparition
    ,dat_first_apparition
    ,flg_apparition
    ,max_rn_monitor - min_rn_monitor as num_occurence_par_session
    ,dat_first_apparition_without_error
FROM histo_anomalies
