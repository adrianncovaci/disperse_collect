use ::contract::DisperseCollect;
use ethers::{
    prelude::*,
    providers::{Http, Provider},
    signers::LocalWallet,
    types::{Address, H256, U256},
};
use std::sync::Arc;

abigen!(
    IERC20,
    r#"[
        function transfer(address to, uint256 value) external returns (bool)
        function transferFrom(address from, address to, uint256 value) external returns (bool)
        function balanceOf(address account) external view returns (uint256)
        function approve(address spender, uint256 value) external returns (bool)
    ]"#,
);

type Client = SignerMiddleware<Provider<Http>, LocalWallet>;

#[derive(Debug)]
pub struct DisperseClient {
    pub contract: DisperseCollect<Client>,
    provider: Provider<Http>,
    wallet: LocalWallet,
}

impl DisperseClient {
    pub async fn new() -> anyhow::Result<Self> {
        let provider = Provider::<Http>::try_from(
            std::env::var("RPC_URL").unwrap_or_else(|_| "http://localhost:8545".to_string()),
        )?;

        let chain_id = provider.get_chainid().await?;
        let wallet = std::env::var("PRIVATE_KEY")
            .expect("PRIVATE_KEY must be set")
            .parse::<LocalWallet>()?
            .with_chain_id(chain_id.as_u64());

        let middleware = SignerMiddleware::new(provider.clone(), wallet.clone());
        let client = Arc::new(middleware);

        let contract_addr = std::env::var("CONTRACT_ADDRESS")
            .expect("CONTRACT_ADDRESS must be set")
            .parse::<Address>()?;

        let contract = DisperseCollect::new(contract_addr, client);

        Ok(Self {
            contract,
            provider,
            wallet,
        })
    }

    pub async fn sign_and_send_transaction(&self, tx: TransactionRequest) -> anyhow::Result<H256> {
        let middleware = SignerMiddleware::new(self.provider.clone(), self.wallet.clone());
        let client = Arc::new(middleware);

        let tx = tx.from(self.wallet.address());
        let pending_tx = client.send_transaction(tx, None).await?;
        Ok(pending_tx.tx_hash())
    }

    pub fn calculate_amounts(total: U256, percentages: &[U256]) -> anyhow::Result<Vec<U256>> {
        let total_percentage: U256 = percentages.iter().fold(U256::zero(), |acc, &x| acc + x);
        if total_percentage != U256::from(10000u32) {
            // 100.00%
            return Err(anyhow::anyhow!("Percentages must sum to 100.00%"));
        }

        // Calculate amounts based on percentages
        Ok(percentages
            .iter()
            .map(|&p| (total * p) / U256::from(10000u32))
            .collect())
    }

    pub async fn collect_eth(
        &self,
        from: Vec<Address>,
        to: Address,
        amounts: Vec<U256>,
    ) -> anyhow::Result<Vec<H256>> {
        if from.len() != amounts.len() {
            return Err(anyhow::anyhow!(
                "Address and amount arrays must have same length"
            ));
        }

        let mut tx_hashes = Vec::new();

        // Process each source address
        for (from_addr, &amount) in from.iter().zip(amounts.iter()) {
            // Check balance
            let balance = self.provider.get_balance(*from_addr, None).await?;
            if balance < amount {
                return Err(anyhow::anyhow!(
                    "Insufficient ETH balance for address: {}",
                    from_addr
                ));
            }

            // Create and send transaction
            let tx = TransactionRequest::new()
                .from(*from_addr)
                .to(to)
                .value(amount);

            let hash = self.sign_and_send_transaction(tx).await?;
            tx_hashes.push(hash);
        }

        Ok(tx_hashes)
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

    pub async fn collect_token(
        &self,
        token: Address,
        from: Vec<Address>,
        to: Address,
        amounts: Vec<U256>,
    ) -> anyhow::Result<Vec<H256>> {
        let mut tx_hashes = Vec::new();

        let client = Arc::new(SignerMiddleware::new(
            self.provider.clone(),
            self.wallet.clone(),
        ));

        let token_contract = IERC20::new(token, client);

        for (from_addr, &amount) in from.iter().zip(amounts.iter()) {
            let balance = token_contract.balance_of(*from_addr).call().await?;
            if balance < amount {
                return Err(anyhow::anyhow!(
                    "Insufficient token balance for address: {}",
                    from_addr
                ));
            }

            let tx = token_contract.transfer_from(*from_addr, to, amount);
            let tx = tx.send().await?;
            tx_hashes.push(tx.tx_hash());
        }

        Ok(tx_hashes)
    }

    pub async fn approve_token_collection(
        &self,
        token: Address,
        collector: Address,
        amount: U256,
    ) -> anyhow::Result<H256> {
        let client = Arc::new(SignerMiddleware::new(
            self.provider.clone(),
            self.wallet.clone(),
        ));

        let token_contract = IERC20::new(token, client);
        let tx = token_contract.approve(collector, amount);
        let tx = tx.send().await?;
        Ok(tx.tx_hash())
    }

    pub async fn revoke_token_collection(
        &self,
        token: Address,
        collector: Address,
    ) -> anyhow::Result<H256> {
        self.approve_token_collection(token, collector, U256::zero())
            .await
    }
}
