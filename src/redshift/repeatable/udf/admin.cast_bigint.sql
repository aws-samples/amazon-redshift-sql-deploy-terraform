
CREATE OR REPLACE FUNCTION admin.cast_bigint (
character varying
)
RETURNS bigint
STABLE
AS $$

    select 
        case when $1 = '' then null
             when $1 = 'None' then null
             when length($1)<18 then cast($1 as bigint) 
             else 0 
        end

$$ LANGUAGE sql;