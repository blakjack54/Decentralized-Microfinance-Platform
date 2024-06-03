// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Microfinance {
    struct Loan {
        address borrower;
        uint256 amount;
        uint256 repaymentAmount;
        uint256 dueDate;
        bool repaid;
        address lender;
    }

    uint256 public loanCount;
    mapping(uint256 => Loan) public loans;

    event LoanRequested(uint256 loanId, address borrower, uint256 amount, uint256 repaymentAmount, uint256 dueDate);
    event LoanFunded(uint256 loanId, address lender);
    event LoanRepaid(uint256 loanId, address borrower);

    function requestLoan(uint256 amount, uint256 repaymentAmount, uint256 duration) external {
        loanCount++;
        loans[loanCount] = Loan(msg.sender, amount, repaymentAmount, block.timestamp + duration, false, address(0));
        emit LoanRequested(loanCount, msg.sender, amount, repaymentAmount, block.timestamp + duration);
    }

    function fundLoan(uint256 loanId) external payable {
        Loan storage loan = loans[loanId];
        require(loan.lender == address(0), "Loan already funded");
        require(msg.value == loan.amount, "Incorrect loan amount");

        loan.lender = msg.sender;
        payable(loan.borrower).transfer(loan.amount);
        emit LoanFunded(loanId, msg.sender);
    }

    function repayLoan(uint256 loanId) external payable {
        Loan storage loan = loans[loanId];
        require(loan.lender != address(0), "Loan not funded");
        require(!loan.repaid, "Loan already repaid");
        require(block.timestamp <= loan.dueDate, "Loan overdue");
        require(msg.value == loan.repaymentAmount, "Incorrect repayment amount");

        loan.repaid = true;
        payable(loan.lender).transfer(loan.repaymentAmount);
        emit LoanRepaid(loanId, msg.sender);
    }

    function getLoan(uint256 loanId) external view returns (address borrower, uint256 amount, uint256 repaymentAmount, uint256 dueDate, bool repaid, address lender) {
        Loan storage loan = loans[loanId];
        return (loan.borrower, loan.amount, loan.repaymentAmount, loan.dueDate, loan.repaid, loan.lender);
    }
}
