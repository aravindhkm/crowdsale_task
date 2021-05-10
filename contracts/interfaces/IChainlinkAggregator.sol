// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;

interface IChainlinkAggregator {
  function latestAnswer() external view returns (int256);
}