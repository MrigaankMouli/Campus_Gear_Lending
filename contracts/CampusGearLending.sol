// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Campus Gear Lending
/// @notice A custodian records equipment loans without putting student identity data on-chain.
contract CampusGearLending {
    address public immutable custodian;
    uint256 public constant MAX_LOAN_DURATION = 30 days;

    enum Status { Pending, Active, ReturnPending, Closed, Cancelled }

    struct Item {
        string name;
        bool enabled;
        uint256 currentLoanId;
    }

    struct Loan {
        uint256 itemId;
        address borrower;
        uint256 dueAt;
        Status status;
    }

    Item[] private items;
    Loan[] private loans;

    event ItemAdded(uint256 indexed itemId, string name);
    event ItemEnabled(uint256 indexed itemId, bool enabled);
    event LoanRequested(uint256 indexed loanId, uint256 indexed itemId, address indexed borrower);
    event LoanStatusChanged(uint256 indexed loanId, Status status);

    modifier onlyCustodian() {
        require(msg.sender == custodian, "Custodian only");
        _;
    }

    constructor() {
        custodian = msg.sender;
    }

    function addItem(string calldata name) external onlyCustodian returns (uint256 itemId) {
        require(bytes(name).length > 0 && bytes(name).length <= 80, "Name must be 1-80 bytes");
        items.push(Item({name: name, enabled: true, currentLoanId: 0}));
        itemId = items.length;
        emit ItemAdded(itemId, name);
    }

    function setItemEnabled(uint256 itemId, bool enabled) external onlyCustodian {
        Item storage item = _item(itemId);
        require(item.enabled != enabled, "Already in this state");
        item.enabled = enabled;
        emit ItemEnabled(itemId, enabled);
    }

    function requestLoan(uint256 itemId, uint256 dueAt) external returns (uint256 loanId) {
        require(msg.sender != custodian, "Custodian cannot borrow");
        Item storage item = _item(itemId);
        require(item.enabled, "Item disabled");
        require(item.currentLoanId == 0, "Item unavailable");
        require(dueAt > block.timestamp && dueAt - block.timestamp <= MAX_LOAN_DURATION,
            "Due date must be within 30 days");
        loans.push(Loan({itemId: itemId, borrower: msg.sender, dueAt: dueAt, status: Status.Pending}));
        loanId = loans.length;
        item.currentLoanId = loanId;
        emit LoanRequested(loanId, itemId, msg.sender);
    }

    function approveLoan(uint256 loanId) external onlyCustodian {
        Loan storage loan = _loan(loanId);
        require(loan.status == Status.Pending, "Loan not pending");
        require(block.timestamp < loan.dueAt, "Due date passed");
        require(items[loan.itemId - 1].enabled, "Item disabled");
        loan.status = Status.Active;
        emit LoanStatusChanged(loanId, Status.Active);
    }

    function cancelRequest(uint256 loanId) external {
        Loan storage loan = _loan(loanId);
        require(msg.sender == loan.borrower || msg.sender == custodian, "Not authorised");
        require(loan.status == Status.Pending, "Loan not pending");
        loan.status = Status.Cancelled;
        items[loan.itemId - 1].currentLoanId = 0;
        emit LoanStatusChanged(loanId, Status.Cancelled);
    }

    function markReturned(uint256 loanId) external {
        Loan storage loan = _loan(loanId);
        require(msg.sender == loan.borrower, "Borrower only");
        require(loan.status == Status.Active, "Loan not active");
        loan.status = Status.ReturnPending;
        emit LoanStatusChanged(loanId, Status.ReturnPending);
    }

    function confirmReturn(uint256 loanId) external onlyCustodian {
        Loan storage loan = _loan(loanId);
        require(loan.status == Status.ReturnPending, "Return not pending");
        loan.status = Status.Closed;
        items[loan.itemId - 1].currentLoanId = 0;
        emit LoanStatusChanged(loanId, Status.Closed);
    }

    function itemCount() external view returns (uint256) { return items.length; }
    function loanCount() external view returns (uint256) { return loans.length; }

    function getItem(uint256 itemId) external view returns (Item memory) { return _item(itemId); }
    function getLoan(uint256 loanId) external view returns (Loan memory) { return _loan(loanId); }

    function _item(uint256 itemId) internal view returns (Item storage) {
        require(itemId > 0 && itemId <= items.length, "Unknown item");
        return items[itemId - 1];
    }

    function _loan(uint256 loanId) internal view returns (Loan storage) {
        require(loanId > 0 && loanId <= loans.length, "Unknown loan");
        return loans[loanId - 1];
    }
}
