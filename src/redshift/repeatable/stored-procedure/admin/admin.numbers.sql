CREATE TABLE admin.numbers (
    number bigint ENCODE raw
)
DISTSTYLE ALL
SORTKEY ( number );

TRUNCATE admin.numbers;

insert into admin.numbers
with recursive numbers(NUMBER) as
(
select 1 UNION ALL
select NUMBER + 1 from numbers where NUMBER < 1000
)
select * from numbers;
