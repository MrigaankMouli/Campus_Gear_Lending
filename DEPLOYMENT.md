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
| 1. Add item transaction | [`0x78578017ce459e4490ff86b72554f19b3eca0a5628c3a3d9afa3d673d53c119c`](https://sepolia.etherscan.io/tx/0x78578017ce459e4490ff86b72554f19b3eca0a5628c3a3d9afa3d673d53c119c) |
| 2. Request loan transaction | [`0xe41b9d9984e5f5296cf03e45193829d630f5183caeddbc7ff3a7c8a200a8fa86`](https://sepolia.etherscan.io/tx/0xe41b9d9984e5f5296cf03e45193829d630f5183caeddbc7ff3a7c8a200a8fa86) |
| 3. Approve loan transaction | [`0x6130d85784c1995c4fd99553f0902e4c747ccae998b7e15c8bf996018d0056ac`](https://sepolia.etherscan.io/tx/0x6130d85784c1995c4fd99553f0902e4c747ccae998b7e15c8bf996018d0056ac) |
| 4. Mark returned transaction | [`0xd4470ff3678b57277e0f17995a8adc3deebab42e0539750913cd99850fed5ba2`](https://sepolia.etherscan.io/tx/0xd4470ff3678b57277e0f17995a8adc3deebab42e0539750913cd99850fed5ba2) |
| 5. Confirm return transaction | [`0xceeef37341a703f811314eaaa8dc3aae904ea883e60368beea83a57b79e27938`](https://sepolia.etherscan.io/tx/0xceeef37341a703f811314eaaa8dc3aae904ea883e60368beea83a57b79e27938) |

The address, deploying wallet, and deployment hash are visible in [`assets/02-deployed1.png`](assets/02-deployed1.png); Remix shows the deployed instance in [`assets/02-deployed2.png`](assets/02-deployed2.png). The five interaction hashes above were transcribed from the numbered frontend screenshots in `assets/03-Transaction1.png` through `assets/03-Transaction5.png`. The frontend is configured for this address. The fourth screenshot's notification says “Mark returned confirmed,” but its loan card still reads “Active”; see the [README evidence notes](README.md#screenshot-evidence) for this display discrepancy.

## Previously reported failed transaction

The reported [failed Sepolia transaction `0x39b985066720ea195ec6f260afd6df2f20fb47fec625e5b01996a1544777f49b`](https://sepolia.etherscan.io/tx/0x39b985066720ea195ec6f260afd6df2f20fb47fec625e5b01996a1544777f49b) had receipt status `0` and targeted `0xdb9B1e94B5b69Df7e401DDbedE43491141047dB3`, a **different address** from the deployed contract above. Its transaction data was empty. Do not count it as a test of this contract's authorisation rules. Make sure the browser serves the latest frontend files and shows the full configured address before sending a new transaction.
