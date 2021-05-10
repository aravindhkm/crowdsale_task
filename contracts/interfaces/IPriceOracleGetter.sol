// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;


interface IPriceOracleGetter {
  /**
   * @dev returns the asset price in ETH wei
   * @param asset the address of the asset
   **/
  function getAssetPrice(address asset) external view returns (uint256);
}