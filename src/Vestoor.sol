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

    event NewVesting(address indexed token, address indexed beneficiary, uint256 amt, uint256 bywhen);
    event VestingCompleted(address indexed token, address indexed beneficiary, uint256 amt);
    event WithdrewFromVest(address indexed token, address indexed beneficiary, uint256 partialAmt);

    /// @notice constructor sets immutable constant
    /// @param _k constant for vesting time and ammount encoding in 1 uint256
    constructor(uint256 _k) public {
        k = _k;
    }


    /// @notice set vesting agreement
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
        require(_amount < k, "Max amount is k-1");

        vestings[_token][_beneficiary] = _amount * k + ( _enddate * days + block.timestamp );

        s = IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        emit NewVesting(_token, _beneficiary, _amount, _enddate);
        return s;
    }



    function approveMyBag(address _token) public nonReentrant returns (bool s) {
        uint256 iv= vestings[_token][msg.sender];
        require(vestings[_token][msg.sender] != 0, "Nothing to bag");

        if (iv % k > block.timestamp) {
            s = IERC20(_token).transfer(msg.sender, iv/k);
            require(s, "Transfer failed");
            vestings[_token][msg.sender] = 0;

            emit VestingCompleted(_token, msg.sender, iv/k);

        } else {
            uint256 eligibleAmount = (iv / k) - ( ((iv / k) / (iv % k)) * ( (iv % k) - block.timestamp ) );
            vestings[_token][msg.sender] = (iv / k - eligibleAmount) * k + ((iv % k);

            s = IERC20(_token).transfer(msg.sender, eligibleAmount);
            require(s, "Transfer failed");
        }

        
        

    }


    function getVest(address _token, address _beneficiary) external view returns (uint256) {
        return vestings[_token][_beneficiary];
    }
}

