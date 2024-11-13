use crate::error::ApiError;
use axum::{http::StatusCode, response::IntoResponse, Json};
use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct DisperseResponse {
    pub tx_hash: String,
}

#[derive(Serialize)]
#[serde(untagged)]
pub enum ApiResponse {
    Success(DisperseResponse),
    Error(ApiError),
}

impl IntoResponse for ApiResponse {
    fn into_response(self) -> axum::response::Response {
        match self {
            ApiResponse::Success(response) => (StatusCode::OK, Json(response)).into_response(),
            ApiResponse::Error(error) => {
                (StatusCode::INTERNAL_SERVER_ERROR, Json(error)).into_response()
            }
        }
    }
}
