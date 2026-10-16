# Deployment record

This record contains the confirmed Sepolia deployment. Fill the remaining fields only after performing those actions; do not invent transaction hashes.

| Field | Actual value |
| --- | --- |
| Network | Ethereum Sepolia |
| Decimal chain ID | 11155111 |
| Compiler version | Compilation screenshot shows Remix Solidity 0.8.34; confirm the version used for the deployment in Remix |
| Contract address | `0x34dbf27562b0957a5bb2485605f19f52c03676b8` |
| Custodian wallet (public address) | `0x0f8F283B6A28940617Db23ca41c31b0832A15028` |
| Deployment transaction hash | [`0xccebdeeba264f970279a9ddd177866865b2c33037334e15539de04cfe458dc77`](https://sepolia.etherscan.io/tx/0xccebdeeba264f970279a9ddd177866865b2c33037334e15539de04cfe458dc77) |
| Successful add-item transaction hash | Pending test |
| Successful loan-request transaction hash | Pending test |
| Successful approval transaction hash | Pending test |
| Successful return transaction hash | Pending test |

The address, deploying wallet, and transaction hash are visible in [`assets/02-deployed1.png`](assets/02-deployed1.png); Remix shows the deployed instance in [`assets/02-deployed2.png`](assets/02-deployed2.png). The frontend is configured for this address. Add actual interaction transaction hashes and test observations after running them.

## Previously reported failed transaction

The reported [failed Sepolia transaction `0x39b985066720ea195ec6f260afd6df2f20fb47fec625e5b01996a1544777f49b`](https://sepolia.etherscan.io/tx/0x39b985066720ea195ec6f260afd6df2f20fb47fec625e5b01996a1544777f49b) had receipt status `0` and targeted `0xdb9B1e94B5b69Df7e401DDbedE43491141047dB3`, a **different address** from the deployed contract above. Its transaction data was empty. Do not count it as a test of this contract's authorisation rules. Make sure the browser serves the latest frontend files and shows the full configured address before sending a new transaction.
