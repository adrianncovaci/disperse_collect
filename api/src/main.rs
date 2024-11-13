pub mod error;
pub mod models;

use axum::{
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use contract::DisperseContract;

use self::{
    error::ApiError,
    models::{
        collect::{
            ApproveCollectionRequest, CollectEthRequest, CollectTokenRequest,
            RevokeCollectionRequest,
        },
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
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .disperse_token(payload.token, payload.recipients, payload.amounts)
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
pub async fn disperse_eth_by_percentage(
    Json(payload): Json<DisperseEthPercentageRequest>,
) -> impl IntoResponse {
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .disperse_eth_by_percentage(
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

#[axum_macros::debug_handler]
pub async fn collect_eth(Json(payload): Json<CollectEthRequest>) -> impl IntoResponse {
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .collect_eth(payload.from, payload.to, payload.amount)
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
pub async fn collect_token(Json(payload): Json<CollectTokenRequest>) -> impl IntoResponse {
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .collect_token(payload.token, payload.from, payload.to)
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
pub async fn approve_collection(
    Json(payload): Json<ApproveCollectionRequest>,
) -> impl IntoResponse {
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .approve_collection(payload.token, payload.collector, payload.percentage)
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
pub async fn revoke_collection(Json(payload): Json<RevokeCollectionRequest>) -> impl IntoResponse {
    let contract = match DisperseContract::new().await {
        Ok(contract) => contract,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    let tx_hash = match contract
        .revoke_collection(payload.token, payload.collector)
        .await
    {
        Ok(tx_hash) => tx_hash,
        Err(e) => return ApiResponse::Error(ApiError::InternalError(e.to_string())),
    };

    ApiResponse::Success(DisperseResponse {
        tx_hash: format!("0x{:x}", tx_hash),
    })
}

async fn health_check() -> &'static str {
    "OK"
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/health", get(health_check))
        .route("/api/disperse/eth", post(disperse_eth))
        .route("/api/disperse/token", post(disperse_token))
        .route(
            "/api/disperse/eth/percentage",
            post(disperse_eth_by_percentage),
        )
        .route(
            "/api/disperse/token/percentage",
            post(disperse_token_by_percentage),
        )
        .route("/api/collect/eth", post(collect_eth))
        .route("/api/collect/token", post(collect_token))
        .route("/api/collect/approve", post(approve_collection))
        .route("/api/collect/revoke", post(revoke_collection));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
