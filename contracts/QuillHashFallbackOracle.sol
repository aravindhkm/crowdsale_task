// SPDX-License-Identifier: agpl-3.0

import './interfaces/IPriceOracleGetter.sol';
import './interfaces/Ownable.sol';
import './libraries/SafeMath.sol';

pragma solidity 0.7.6;
pragma abicoder v2;

contract QuillHashFallbackOracle is Ownable, IPriceOracleGetter {
  using SafeMath for uint256;

  struct Price {
    uint64 blockNumber;
    uint64 blockTimestamp;
    uint128 price;
  }

  event PricesSubmitted(address sybil, address assets, uint128 prices);
  event SybilAuthorized(address indexed sybil);
  event SybilUnauthorized(address indexed sybil);

  mapping(address => Price) private _prices;

  mapping(address => bool) private _sybils;

  modifier onlySybil {
    _requireWhitelistedSybil(msg.sender);
    _;
  }

  function authorizeSybil(address sybil) external onlyOwner {
    _sybils[sybil] = true;

    emit SybilAuthorized(sybil);
  }

  function unauthorizeSybil(address sybil) external onlyOwner {
    _sybils[sybil] = false;

    emit SybilUnauthorized(sybil);
  }

  function submitPrices(address assets, uint128 prices) external onlySybil {
    _prices[assets] = Price(uint64(block.number), uint64(block.timestamp), prices);
    emit PricesSubmitted(msg.sender, assets, prices);
  }

  function getAssetPrice(address asset) external view override returns (uint256) {
    return uint256(_prices[asset].price);
  }

  function isSybilWhitelisted(address sybil) public view returns (bool) {
    return _sybils[sybil];
  }

  function getPricesData(address assets) external view returns (Price memory) {
      return _prices[assets];
  }

  function _requireWhitelistedSybil(address sybil) internal view {
    require(isSybilWhitelisted(sybil), 'INVALID_SYBIL');
  }
}