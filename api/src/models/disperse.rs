use ethers::types::{Address, U256};
use serde::Deserialize;

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
