use std::time::SystemTime;

use sqlite_loadable::prelude::*;
use sqlite_loadable::{api, define_scalar_function, Result};
use ulid::Ulid;

// ulid() -> '01GMRG9JWFHHCGG5TSXHWYR0CM'
// TODO maybe `ulid(blob)` to pretty format?
pub fn ulid(context: *mut sqlite3_context, _values: &[*mut sqlite3_value]) -> Result<()> {
    api::result_text(context, Ulid::new().to_string())?;
    Ok(())
}

// ulid_bytes() -> X'0185310899dd7662b8f1e5adf9a5e7c0'
// TODO maybe `ulid(id)` to serialize text ID?
pub fn ulid_bytes(context: *mut sqlite3_context, _values: &[*mut sqlite3_value]) -> Result<()> {
    api::result_blob(context, &Ulid::new().0.to_be_bytes());
    Ok(())
}

// ulid_with_prefix('xyz') -> 'xyz_01GMRGH6F01DAKVTG9HJA19MP6'
pub fn ulid_with_prefix(
    context: *mut sqlite3_context,
    values: &[*mut sqlite3_value],
) -> Result<()> {
    let prefix = api::value_text(values.get(0).expect("1st argument required")).unwrap();
    api::result_text(context, format!("{prefix}_{}", Ulid::new().to_string()))?;
    Ok(())
}

// ulid_datetime('01GMP2G8ZG6PMKWYVKS62TTA41') -> 1671483106
// TODO return millisecond precision
pub fn ulid_datetime(context: *mut sqlite3_context, values: &[*mut sqlite3_value]) -> Result<()> {
    let ulid =
        Ulid::from_string(api::value_text(values.get(0).expect("1st argument required")).unwrap())
            .unwrap();
    //api::result_text(context, Ulid::new().to_string())?;
    api::result_int64(
        context,
        ulid.datetime()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap()
            .as_secs()
            .try_into()
            .unwrap(),
    );
    Ok(())
}

// TODO ulid_datetime() to ulid_extract_datetime(), ulid_extract_random()

#[sqlite_entrypoint]
pub fn sqlite3_ulid_init(db: *mut sqlite3) -> Result<()> {
    define_scalar_function(db, "ulid", 0, ulid, FunctionFlags::UTF8)?;
    define_scalar_function(db, "ulid_bytes", 0, ulid_bytes, FunctionFlags::UTF8)?;
    define_scalar_function(
        db,
        "ulid_with_prefix",
        1,
        ulid_with_prefix,
        FunctionFlags::UTF8,
    )?;
    define_scalar_function(
        db,
        "ulid_datetime",
        1,
        ulid_datetime,
        FunctionFlags::UTF8 | FunctionFlags::DETERMINISTIC,
    )?;
    Ok(())
}
