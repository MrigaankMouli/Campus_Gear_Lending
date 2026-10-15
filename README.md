# Campus Gear Lending DApp

Campus Gear Lending is an Ethereum decentralised application (DApp) for managing shared campus equipment such as cameras, projectors, and laboratory devices. It records who requested an item, whether the custodian approved the loan, and whether the equipment has been returned.

## Problem addressed

Equipment lending managed through paper registers or messages can lead to conflicting reservations, unclear responsibility, and disagreements about returns. This DApp maintains a shared on-chain record and applies the same lending rules to every wallet. An item can have only one open request or loan, and a borrower cannot release it for someone else merely by claiming to have returned it.

The blockchain makes recorded actions traceable to wallet addresses and enforces permissions and valid state changes. It does not verify student identity, equipment condition, or physical handover. Those responsibilities remain with the campus custodian.

## How the application works

There are two roles:

- **Custodian:** the wallet that deploys the contract. It adds equipment, enables or disables lending, approves requests, and confirms physical returns. This address is fixed for the lifetime of the contract.
- **Borrower:** any other wallet. It can request available equipment, cancel its pending request, and mark its active loan returned. The contract does not maintain a student membership list.

A typical loan follows this sequence:

1. The custodian adds an equipment name. The contract assigns an item ID and makes it available.
2. A borrower selects the item and a future due date no more than 30 days from the current block timestamp. The request immediately reserves the item.
3. The custodian approves the pending request before its due date, recording an active loan. Physical handover happens outside the application.
4. After returning the equipment, the borrower selects **Mark returned**. The item remains reserved while receipt is being verified.
5. The custodian checks the physical return and selects **Confirm return**. The loan closes and the item can be requested again if it is enabled.

| Current loan state | Action | Permitted wallet | Resulting state |
| --- | --- | --- | --- |
| No open loan | Request loan | Any wallet except the custodian | Pending |
| Pending | Approve | Custodian | Active |
| Pending | Cancel | Requesting borrower or custodian | Cancelled; reservation released |
| Active | Mark returned | Requesting borrower | ReturnPending |
| ReturnPending | Confirm return | Custodian | Closed; reservation released |

Disabling an item prevents new requests and approval of pending requests, but an existing active loan can still complete its return. Due dates do not automatically close loans or cancel requests. An expired pending request must be cancelled by its borrower or the custodian to release its reservation. There are no automatic fines, deposits, payments, or scheduled transactions.

## What the smart contract and blockchain do

The `CampusGearLending` smart contract is the authoritative lending ledger. Each item stores its name, enabled status, and current loan ID. Each loan stores its item ID, borrower address, due timestamp, and status. IDs begin at **1**; a current loan ID of **0** means the item has no open loan. Closed and cancelled loan records remain available.

The contract checks the caller through `msg.sender` and validates every state-changing operation. It rejects unknown IDs, empty or oversized equipment names, invalid due dates, duplicate reservations, incorrect loan states, and actions by unauthorised wallets. These checks apply even if someone bypasses the website and calls the contract directly. A reverted operation does not apply its requested state changes.

MetaMask connects the user's wallet to the interface and signs transactions. Ethers.js translates interface actions into contract calls through the wallet's Ethereum provider. State changes require a confirmed transaction and gas; reading the ledger through view calls does not require a paid transaction. The application waits for transaction confirmation before refreshing its displayed records.

The contract also emits events when items are added or enabled/disabled, loans are requested, and loan statuses change. Transactions and events provide a history of recorded actions. The interface displays the current ledger by reading `custodian()`, `itemCount()`, `loanCount()`, `getItem()`, and `getLoan()`.

On a public network, item names, wallet addresses, and loan dates are public. Solidity's private arrays do not make blockchain data confidential. The system depends on the custodian for truthful physical-return confirmation and is an educational prototype, not an audited lending service.

## Deployment network and contract address

**Deployment evidence is pending.** The frontend currently has an empty contract address. Its configured chain ID is Sepolia's `11155111`, which is a configuration default and does not establish that a Sepolia deployment exists.

| Deployment field | Recorded value |
| --- | --- |
| Intended frontend network | Ethereum Sepolia testnet |
| Configured decimal chain ID | `11155111` |
| Actual deployment network | Pending deployment record |
| Deployed smart contract address | Not yet recorded |
| Deployment transaction hash | Not yet recorded |
| Custodian public address | Not yet recorded |

After deployment, replace the pending values above with the actual values and update [the deployment record](DEPLOYMENT.md) and `frontend/config.js` consistently. The automated tests use an ephemeral local Ganache chain; their deployment is not a persistent address for the application.

## Steps to execute the application

You need a browser with MetaMask, test ETH on the selected test network, Python 3 to serve the interface, and internet access for Remix and the frontend's Ethers.js CDN import.

1. Open [Remix](https://remix.ethereum.org/) and copy the source from `contracts/CampusGearLending.sol` into a Solidity file in its workspace.
2. Select Solidity compiler **0.8.20**, compile `CampusGearLending`, and capture the successful compilation screen.
3. In MetaMask, select Sepolia and an account funded with test ETH. This deploying account will become the custodian. Alternatively, use a running local Ganache network and its actual RPC URL and chain ID.
4. In Remix's deployment panel, select the browser-extension/injected MetaMask provider. Verify the account and network, deploy `CampusGearLending` without constructor arguments, and confirm the transaction in MetaMask.
5. Once confirmed, record the deployed address, network, chain ID, and deployment transaction hash in the section above. Capture the deployment screen.
6. In `frontend/config.js`, set `CONTRACT_ADDRESS` to the deployed address and `EXPECTED_CHAIN_ID` to the deployment network's decimal chain ID.
7. From the repository root, start the interface:

   ```sh
   python3 -m http.server 8000 --directory frontend
   ```

8. Open `http://localhost:8000` in the browser with MetaMask. Keep the server running while using the application. If using Ganache, keep its node running too.

## Connect MetaMask and interact with the contract

1. Unlock MetaMask and select the network used for deployment. Select the custodian account, then click **Connect MetaMask** on the webpage and approve account access. The application checks the chain ID and whether contract code exists at the configured address.
2. Verify that the page shows the connected address, **Custodian** role, chain ID, and contract address. Capture the wallet connection screenshot.
3. Enter an equipment name such as `Camera kit` and select **Add item**. Confirm the transaction in MetaMask and wait for the confirmation message and transaction hash. The new item should appear in the inventory.
4. Switch MetaMask to a second account for the borrower. Account or network changes reload the page, so click **Connect MetaMask** again as needed. Both accounts need test ETH for their transactions.
5. Choose the available item and a future due date within 30 days, then select **Request loan** and confirm in MetaMask. The loan should appear as **Pending** and the item as **Reserved**.
6. Switch back to the custodian, reconnect, and select **Approve** for the request. Confirm the transaction; its state becomes **Active**.
7. As the borrower, select **Mark returned** after physically returning the item. As the custodian, select **Confirm return** after checking receipt. Confirm each transaction. The loan becomes **Closed** and the enabled item becomes **Available**.
8. Use **Refresh data** to read the current blockchain records again. Capture a successful transaction with its hash and the populated inventory and loan lists.

A pending request can also be cancelled by its borrower or the custodian. Custodian-only actions remain protected by the contract even when an interface control is visible to another account.

## Test cases and observed results

The repository includes a [recorded local integration-test result](evidence/local-test-results.txt):

```text
PASS: local Ganache deployment, full lifecycle, cancellation, invalid and unauthorised calls
```

The observations below refer to that existing local run and the assertions in `tests/integration.cjs`; they are not a new test run, MetaMask test results, or evidence of deployment to Sepolia. The negative-test helper checks that calls throw, but does not assert exact revert messages or mined failed receipts. The listed revert messages are expected from the contract source.

| Category | Test input or action | Expected result | Recorded local observation |
| --- | --- | --- | --- |
| Valid | Add `Camera`; request with a due date about one day ahead; approve; mark returned; confirm return | Loan closes and item reservation clears | Passed; status `3` (Closed) and `currentLoanId = 0` asserted |
| Valid | Request the released item, then cancel as its borrower | Pending request cancelled and reservation clears | Passed; `currentLoanId = 0` asserted |
| Invalid | Custodian adds an empty name | Reject: `Name must be 1-80 bytes` | Passed; call rejected |
| Invalid | Request item ID `99` when only one item exists | Reject: `Unknown item` | Passed; call rejected |
| Invalid | Request with due timestamp `1` (in the past) | Reject: `Due date must be within 30 days` | Passed; call rejected |
| Invalid | A second borrower requests an already reserved item | Reject: `Item unavailable` | Passed; call rejected |
| Unauthorised | Non-custodian adds equipment | Reject: `Custodian only` | Passed; call rejected |
| Unauthorised | Non-custodian approves a pending request | Reject: `Custodian only` | Passed; call rejected |
| Unauthorised | Unrelated wallet cancels another borrower's request | Reject: `Not authorised` | Passed; call rejected |
| Unauthorised | Unrelated wallet marks an active loan returned | Reject: `Borrower only` | Passed; call rejected |

To reproduce the local checks, run the following from the repository root with Node.js and npm installed:

```sh
npm ci
npm test
```

For Remix tests, copy the contract and `tests/CampusGearLending_test.sol` into the same workspace, preserving their relative paths. Enable **Solidity Unit Testing**, select the test file, and run it. The plugin supplies `remix_tests.sol`. Capture the actual results; a Remix test run has not been recorded here.

For a manual unauthorised-call demonstration, create a pending request and use Remix to call `approveLoan(loanId)` from a non-custodian account against the deployed contract. Capture the actual error. A gas-estimation rejection is evidence of a rejected call, not a mined failed transaction; label it accordingly. If a transaction is actually mined and fails, record its hash and failed receipt status. Rejecting a MetaMask signature is also distinct from a contract revert.

## Screenshot evidence

**No screenshot files are currently included.** Add genuine captures of the running application and replace each pending entry with an embedded image using the indicated path. The filenames below are planned evidence locations, not existing screenshots.

| Required screenshot | What the capture must show | Planned path | Status |
| --- | --- | --- | --- |
| Smart contract compilation | Contract name, Solidity compiler version, and successful compilation in Remix | `evidence/01-compiled.png` | Pending |
| Smart contract deployment | Deployed contract address, selected network, and confirmed deployment | `evidence/02-deployed.png` | Pending |
| MetaMask wallet connection | Connected account and role, chain ID, and contract in the interface | `evidence/03-wallet-connected.png` | Pending |
| Successful transaction | A confirmed contract action and its transaction hash | `evidence/04-successful-transaction.png` | Pending |
| Failed transaction | Invalid or unauthorised action with its actual error; include hash/status if mined, otherwise label as a pre-submission rejection | `evidence/05-failed-transaction.png` | Pending |
| Blockchain data in the interface | Populated equipment and loan records, including availability, borrower, due date, and loan status | `evidence/06-blockchain-data.png` | Pending |

For example, once the compilation image exists, embed it with:

```markdown
![Successful smart contract compilation in Remix](evidence/01-compiled.png)
```

Deployment details and these six captures are still required to complete the submission evidence. Keep wallet recovery phrases and private keys out of screenshots and repository files.
