with base as (
    select * from {{ ref('stg_stock_prices') }}
),
with_metrics as (
    select
        *,
        round(
            avg(close_price) over (
                partition by ticker
                order by price_date
                rows between 6 preceding and current row
            ), 2
        ) as moving_avg_7d,

        round(
            (close_price - lag(close_price) over (
                partition by ticker order by price_date)
            ) / nullif(lag(close_price) over (
                partition by ticker order by price_date), 0) * 100
        , 2) as daily_return_pct,

        round(
            stddev(close_price) over (
                partition by ticker
                order by price_date
                rows between 29 preceding and current row
            ), 2
        ) as volatility_30d
    from base
)
select * from with_metrics