use ethers::types::{Address, U256};
use serde::Deserialize;

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
    pub amount: U256,
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
