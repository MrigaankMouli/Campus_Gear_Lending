# Screenshot evidence checklist

The following captures are already included in `../assets/` and described in the root README:

1. `../assets/01-compiled.png`: existing Remix compiler capture.
2. `../assets/02-deployed1.png` and `../assets/02-deployed2.png`: existing Sepolia confirmation and Remix deployed contract captures.
3. `../assets/03-Transaction1.png` through `../assets/03-Transaction5.png`: the ordered add, request, approve, mark returned, and confirm return sequence with transaction hashes and inventory/loan displays. `03-Transaction2.png` and `03-Transaction3.png` also show the borrower and custodian account selections.
4. `../assets/04-MetaMask_Transaction_Ex.png`: the MetaMask signing prompt on Sepolia, before confirmation.
5. `../assets/05-FaliureExample.png`: a borrower attempting to add equipment and receiving a frontend validation error. This does not show a mined failed transaction or Solidity revert.

Still to capture if required for the submission: the actual Remix Solidity Unit Testing result and a separate invalid or unauthorised contract call with its real revert message. The Remix test workspace needs `contracts/CampusGearLending.sol`, `test-support/BorrowerActor.sol`, and `tests/CampusGearLending_test.sol` at those relative paths. Label an error during gas estimation as a pre-submission rejection rather than a mined failed transaction.

Do not include private keys, seed phrases, or passwords in screenshots.
