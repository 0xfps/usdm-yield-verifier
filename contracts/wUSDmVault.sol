// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./EpochManager.sol";
import "./interfaces/IZKYieldVerifier.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract wUSDmVault {
    struct Stake {
        uint256 amount;
        uint256 startEpoch;
    }

    IERC20 public immutable usdm;
    EpochManager public immutable epochManager;
    mapping(address => Stake[]) public stakes;

    event Wrapped(address indexed user, uint256 amount, uint256 epoch);
    event Unwrapped(address indexed user, uint256 amount);

    constructor(address _usdm, address _epochManager) {
        usdm = IERC20(_usdm);
        epochManager = EpochManager(_epochManager);
    }

    function wrap(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        usdm.transferFrom(msg.sender, address(this), amount);
        uint256 currentEpoch = epochManager.getCurrentEpoch();
        stakes[msg.sender].push(Stake({ amount: amount, startEpoch: currentEpoch }));
        emit Wrapped(msg.sender, amount, currentEpoch);
    }

    function unwrap(uint256 index) external {
        Stake memory s = stakes[msg.sender][index];
        require(s.amount > 0, "Nothing to unwrap");
        delete stakes[msg.sender][index];
        usdm.transfer(msg.sender, s.amount);
        emit Unwrapped(msg.sender, s.amount);
    }

    function getUserStakeSum(address user) external view returns (uint256 total) {
        Stake[] memory arr = stakes[user];
        for (uint256 i = 0; i < arr.length; i++) {
            total += arr[i].amount;
        }
    }
}

