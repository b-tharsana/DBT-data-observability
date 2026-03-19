{{ config(materialized='view', tags=["quality"]) }}

with 
    histo_anomalies as (select 
                          * 
                        from  {{ source('sources_common_audit','HISTO_FAILURES_TABLE')}})
    ,monitor as (select *
                        ,ROW_NUMBER() OVER (PARTITION BY nam_test ORDER BY dat_execution asc) as rank_monitor
                 from {{ source('sources_common_audit','MONITOR_TABLE')}})
    ,join_table as (select histo_anomalies.*
                    ,monitor.dat_execution
                    ,monitor.nam_test
                    ,monitor.rank_monitor
                    ,monitor.column_data_type
                    ,ROW_NUMBER() OVER (PARTITION BY id_context, nam_test ORDER BY dat_execution asc) as rank_histo
                    from histo_anomalies
                    left join monitor on histo_anomalies.id_run = monitor.id_run
    )

select
    id_anomaly,
    cast(id_run as int) as id_run,
    id_context,
    anomaly_column_value,
    dat_execution,
    nam_test,
    rank_monitor,
    rank_histo,
    rank_monitor - rank_histo as id_session,
    min(rank_monitor) OVER (
        PARTITION BY
            id_context,
            nam_test,
            rank_monitor - rank_histo
    ) as min_rn_monitor,
    max(rank_monitor) OVER (
        PARTITION BY
            id_context,
            nam_test,
            rank_monitor - rank_histo
    ) + 1 as max_rn_monitor,
    case 
        when column_data_type = 'datetime' then try_cast(anomaly_column_value AS datetime)
    end AS value_date,
    case 
        when column_data_type = 'int' then try_cast(anomaly_column_value as int)
        when column_data_type = 'decimal' then try_cast(anomaly_column_value as decimal(18,2))
    end AS value_numeric,
    case 
        when column_data_type = 'varchar' or column_data_type = 'nvarchar' then try_cast(anomaly_column_value as varchar)
    end AS value_string
from join_table
