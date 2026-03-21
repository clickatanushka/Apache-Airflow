
    
    

with all_values as (

    select
        ticker as value_field,
        count(*) as n_records

    from "airflow"."analytics"."stg_stock_prices"
    group by ticker

)

select *
from all_values
where value_field not in (
    'AAPL','GOOGL','MSFT','AMZN','META','TSLA','NFLX','NVDA','JPM','BAC'
)


