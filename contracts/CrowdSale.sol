// SPDX-License-Identifier: GPL-3.0

import './interfaces/IERC20.sol';
import './interfaces/Pausable.sol';
import './interfaces/IPriceOracleGetter.sol';
import './libraries/SafeMath.sol';
import './libraries/SafeERC20.sol';

pragma solidity ^0.7.6;

contract Crowdsale is Pausable {
      using SafeMath for uint256;
      using SafeERC20 for IERC20;
    
      IERC20 public token;
      IPriceOracleGetter public oracle;
    
      address public wallet;
      
      uint256 public minimumRequire = 500;
      uint256 public tokenPrice = 1e15;  // 0.001 USD
      uint256 public saleEndTIme;
      
      mapping (address => bool) public WhiteLisiters;
    
      /**
       * Event for token purchase logging
       * @param value weis paid for purchase
       * @param amount amount of tokens purchased
       */
      event TokenPurchase(
        address indexed purchaser,
        uint256 value,
        uint256 amount
      );
    
      /**
      * @param _wallet Address where collected funds will be forwarded to
      * @param _token Address of the token being sold
      */
      constructor(address _wallet, address _token,address _oracle) {
          wallet = _wallet;
          token = IERC20(_token);
          oracle = IPriceOracleGetter(_oracle);
          
          saleEndTIme = block.timestamp + 2592000; // 30 Days
      }
      
      receive () external payable {
          this.buyTokens();
      }
      
      function addInvestor(address _addr) public onlyOwner {
          require(!WhiteLisiters[_addr], "already added");
          
          WhiteLisiters[_addr] = true;
      }
      
      function removeInvestor(address _addr) public onlyOwner {
          require(WhiteLisiters[_addr], "already removed");
          
          WhiteLisiters[_addr] = false;
      }
      
      function getTokenAmount() public view returns(uint256){
         return (oracle.getAssetPrice(address(token)).div(10**8));
      } 
      
      function buyTokens() external whenNotPaused payable {
          buy(msg.sender,msg.value);
      }
      
      function buy(address _addr,uint256 amountIn) internal {
        require(saleEndTIme >= block.timestamp, "Crowdsale finished");
         require(WhiteLisiters[_addr], "Only investor can call");
        
        uint256 getAmountIn = amountIn.mul(oracle.getAssetPrice(address(token))).div(10 ** 26);  
        require(getAmountIn >= minimumRequire, "minimum deposit amount is 500 USD");
        
        uint256 getTokenOut = getAmountIn.mul(10 ** 18).div(tokenPrice).mul(10 ** 18);
        
        token.safeTransfer(_addr,getTokenOut);
        payable(wallet).transfer(amountIn);
        
    
        emit TokenPurchase(
          _addr,
          amountIn,
          getTokenOut
        );
    
      }
}