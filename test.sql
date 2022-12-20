.load target/debug/libulid0
.mode quote
.header on

select ulid_bytes();

.mode box
select ulid(), null as '           ulid_bytes()            ', ulid_with_prefix("invoice_");

select ulid_datetime('01GMP2G8ZG6PMKWYVKS62TTA41');


create table events(
  id text primary key,
  data json
);

insert into events
  select
    ulid_with_prefix('event') as id,
    '{}';
  --from json_each(readfile('.json'));