with source as (
    select * from {{ source('public', 'raw_stock_prices') }}
),
cleaned as (
    select
        ticker,
        cast(date as date)            as price_date,
        round(cast(open as numeric), 2)   as open_price,
        round(cast(high as numeric), 2)   as high_price,
        round(cast(low as numeric), 2)    as low_price,
        round(cast(close as numeric), 2)  as close_price,
        cast(volume as bigint)            as volume,
        ingested_at
    from source
    where close is not null
)
select * from cleaned