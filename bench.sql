.load target/release/libulid0
.load ./uuid

select count(value) from generate_series(1, 1e6);
select count(ulid()) from generate_series(1, 1e6);
select count(ulid_bytes()) from generate_series(1, 1e6);
select count(uuid()) from generate_series(1, 1e6);


select uuid(), ulid(), ulid_bytes();