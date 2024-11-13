use axum::{
    routing::{get, post},
    Router,
};

use self::handlers::{
    collect::{collect_eth, collect_token},
    disperse::{
        disperse_eth, disperse_eth_by_percentage, disperse_token, disperse_token_by_percentage,
    },
    utils::health_check,
};

pub mod disperse_client;
pub mod error;
pub mod handlers;
pub mod models;

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
        .route("/api/collect/token", post(collect_token));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
