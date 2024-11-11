use axum::{http::StatusCode, response::IntoResponse, Json};
use ethers::types::{Address, U256};
use serde::{Deserialize, Serialize};

use crate::error::ApiError;

#[derive(Debug, Deserialize)]
pub struct DisperseEthRequest {
    pub recipients: Vec<Address>,
    pub amounts: Vec<U256>,
}

#[derive(Debug, Deserialize)]
pub struct DisperseTokenRequest {
    pub token: Address,
    pub recipients: Vec<Address>,
    pub amounts: Vec<U256>,
}

#[derive(Debug, Deserialize)]
pub struct DisperseEthPercentageRequest {
    pub recipients: Vec<Address>,
    pub percentages: Vec<U256>,
    pub total_amount: U256,
}

#[derive(Debug, Deserialize)]
pub struct DisperseTokenPercentageRequest {
    pub token: Address,
    pub recipients: Vec<Address>,
    pub percentages: Vec<U256>,
    pub total_amount: U256,
}

#[derive(Debug, Deserialize)]
pub struct CollectEthRequest {
    pub from: Vec<Address>,
    pub to: Address,
    pub amount: U256,
}

#[derive(Debug, Deserialize)]
pub struct CollectTokenRequest {
    pub token: Address,
    pub from: Vec<Address>,
    pub to: Address,
}

#[derive(Debug, Deserialize)]
pub struct ApproveCollectionRequest {
    pub token: Address,
    pub collector: Address,
    pub percentage: U256,
}

#[derive(Debug, Deserialize)]
pub struct RevokeCollectionRequest {
    pub token: Address,
    pub collector: Address,
}

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
