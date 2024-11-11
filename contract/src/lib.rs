use ethers::{
    middleware::SignerMiddleware,
    prelude::*,
    providers::{Http, Provider},
    signers::LocalWallet,
};
use std::sync::Arc;

abigen!(
    DisperseCollect,
    "./out/DisperseCollect.sol/DisperseCollect.json",
    event_derives(serde::Deserialize, serde::Serialize)
);

#[derive(Debug)]
pub struct DisperseContract {
    contract: DisperseCollect<SignerMiddleware<Provider<Http>, LocalWallet>>,
}

impl DisperseContract {
    pub async fn new() -> anyhow::Result<Self> {
        let provider = Provider::<Http>::try_from(
            std::env::var("RPC_URL").unwrap_or_else(|_| "http://localhost:8545".to_string()),
        )?;

        let chain_id = provider.get_chainid().await?;

        let wallet = std::env::var("PRIVATE_KEY")
            .expect("PRIVATE_KEY must be set")
            .parse::<LocalWallet>()?
            .with_chain_id(chain_id.as_u64());

        let client = SignerMiddleware::new(provider, wallet);
        let client = Arc::new(client);

        let contract_addr = std::env::var("CONTRACT_ADDRESS")
            .expect("CONTRACT_ADDRESS must be set")
            .parse::<Address>()?;

        let contract = DisperseCollect::new(contract_addr, client);

        Ok(Self { contract })
    }

    pub async fn disperse_eth(
        &self,
        recipients: Vec<Address>,
        amounts: Vec<U256>,
    ) -> anyhow::Result<H256> {
        let total = amounts.iter().fold(U256::zero(), |acc, &x| acc + x);

        let call = self.contract.disperse_eth(recipients, amounts).value(total);

        let tx = call.send().await?;

        Ok(tx.tx_hash())
    }

    pub async fn disperse_eth_by_percentage(
        &self,
        recipients: Vec<Address>,
        percentages: Vec<U256>,
        total_amount: U256,
    ) -> anyhow::Result<H256> {
        let call = self
            .contract
            .disperse_eth_by_percentage(recipients, percentages)
            .value(total_amount);

        let tx = call.send().await?;

        Ok(tx.tx_hash())
    }

    pub async fn disperse_token(
        &self,
        token: Address,
        recipients: Vec<Address>,
        amounts: Vec<U256>,
    ) -> anyhow::Result<H256> {
        let call = self.contract.disperse_token(token, recipients, amounts);

        let tx = call.send().await?;

        Ok(tx.tx_hash())
    }

    pub async fn disperse_token_by_percentage(
        &self,
        token: Address,
        recipients: Vec<Address>,
        percentages: Vec<U256>,
        total_amount: U256,
    ) -> anyhow::Result<H256> {
        let call = self.contract.disperse_token_by_percentage(
            token,
            recipients,
            percentages,
            total_amount,
        );

        let tx = call.send().await?;

        Ok(tx.tx_hash())
    }

    pub async fn collect_eth(
        &self,
        from: Vec<Address>,
        to: Address,
        amount: U256,
    ) -> anyhow::Result<H256> {
        let call = self.contract.collect_eth(from, to).value(amount);
        let tx = call.send().await?;
        Ok(tx.tx_hash())
    }

    pub async fn collect_token(
        &self,
        token: Address,
        from: Vec<Address>,
        to: Address,
    ) -> anyhow::Result<H256> {
        let call = self.contract.collect_token(token, from, to);
        let tx = call.send().await?;
        Ok(tx.tx_hash())
    }

    pub async fn approve_collection(
        &self,
        token: Address,
        collector: Address,
        percentage: U256,
    ) -> anyhow::Result<H256> {
        let call = self
            .contract
            .approve_collection(token, collector, percentage);
        let tx = call.send().await?;
        Ok(tx.tx_hash())
    }

    pub async fn revoke_collection(
        &self,
        token: Address,
        collector: Address,
    ) -> anyhow::Result<H256> {
        let call = self.contract.revoke_collection(token, collector);
        let tx = call.send().await?;
        Ok(tx.tx_hash())
    }
}
