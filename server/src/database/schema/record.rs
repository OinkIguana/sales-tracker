//! The Records table
use std::panic::catch_unwind;
use postgres::rows::Row;
use chrono::NaiveDateTime;
use money::Money;

#[derive(Clone)]
pub struct Record {
    pub record_id: i32,
    pub user_con_id: i32,
    pub price: Money,
    pub products: Vec<i32>,
    pub sale_time: NaiveDateTime,
}
impl Record {
    pub fn from(row: Row) -> Result<Self, String> {
        catch_unwind(|| {
            Self {
                record_id: row.get("record_id"),
                user_con_id: row.get("user_con_id"),
                price: row.get("price"),
                products: row.get("products"),
                sale_time: row.get("sale_time"),
            }
        }).map_err(|_| "Tried to create a Record from a non-Record row".to_string())
    }
}