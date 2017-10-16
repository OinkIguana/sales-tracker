//! Holds information about a user and their products, prices, and conventions
use chrono::NaiveDateTime;
use juniper::FieldResult;
use database::Database;
pub use database::{User, ProductType, Product, PriceRow};

// TODO: un-stub these
type Convention = bool;

graphql_object!(User: Database |&self| {
    description: "Holds information about a user and their products, prices, and conventions"

    field id() -> i32 { self.user_id }
    field email() -> &String { &self.email }
    field keys() -> i32 { self.keys }
    field join_date() -> NaiveDateTime { self.join_date }

    field product_types(&executor) -> FieldResult<Vec<ProductType>> {
        dbtry! {
            executor
                .context()
                .get_product_types_for_user(self.user_id)
        }
    }
    field products(&executor) -> FieldResult<Vec<Product>> {
        dbtry! {
            executor
                .context()
                .get_products_for_user(self.user_id)
        }
    }
    field prices(&executor) -> FieldResult<Vec<PriceRow>> {
        dbtry! {
            executor
                .context()
                .get_prices_for_user(self.user_id)
                .map(|prices| prices
                    .into_iter()
                    .fold(vec![], |prev, price| {
                        let len = prev.len() as i32;
                        prev.into_iter().chain(price.spread(len)).collect()
                    })
                )
        }
    }

    field conventions() -> Vec<Convention> { vec![] }
});
