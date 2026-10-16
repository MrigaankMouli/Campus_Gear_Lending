// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol";
import "../contracts/CampusGearLending.sol";
import "../test-support/BorrowerActor.sol";

contract CampusGearLendingTest {
    CampusGearLending ledger;
    BorrowerActor alice;
    BorrowerActor bob;

    function beforeEach() public {
        ledger = new CampusGearLending();
        alice = new BorrowerActor();
        bob = new BorrowerActor();
        ledger.addItem("Camera kit");
    }

    function validLifecycle() public {
        alice.request(ledger, 1, block.timestamp + 1 days);
        ledger.approveLoan(1);
        alice.returnItem(ledger, 1);
        ledger.confirmReturn(1);
        CampusGearLending.Item memory item = ledger.getItem(1);
        CampusGearLending.Loan memory loan = ledger.getLoan(1);
        Assert.equal(uint256(loan.status), uint256(CampusGearLending.Status.Closed), "Loan closed");
        Assert.equal(item.currentLoanId, uint256(0), "Item available again");
        Assert.equal(loan.borrower, address(alice), "Borrower recorded");
    }

    function invalidInputAndDoubleBooking() public {
        (bool emptyName,) = address(ledger).call(abi.encodeWithSelector(ledger.addItem.selector, ""));
        Assert.ok(!emptyName, "Empty name rejected");
        (bool pastDue,) = address(alice).call(abi.encodeWithSelector(alice.request.selector, ledger, 1, block.timestamp));
        Assert.ok(!pastDue, "Past due date rejected");
        (bool unknownItem,) = address(alice).call(abi.encodeWithSelector(alice.request.selector, ledger, 99, block.timestamp + 1 days));
        Assert.ok(!unknownItem, "Unknown item rejected");
        alice.request(ledger, 1, block.timestamp + 1 days);
        (bool doubleBook,) = address(bob).call(abi.encodeWithSelector(bob.request.selector, ledger, 1, block.timestamp + 1 days));
        Assert.ok(!doubleBook, "Double booking rejected");
    }

    function unauthorisedAccess() public {
        (bool addOk,) = address(alice).call(abi.encodeWithSelector(alice.add.selector, ledger, "Projector"));
        Assert.ok(!addOk, "Non custodian cannot add");
        alice.request(ledger, 1, block.timestamp + 1 days);
        (bool approveOk,) = address(alice).call(abi.encodeWithSelector(alice.approve.selector, ledger, 1));
        Assert.ok(!approveOk, "Non custodian cannot approve");
        (bool cancelOk,) = address(bob).call(abi.encodeWithSelector(bob.cancel.selector, ledger, 1));
        Assert.ok(!cancelOk, "Unrelated wallet cannot cancel");
        ledger.approveLoan(1);
        (bool returnOk,) = address(bob).call(abi.encodeWithSelector(bob.returnItem.selector, ledger, 1));
        Assert.ok(!returnOk, "Non borrower cannot return");
    }

    function cancellationReleasesItem() public {
        alice.request(ledger, 1, block.timestamp + 1 days);
        alice.cancel(ledger, 1);
        CampusGearLending.Item memory item = ledger.getItem(1);
        Assert.equal(item.currentLoanId, uint256(0), "Cancelled item available");
        bob.request(ledger, 1, block.timestamp + 2 days);
        Assert.equal(ledger.loanCount(), uint256(2), "New borrower can request");
    }
}
