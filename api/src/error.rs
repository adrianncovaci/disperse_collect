use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub enum ApiError {
    InternalError(String),
}
