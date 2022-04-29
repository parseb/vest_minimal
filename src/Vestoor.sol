// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Vestoor
/// @author parseb petra306@protonmail.com
contract Vestoor is ReentrancyGuard {

    /// @notice storage and getter for vesting agreements
    mapping (address => mapping(address => uint256)) public vestings;
    uint256 immutable k; //19

    error VestingInProgress(address, address);


    constructor(uint256 _k) public {
        k = _k;
    }
    function setVest(address _token, 
                    address _beneficiary, 
                    uint256 _amount, 
                    uint256 _enddate) 
                    external 
                    returns (bool s) {

        if (vestings[_token][_beneficiary] != 0) revert VestingInProgress(_token, _beneficiary);
        require(IERC20(_token).balanceOf(msg.sender) >= _amount, "Insufficient funds");

        require(_amount > 0, "Amount must be greater than 0");
        require(_beneficiary != address(0), "Beneficiary is 0");
        require(_enddate > block.timestamp, "Present given. Requires Future.");
        require(_amount > _enddate, "Amount must be greater than enddate");

        vestings[_token][_beneficiary] = _amount * k + _enddate;

        s = IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        return s;
    }



    function approveMyBag(address _token) public nonReentrant returns (bool s) {
        uint256 iv= vestings[_token][msg.sender];
        require(vestings[_token][msg.sender] != 0, "Nothing to bag");

        if (iv % k < block.timestamp) {
            s = IERC20(_token).approve(msg.sender, iv/k);
            require(s, "Approve failed");
            vestings[_token][msg.sender] = 0;
        } else {
            uint256 eligibleAmount = (block.timestamp - (iv % k) ) * k / (iv / k);
            s = IERC20(_token).approve(msg.sender, eligibleAmount);
            require(s, "Approve failed");
            vestings[_token][msg.sender] = (iv / k - eligibleAmount) * k + (iv % k);
        }

        
        

    }


    function getVest(address _token, address _beneficiary) external view returns (uint256) {
        return vestings[_token][_beneficiary];
    }
}

