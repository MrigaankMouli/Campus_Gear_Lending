# Deployment and transaction record

This is the recorded **Ethereum Sepolia** deployment used by the [frontend](frontend/) and [README](README.md). All visual evidence appears directly in the README.

| Deployment field | Recorded value |
| --- | --- |
| Chain ID | `11155111` |
| Contract address | [`0x34dbf27562b0957a5bb2485605f19f52c03676b8`](https://sepolia.etherscan.io/address/0x34dbf27562b0957a5bb2485605f19f52c03676b8) |
| Deploying custodian wallet | `0x0f8F283B6A28940617Db23ca41c31b0832A15028` |
| Deployment transaction | [`0xccebdeeba264f970279a9ddd177866865b2c33037334e15539de04cfe458dc77`](https://sepolia.etherscan.io/tx/0xccebdeeba264f970279a9ddd177866865b2c33037334e15539de04cfe458dc77) |
| Compilation evidence | The Remix compiler display in the README shows Solidity 0.8.34 |

The compiler display does not by itself verify the version used for the recorded deployment. The frontend's configured address and chain ID are in [`frontend/config.js`](frontend/config.js).

## Successful transaction sequence

| Step | Caller and action | Transaction | Resulting data shown in README |
| --- | --- | --- | --- |
| 1 | Custodian adds `Whiteboard` | [`0x78578017…d53c119c`](https://sepolia.etherscan.io/tx/0x78578017ce459e4490ff86b72554f19b3eca0a5628c3a3d9afa3d673d53c119c) | Item #1 available |
| 2 | Borrower requests item #1 | [`0xe41b9d99…00a8fa86`](https://sepolia.etherscan.io/tx/0xe41b9d9984e5f5296cf03e45193829d630f5183caeddbc7ff3a7c8a200a8fa86) | Loan #1 pending; item reserved |
| 3 | Custodian approves loan #1 | [`0x6130d857…8d0056ac`](https://sepolia.etherscan.io/tx/0x6130d85784c1995c4fd99553f0902e4c747ccae998b7e15c8bf996018d0056ac) | Loan #1 active |
| 4 | Borrower marks loan #1 returned | [`0xd4470ff3…850fed5ba2`](https://sepolia.etherscan.io/tx/0xd4470ff3678b57277e0f17995a8adc3deebab42e0539750913cd99850fed5ba2) | Confirmation notification; the card still reads `Active` at capture time |
| 5 | Custodian confirms receipt | [`0xceeef373…b79e27938`](https://sepolia.etherscan.io/tx/0xceeef37341a703f811314eaaa8dc3aae904ea883e60368beea83a57b79e27938) | Loan #1 closed; item available |

The README displays the selected frontend roles and returned item/loan records. Its MetaMask prompt shows a transaction awaiting confirmation, so use the confirmed transactions above as execution evidence.

## Failed authorisation transaction

| Field | Recorded value |
| --- | --- |
| Sender | Borrower `0x93b15649f79CFF751b140c7B9E91aB93159E45ad` |
| Recipient | Deployed contract `0x34dbf27562b0957a5bb2485605f19f52c03676b8` |
| Transaction | [`0x098883fb9ac54d4a4cc8903216de9799b26cf8bfed08075d6f002a7e5207247f`](https://sepolia.etherscan.io/tx/0x098883fb9ac54d4a4cc8903216de9799b26cf8bfed08075d6f002a7e5207247f) |
| Observed result | Mined failure with `Custodian only` revert |

The frontend also shows a separate client-side permission check, which did not submit a transaction. Remix recorded four passing tests for valid, invalid, and unauthorised calls. Both results and the run instructions are presented with the visual evidence in the [README](README.md#6-testing-and-observed-results).
