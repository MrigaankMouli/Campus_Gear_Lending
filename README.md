# Campus Gear Lending

Campus Gear Lending is a Solidity DApp for lending shared campus equipment such as cameras and projectors. Paper registers and messages make it difficult to see whether an item is available, who requested it, and whether it was returned. This application records each request and return on Ethereum Sepolia, prevents overlapping loans, and lets a custodian approve loans and confirm physical returns.

## Assignment components

| Requirement | Implementation |
| --- | --- |
| Solidity contract with constructor, state, functions, and validation | [`contracts/CampusGearLending.sol`](contracts/CampusGearLending.sol) |
| HTML, CSS, and JavaScript interface | [`frontend/`](frontend/) |
| MetaMask connection through Ethers.js | [`frontend/app.js`](frontend/app.js) |
| Transactions and blockchain data | Add, request, approve, return, and cancel actions; the interface reads item and loan records from the contract |
| Valid, invalid, and unauthorised tests | [`tests/CampusGearLending_test.sol`](tests/CampusGearLending_test.sol) for Remix; [`tests/integration.cjs`](tests/integration.cjs) for a local Ganache run |

The deploying wallet becomes the **custodian** in the constructor. It can add or disable items, approve requests, and confirm returns. Another wallet can request an available item, cancel its own pending request, and mark its active loan returned. The contract validates item IDs, names, due dates, loan states, and caller permissions. A request reserves an item until cancellation or confirmed return. Due dates do not automatically close loans.

## Sepolia deployment

| Field | Value |
| --- | --- |
| Network | Ethereum Sepolia; chain ID `11155111` |
| Contract | [`0x34dbf27562b0957a5bb2485605f19f52c03676b8`](https://sepolia.etherscan.io/address/0x34dbf27562b0957a5bb2485605f19f52c03676b8) |
| Custodian | `0x0f8F283B6A28940617Db23ca41c31b0832A15028` |
| Deployment transaction | [`0xccebdeeba264f970279a9ddd177866865b2c33037334e15539de04cfe458dc77`](https://sepolia.etherscan.io/tx/0xccebdeeba264f970279a9ddd177866865b2c33037334e15539de04cfe458dc77) |

The frontend configuration already points to this deployed contract. See [DEPLOYMENT.md](DEPLOYMENT.md) for the recorded interaction hashes and screenshot references.

## Run the DApp

1. Install MetaMask in a browser, unlock it, enable test networks if needed, and select **Sepolia**. Have Sepolia test ETH in each wallet that will send transactions. The custodian is the deploying address above; a different wallet acts as borrower.
2. From the repository root, serve the frontend with Python 3:

   ```sh
   python3 -m http.server 8000 --directory frontend
   ```

3. Open `http://localhost:8000`. Select **Connect / choose accounts**, grant the page access to the custodian and borrower wallets in MetaMask, then pick the desired full address under **Connected account** and press **Use selected account**. Check the displayed role, Sepolia chain ID, and contract address. Switching accounts only in the MetaMask popup may leave the page using its previously selected account; select it on the page too.
4. As custodian, add an item and confirm the MetaMask transaction. As borrower, choose that item and a future due date within 30 days, then request it. As custodian, approve the pending loan. As borrower, mark it returned after physical handover. As custodian, confirm receipt. Confirm each transaction in MetaMask and wait for its receipt before the next action.
5. Select **Refresh data** to retrieve the current inventory and loan records from the blockchain. The item becomes available again after the confirmed return. View functions can be read without sending a paid transaction.

To compile or redeploy in **Remix IDE**, copy `contracts/CampusGearLending.sol` into a Remix workspace, compile with a compatible Solidity 0.8.x compiler, select the MetaMask injected provider on Sepolia, and deploy `CampusGearLending` with **no constructor arguments**. The deploying address will be the new custodian. A new deployment has a new contract address: update `frontend/config.js`, this README, and `DEPLOYMENT.md` if you intend to use it. The included compilation screenshot displays Solidity 0.8.34; it does not independently establish which compiler version created the recorded Sepolia deployment.

## Tests and observed results

In Remix, copy these files into the **same workspace**, preserving their paths: `contracts/CampusGearLending.sol`, `test-support/BorrowerActor.sol`, and `tests/CampusGearLending_test.sol`. Open the **Solidity Unit Testing** plugin and run only `tests/CampusGearLending_test.sol`. The [captured Remix run](assets/06-Remix-UnitTests.png) reports **4 passed, 0 failed**. The invalid and unauthorised tests pass when the prohibited contract calls are rejected.

| Category | Test case | Observed result |
| --- | --- | --- |
| Valid | Borrower requests an item; custodian approves; borrower marks returned; custodian confirms | Remix lifecycle test passed; loan is `Closed` and the item is available again |
| Valid | Borrower cancels a pending request; another borrower requests the released item | Remix cancellation test passed |
| Invalid | Empty item name, past due date, unknown item ID, and second request for a reserved item | Remix invalid input and double booking test passed: each call was rejected |
| Unauthorised | Non-custodian adds or approves; unrelated wallet cancels or marks returned | Remix unauthorised access test passed: each call was rejected |
| Unauthorised, Sepolia | Borrower sends a custodian-only call to the deployed contract | [Mined transaction](https://sepolia.etherscan.io/tx/0x098883fb9ac54d4a4cc8903216de9799b26cf8bfed08075d6f002a7e5207247f) failed with `Custodian only`; see the [explorer screenshot](assets/07-Unauthorized-AddItem.png) |

An additional local integration test deploys a fresh instance on Ganache and checks the lifecycle, cancellation, invalid inputs, and caller permissions. With Node.js and npm installed, run `npm ci` and `npm test` from the repository root. The [saved local result](evidence/local-test-results.txt) reports `PASS`. That local instance is separate from the Sepolia deployment.

## Assignment screenshots

**Compilation:** Remix shows `CampusGearLending` compiled with Solidity 0.8.34.

![Remix compilation result](assets/01-compiled.png)

**Deployment:** The Sepolia contract-creation receipt and the deployed instance in Remix show the custodian and contract address.

![Successful Sepolia contract deployment](assets/02-deployed1.png)

[View the deployed instance in Remix](assets/02-deployed2.png).

**MetaMask wallet connection and successful transaction:** The account selection and confirmed add-item action are visible in the frontend. The separate [MetaMask signing prompt](assets/04-MetaMask_Transaction_Ex.png) is awaiting confirmation and does not itself prove execution.

![Custodian account and confirmed add-item transaction](assets/03-Transaction1.png)

**Blockchain data in the UI:** The borrower account is selected; loan #1 is `Pending` and the item is `Reserved` after the request.

![Borrower account and pending loan read from the contract](assets/03-Transaction2.png)

**Failed transaction:** The Sepolia explorer shows the borrower, the deployed contract, and the `Custodian only` revert.

![Failed unauthorised transaction on Sepolia](assets/07-Unauthorized-AddItem.png)

**Remix tests:** Four passed, zero failed, covering valid, invalid, and unauthorised inputs.

![Remix Solidity Unit Testing result](assets/06-Remix-UnitTests.png)

The five numbered lifecycle screenshots record [add](assets/03-Transaction1.png), [request](assets/03-Transaction2.png), [approve](assets/03-Transaction3.png), [mark returned](assets/03-Transaction4.png), and [confirm return](assets/03-Transaction5.png) in that order. The final screenshot shows the loan `Closed` and the item available. Screenshot 4 shows a confirmed notification, but its loan card still displays `Active` at capture time. The [frontend permission error](assets/05-FaliureExample.png) is client-side validation, while the failed Sepolia transaction above shows the actual contract revert.

Do not upload wallet private keys, seed phrases, passwords, or other credentials. Item names, wallet addresses, and loan dates recorded on a public blockchain are public.
