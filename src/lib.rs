use std::time::SystemTime;

use sqlite_loadable::api::ValueType;
use sqlite_loadable::prelude::*;
use sqlite_loadable::{api, define_scalar_function, Error, Result};
use ulid::Ulid;

// ulid_version() -> 'v0.1.0'
pub fn ulid_version(context: *mut sqlite3_context, _values: &[*mut sqlite3_value]) -> Result<()> {
    api::result_text(context, format!("v{}", env!("CARGO_PKG_VERSION")))?;
    Ok(())
}

pub fn ulid_debug(context: *mut sqlite3_context, _values: &[*mut sqlite3_value]) -> Result<()> {
    api::result_text(
        context,
        format!(
            "Version: v{}
Source: {}
",
            env!("CARGO_PKG_VERSION"),
            env!("GIT_HASH")
        ),
    )?;
    Ok(())
}

// ulid() -> '01GMRG9JWFHHCGG5TSXHWYR0CM'
pub fn ulid(context: *mut sqlite3_context, values: &[*mut sqlite3_value]) -> Result<()> {
    let ulid = if let Some(input) = values.get(0) {
        Ulid(u128::from_be_bytes(
            api::value_blob(input)
                .try_into()
                .map_err(|_| Error::new_message("invalid BLOB input to ulid()"))?,
        ))
    } else {
        Ulid::new()
    };
    api::result_text(context, ulid.to_string().to_lowercase())?;
    Ok(())
}

// ulid_with_prefix('xyz') -> 'xyz_01GMRGH6F01DAKVTG9HJA19MP6'
pub fn ulid_with_prefix(
    context: *mut sqlite3_context,
    values: &[*mut sqlite3_value],
) -> Result<()> {
    let prefix = api::value_text(values.get(0).expect("1st argument required"))?;
    api::result_text(
        context,
        format!("{prefix}_{}", Ulid::new().to_string()).to_lowercase(),
    )?;
    Ok(())
}

// ulid_bytes() -> X'0185310899dd7662b8f1e5adf9a5e7c0'
// ulid_bytes('') -> X'0185310899dd7662b8f1e5adf9a5e7c0'
pub fn ulid_bytes(context: *mut sqlite3_context, values: &[*mut sqlite3_value]) -> Result<()> {
    let ulid = if let Some(input) = values.get(0) {
        Ulid::from_string(api::value_text(input)?).map_err(|e| {
            Error::new_message(format!("invalid ULID input to ulid_bytes(): {}", e).as_str())
        })?
    } else {
        Ulid::new()
    };
    api::result_blob(context, &ulid.0.to_be_bytes());
    Ok(())
}

use chrono::NaiveDateTime;
// ulid_datetime('01GMP2G8ZG6PMKWYVKS62TTA41') -> 1671483106
// TODO return millisecond precision
pub fn ulid_datetime(context: *mut sqlite3_context, values: &[*mut sqlite3_value]) -> Result<()> {
    let input = values.get(0).expect("1st argument required");
    let ulid = match api::value_type(input) {
        ValueType::Text => {
            let input = api::value_text(input)?;
            // if input text is longer than a normal ULID, it might be prefixed - so try to strip
            // a prefix and extract the underlying ULID
            if input.len() > ulid::ULID_LEN {
                let id = if let Some((_, ulid)) = input.rsplit_once('_') {
                    ulid
                } else {
                    input
                };
                Ulid::from_string(id).map_err(|e| {
                    Error::new_message(
                        format!("invalid ULID input to ulid_datetime(): {}", e).as_str(),
                    )
                })?
            } else {
                Ulid::from_string(input).map_err(|e| {
                    Error::new_message(
                        format!("invalid ULID input to ulid_datetime(): {}", e).as_str(),
                    )
                })?
            }
        }
        ValueType::Blob => Ulid(u128::from_be_bytes(
            api::value_blob(input)
                .try_into()
                .map_err(|_| Error::new_message("invalid BLOB input to ulid_datetime()"))?,
        )),
        _ => return Err(Error::new_message("unsupported input for ulid_datetime")),
    };

    //api::result_text(context, Ulid::new().to_string())?;
    let ms = ulid
        .datetime()
        .duration_since(SystemTime::UNIX_EPOCH)
        .map_err(|e| Error::new_message(format!("error calculating duration: {e}").as_str()))?
        .as_millis()
        .try_into()
        .map_err(|e| {
            Error::new_message(
                format!("error converting duration to i64 milliseconds: {e}").as_str(),
            )
        })?;

    match NaiveDateTime::from_timestamp_millis(ms) {
        Some(dt) => api::result_text(context, dt.format("%Y-%m-%d %H:%M:%S.%3f").to_string())?,
        None => return Err(Error::new_message("timestamp overflow")),
    };
    Ok(())
}

// TODO ulid_datetime() to ulid_extract_datetime(), ulid_extract_random()

#[sqlite_entrypoint]
pub fn sqlite3_ulid_init(db: *mut sqlite3) -> Result<()> {
    define_scalar_function(
        db,
        "ulid_version",
        0,
        ulid_version,
        FunctionFlags::UTF8 | FunctionFlags::DETERMINISTIC,
    )?;
    define_scalar_function(
        db,
        "ulid_debug",
        0,
        ulid_debug,
        FunctionFlags::UTF8 | FunctionFlags::DETERMINISTIC,
    )?;

    define_scalar_function(db, "ulid", 0, ulid, FunctionFlags::UTF8)?;
    define_scalar_function(db, "ulid", 1, ulid, FunctionFlags::UTF8)?;
    define_scalar_function(db, "ulid_bytes", 0, ulid_bytes, FunctionFlags::UTF8)?;
    define_scalar_function(db, "ulid_bytes", 1, ulid_bytes, FunctionFlags::UTF8)?;
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
