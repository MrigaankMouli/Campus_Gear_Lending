# Campus Gear Lending

A simple Ethereum DApp for lending shared campus equipment. A custodian lists equipment and approves requests. A borrower requests a loan, marks the item returned, and the custodian confirms physical receipt. The contract prevents two open requests for the same item. This is an original coursework implementation; equipment labels and wallet addresses are public on-chain.

## Project files

| File | Purpose |
| --- | --- |
| `contracts/CampusGearLending.sol` | Solidity contract (compiler 0.8.20 or newer within 0.8.x) |
| `frontend/index.html`, `styles.css`, `app.js`, `config.js` | Interface and MetaMask connection with Ethers.js v6 |
| `tests/CampusGearLending_test.sol` | Remix Solidity Unit Testing cases |
| `tests/integration.cjs`, `package.json` | Repeatable local Ganache integration test |
| `DEPLOYMENT.md` | Fill in actual network, address and transaction hashes |
| `evidence/README.md` | Screenshot checklist |
| `submission/README.md` | Required Word/PDF cover sheet instructions |

## Workflow

1. Custodian (the deploying wallet) adds an item.
2. Borrower chooses an available item and due date up to 30 days away.
3. Custodian approves the pending request before its due date. Either custodian or borrower can cancel a pending request.
4. Borrower marks an active loan returned; custodian verifies physical return and closes it.
5. Item becomes available again. Disabling an item prevents approval and new requests; a current loan can still be closed.

IDs start at **1**. The contract stores no private keys, names of students, or file uploads. It does not itself prove physical delivery or return.

## Deploy with Remix and MetaMask

1. Open [Remix](https://remix.ethereum.org/). Create the `contracts/CampusGearLending.sol` file in a Remix workspace and paste in the supplied source.
2. In **Solidity Compiler**, choose compiler **0.8.20** (or a later 0.8.x), select `CampusGearLending.sol`, and compile. Save the compilation screenshot.
3. In MetaMask, select a test network such as **Sepolia** with test ETH, or connect MetaMask to a local **Ganache** RPC network. Check the **decimal chain ID** shown in MetaMask (Ganache configuration varies). Never use real funds for coursework.
4. In **Deploy & Run Transactions**, use **Browser Extension** / **Injected Provider - MetaMask** (the label may vary), verify the selected account and network, select `CampusGearLending`, and click **Deploy**. Confirm in MetaMask. Save the contract address and deployment transaction hash in `DEPLOYMENT.md`.
5. Enter the deployed address and decimal chain ID in `frontend/config.js`. The ABI in `frontend/app.js` is already provided for the contract. If you change the Solidity public API, update the ABI too.
6. From the `frontend` directory run `python3 -m http.server 8000`, then visit `http://localhost:8000` in the browser with MetaMask. A local server is needed for JavaScript modules. The page loads Ethers.js v6 from a CDN, so internet access is needed.
7. Connect the **same network** in MetaMask. Use the deploying wallet to add an item. Switch to a second wallet to request a loan. Switch back to approve it. Switch to the borrower to mark return, then to the custodian to confirm it. Use **Refresh data** after switching; MetaMask account/network changes also reload the page.
8. Record transaction hashes and screenshots. The frontend shows public item and loan data by calling contract view functions. A reverted transaction may be blocked during gas estimation; for a failed transaction screenshot use a valid pending request and try to approve it from an unauthorised account in Remix, then capture the revert message. Avoid spending gas solely to produce a failed on-chain receipt.

**Ganache note:** Ganache may need to bind to an address that MetaMask can reach and its chain ID must match `config.js`. If you import a Ganache test account, its private key stays only in your local MetaMask. Never add it to this repository.

## Run tests in Remix

Copy both `contracts/` and `tests/` into the same Remix workspace, preserving the relative paths. Activate the **Solidity Unit Testing** plugin, select `tests/CampusGearLending_test.sol`, and run it. The test file imports `remix_tests.sol`, which the plugin supplies. These tests run in Remix's isolated test environment; deployment to Sepolia or Ganache is a separate step. Save the test result screenshot and add the **observed** results below after running. The results listed here are expected behaviour, not claims of an executed run.

For an independent automated local check, run `npm install` and `npm test` in the repository root. The integration test compiles with Solidity 0.8.20, deploys to an ephemeral Ganache chain, and exercises the loan lifecycle, cancellation, invalid input, and unauthorised calls. This was run successfully in the project workspace; run it again yourself and include the output in your submitted test evidence. Its temporary contract address is **not** a persistent deployment address.

| Test case | Input/action | Expected result | Observed result |
| --- | --- | --- | --- |
| Valid lifecycle | Add item, borrower requests, custodian approves, borrower returns, custodian confirms | Closed loan; item available | To be filled after run |
| Valid cancellation | Borrower cancels pending request | Item available for another borrower | To be filled after run |
| Invalid name | Empty item name | Revert: `Name must be 1-80 bytes` | To be filled after run |
| Invalid due date | Current or past timestamp | Revert: `Due date must be within 30 days` | To be filled after run |
| Invalid item | Item ID 99 when only one exists | Revert: `Unknown item` | To be filled after run |
| Double booking | Another borrower requests reserved item | Revert: `Item unavailable` | To be filled after run |
| Unauthorised add/approve | Borrower wallet calls custodian functions | Revert: `Custodian only` | To be filled after run |
| Unauthorised cancel | Unrelated wallet cancels pending request | Revert: `Not authorised` | To be filled after run |
| Unauthorised return | Another wallet marks active loan returned | Revert: `Borrower only` | To be filled after run |

## Submission

Create a GitHub repository such as `campus-gear-lending-dapp` and upload these files, actual deployment details, test results, and genuine screenshots in `evidence/`. Make it accessible to the evaluator. Complete a Word document named `YourName_RegNum_BT_Assignment2.docx` with your name, registration number, assignment title, DApp title, and repository link. Export it as a PDF and submit that PDF to the LMS. The assessor needs a reachable repository, a real deployed address, and actual evidence; these cannot be generated offline.

## References

- [Ethers.js v6 Getting Started](https://docs.ethers.org/v6/getting-started/)
- [Remix Deploy & Run](https://remix-ide.readthedocs.io/en/latest/run.html)
- [Remix Solidity Unit Testing](https://remix-ide.readthedocs.io/en/latest/unittesting.html)

## Security notes

This educational prototype is not audited. Wallet addresses, item labels, and due dates are public. A custodian must verify physical handover and returns off-chain. Avoid personally identifying item names. Do not commit private keys, recovery phrases, passwords, or `node_modules`.
