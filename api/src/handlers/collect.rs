use axum::{response::IntoResponse, Json};
use ethers::types::U256;

use crate::{
    disperse_client::DisperseClient,
    error::ApiError,
    models::{
        collect::{CollectEthRequest, CollectTokenRequest},
        response::{ApiResponse, DisperseResponse},
    },
};

#[axum_macros::debug_handler]
pub async fn collect_eth(Json(payload): Json<CollectEthRequest>) -> impl IntoResponse {
    if payload.amount == U256::zero() {
        return ApiResponse::Error(ApiError::InternalError("Amount cannot be zero".to_string()));
    }

    let client = match DisperseClient::new().await {
        Ok(client) => client,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    // Calculate amount per address
    let amount_per_address = payload.amount / U256::from(payload.from.len());
    let amounts = vec![amount_per_address; payload.from.len()];

    match client.collect_eth(payload.from, payload.to, amounts).await {
        Ok(tx_hashes) => ApiResponse::Success(DisperseResponse {
            tx_hash: format!("0x{:x}", tx_hashes[0]),
        }),
        Err(e) => ApiResponse::Error(ApiError::InternalError(e.to_string())),
    }
}

#[axum_macros::debug_handler]
pub async fn collect_token(Json(payload): Json<CollectTokenRequest>) -> impl IntoResponse {
    if payload.amount == U256::zero() {
        return ApiResponse::Error(ApiError::InternalError("Amount cannot be zero".to_string()));
    }

    if payload.from.is_empty() {
        return ApiResponse::Error(ApiError::InternalError(
            "No source addresses provided".to_string(),
        ));
    }

    let client = match DisperseClient::new().await {
        Ok(client) => client,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    // Calculate amount per address
    let amount_per_address = payload.amount / U256::from(payload.from.len());
    let amounts = vec![amount_per_address; payload.from.len()];

    let tx_hashes = match client
        .collect_token(payload.token, payload.from, payload.to, amounts)
        .await
    {
        Ok(hashes) => hashes,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    ApiResponse::Success(DisperseResponse {
        tx_hash: format!("0x{:x}", tx_hashes[0]),
    })
}
