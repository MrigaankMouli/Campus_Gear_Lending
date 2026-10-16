// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/CampusGearLending.sol";

// Calls the ledger from a distinct address in Remix unit tests.
// Keep this helper outside the *_test.sol file: Remix requires test methods
// to have no parameters, while these forwarding methods need arguments.
contract BorrowerActor {
    function request(CampusGearLending ledger, uint256 itemId, uint256 dueAt) external {
        ledger.requestLoan(itemId, dueAt);
    }

    function returnItem(CampusGearLending ledger, uint256 loanId) external {
        ledger.markReturned(loanId);
    }

    function cancel(CampusGearLending ledger, uint256 loanId) external {
        ledger.cancelRequest(loanId);
    }

    function approve(CampusGearLending ledger, uint256 loanId) external {
        ledger.approveLoan(loanId);
    }

    function add(CampusGearLending ledger, string calldata name) external {
        ledger.addItem(name);
    }
}
