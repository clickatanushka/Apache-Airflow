select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select trend_signal
from "airflow"."analytics"."stock_performance"
where trend_signal is null



      
    ) dbt_internal_test