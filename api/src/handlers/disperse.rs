use axum::{response::IntoResponse, Json};
use contract::DisperseContract;
use ethers::types::U256;

use crate::{
    disperse_client::DisperseClient,
    error::ApiError,
    models::{
        disperse::{
            DisperseEthPercentageRequest, DisperseEthRequest, DisperseTokenPercentageRequest,
            DisperseTokenRequest,
        },
        response::{ApiResponse, DisperseResponse},
    },
};

#[axum_macros::debug_handler]
pub async fn disperse_eth(Json(payload): Json<DisperseEthRequest>) -> impl IntoResponse {
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .disperse_eth(payload.recipients, payload.amounts)
        .await
    {
        Ok(tx_hash) => tx_hash,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    ApiResponse::Success(DisperseResponse {
        tx_hash: format!("0x{:x}", tx_hash),
    })
}

#[axum_macros::debug_handler]
pub async fn disperse_token(Json(payload): Json<DisperseTokenRequest>) -> impl IntoResponse {
    let client = match DisperseClient::new().await {
        Ok(client) => client,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let total_amount = payload
        .amounts
        .iter()
        .fold(U256::zero(), |acc, &amount| acc + amount);

    // First approve tokens
    match client
        .approve_token_collection(payload.token, client.contract.address(), total_amount)
        .await
    {
        Ok(_) => (),
        Err(e) => {
            return ApiResponse::Error(ApiError::InternalError(format!(
                "Token approval failed: {}",
                e
            )))
        }
    };

    // Then disperse
    match client
        .disperse_token(payload.token, payload.recipients, payload.amounts)
        .await
    {
        Ok(tx_hash) => ApiResponse::Success(DisperseResponse {
            tx_hash: format!("0x{:x}", tx_hash),
        }),
        Err(e) => ApiResponse::Error(ApiError::InternalError(e.to_string())),
    }
}

#[axum_macros::debug_handler]
pub async fn disperse_eth_by_percentage(
    Json(payload): Json<DisperseEthPercentageRequest>,
) -> impl IntoResponse {
    let client = match DisperseClient::new().await {
        Ok(client) => client,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let amounts =
        match DisperseClient::calculate_amounts(payload.total_amount, &payload.percentages) {
            Ok(amounts) => amounts,
            Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
        };

    let tx_hash = match client.disperse_eth(payload.recipients, amounts).await {
        Ok(tx_hash) => tx_hash,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    ApiResponse::Success(DisperseResponse {
        tx_hash: format!("0x{:x}", tx_hash),
    })
}

#[axum_macros::debug_handler]
pub async fn disperse_token_by_percentage(
    Json(payload): Json<DisperseTokenPercentageRequest>,
) -> impl IntoResponse {
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .disperse_token_by_percentage(
            payload.token,
            payload.recipients,
            payload.percentages,
            payload.total_amount,
        )
        .await
    {
        Ok(tx_hash) => tx_hash,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    ApiResponse::Success(DisperseResponse {
        tx_hash: format!("0x{:x}", tx_hash),
    })
}
