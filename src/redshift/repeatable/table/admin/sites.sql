drop table if exists admin.sites;

CREATE TABLE admin.sites (
    site_id bigint,
    site_name text ENCODE raw
)
SORTKEY ( site_id );

