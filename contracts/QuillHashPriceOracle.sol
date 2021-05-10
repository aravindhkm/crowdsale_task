// SPDX-License-Identifier: agpl-3.0

import './interfaces/IPriceOracleGetter.sol';
import './interfaces/IChainlinkAggregator.sol';
import './interfaces/Ownable.sol';

pragma solidity 0.7.6;


/// @title QuillHashOracle
/// @author QuillHash
/// @notice Proxy smart contract to get the price of an asset from a price source, with Chainlink Aggregator
///         smart contracts as primary option
/// - If the returned price by a Chainlink aggregator is <= 0, the call is forwarded to a fallbackOracle
/// - Owned by the QuillHash governance system, allowed to add sources for assets, replace them
///   and change the fallbackOracle
contract QuillHashPriceOracle is IPriceOracleGetter, Ownable {
  event AssetSourceUpdated(address indexed asset, address indexed source);
  event FallbackOracleUpdated(address indexed fallbackOracle);

  mapping(address => IChainlinkAggregator) private assetsSources;
  IPriceOracleGetter private _fallbackOracle;
  
  bool private priceRouter; // true is chainlink router and false in quillhash oracle.

  /// @notice Constructor
  /// @param assets The addresses of the assets
  /// @param sources The address of the source of each asset
  /// @param fallbackOracle The address of the fallback oracle to use if the data of an
  ///        aggregator is not consistent
  constructor(
    address assets,
    address sources,
    address fallbackOracle
  ) {
    _setFallbackOracle(fallbackOracle);
    _setAssetsSources(assets, sources);
    
    priceRouter = true;
  }
  
  /// @notice Public function called by the QuillHash Owner to set or replace price feeds
  function enableChainLink() public onlyOwner {
      require(!priceRouter, "Chainlink: already enabled");
      
      priceRouter = true;
  }
  
  /// @notice Public function called by the QuillHash Owner to set or replace sources price feeds
  function enableFallbackPriceOracle() public onlyOwner {
      require(priceRouter, "Chainlink: already enabled");
      
      priceRouter = false;
  }

  /// @notice External function called by the QuillHash governance to set or replace sources of assets
  /// @param assets The addresses of the assets
  /// @param sources The address of the source of each asset
  function setAssetSources(address assets, address sources)
    external
    onlyOwner
  {
    _setAssetsSources(assets, sources);
  }

  /// @notice Sets the fallbackOracle
  /// - Callable only by the QuillHash governance
  /// @param fallbackOracle The address of the fallbackOracle
  function setFallbackOracle(address fallbackOracle) external onlyOwner {
    _setFallbackOracle(fallbackOracle);
  }

  /// @notice Internal function to set the sources for each asset
  /// @param assets The addresses of the assets
  /// @param sources The address of the source of each asset
  function _setAssetsSources(address assets, address sources) internal {
      assetsSources[assets] = IChainlinkAggregator(sources);
      emit AssetSourceUpdated(assets, sources);
  }

  /// @notice Internal function to set the fallbackOracle
  /// @param fallbackOracle The address of the fallbackOracle
  function _setFallbackOracle(address fallbackOracle) internal {
    _fallbackOracle = IPriceOracleGetter(fallbackOracle);
    emit FallbackOracleUpdated(fallbackOracle);
  }

  /// @notice Gets an asset price by address
  /// @param asset The asset address
  function getAssetPrice(address asset) public override view returns (uint256) {
    IChainlinkAggregator source = assetsSources[asset];

    if (priceRouter) {
      int256 price = IChainlinkAggregator(source).latestAnswer();
      if (price > 0) {
        return uint256(price);
      } else {
        return _fallbackOracle.getAssetPrice(asset);
      }
    } else {
      return _fallbackOracle.getAssetPrice(asset);
    }
  }

  /// @notice Gets a list of prices from a list of assets addresses
  /// @param assets The list of assets addresses
  function getAssetsPrices(address assets) external view returns (uint256) {
      return getAssetPrice(assets);
  }

  /// @notice Gets the address of the source for an asset address
  /// @param asset The address of the asset
  /// @return address The address of the source
  function getSourceOfAsset(address asset) external view returns (address) {
    return address(assetsSources[asset]);
  }

  /// @notice Gets the address of the fallback oracle
  /// @return address The addres of the fallback oracle
  function getFallbackOracle() external view returns (address) {
    return address(_fallbackOracle);
  }
}