with metrics as (
    select * from {{ ref('int_stock_metrics') }}
),
final as (
    select
        ticker,
        price_date,
        close_price,
        moving_avg_7d,
        daily_return_pct,
        volatility_30d,
        volume,
        case
            when close_price > moving_avg_7d then 'ABOVE_MA'
            else 'BELOW_MA'
        end as trend_signal
    from metrics
)
select * from final