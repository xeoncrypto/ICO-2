pragma solidity ^0.4.15;

import "./OpportyToken.sol";
import "./Ownable.sol";

contract HoldPresaleContract is Ownable {
  using SafeMath for uint256;
  // Addresses and contracts
  OpportyToken public OppToken;
  address private presaleCont;

  struct Holder {
    bool isActive;
    uint tokens;
    uint8 holdPeriod;
    uint holdPeriodTimestamp;
    bool withdrawed;
  }

  mapping(address => Holder) public holderList;
  mapping(uint => address) private holderIndexes;

  mapping (uint => address) private assetOwners;
  mapping (address => uint) private assetOwnersIndex;
  uint public assetOwnersIndexes;

  uint private holderIndex;

  event TokensTransfered(address contributor , uint amount);
  event Hold(address sender, address contributor, uint amount, uint8 holdPeriod);

  modifier onlyAssetsOwners() {
    require(assetOwnersIndex[msg.sender] > 0);
    _;
  }

  /* constructor */
  function HoldPresaleContract(address _OppToken) {
    OppToken = OpportyToken(_OppToken);
  }

  function setPresaleCont(address pres)  public onlyOwner
  {
    presaleCont = pres;
  }

  function addHolder(address holder, uint tokens, uint8 timed, uint timest) onlyAssetsOwners external {
    if (holderList[holder].isActive == false) {
      holderList[holder].isActive = true;
      holderList[holder].tokens = tokens;
      holderList[holder].holdPeriod = timed;
      holderList[holder].holdPeriodTimestamp = timest;
      holderIndexes[holderIndex] = holder;
      holderIndex++;
    } else {
      holderList[holder].tokens += tokens;
      holderList[holder].holdPeriod = timed;
      holderList[holder].holdPeriodTimestamp = timest;
    }
    Hold(msg.sender, holder, tokens, timed);
  }

  function getBalance() constant returns (uint) {
    return OppToken.balanceOf(this);
  }

  function unlockTokens() external {
    address contributor = msg.sender;

    if (holderList[contributor].isActive && !holderList[contributor].withdrawed) {
      if (now >= holderList[contributor].holdPeriodTimestamp) {
        if ( OppToken.transfer( msg.sender, holderList[contributor].tokens ) ) {
          holderList[contributor].withdrawed = true;
          TokensTransfered(contributor,  holderList[contributor].tokens);
        }
      } else {
        revert();
      }
    } else {
      revert();
    }
  }

  function addAssetsOwner(address _owner) public onlyOwner {
    assetOwnersIndexes++;
    assetOwners[assetOwnersIndexes] = _owner;
    assetOwnersIndex[_owner] = assetOwnersIndexes;
  }
  function removeAssetsOwner(address _owner) public onlyOwner {
    uint index = assetOwnersIndex[_owner];
    delete assetOwnersIndex[_owner];
    delete assetOwners[index];
    assetOwnersIndexes--;
  }
  function getAssetsOwners(uint _index) onlyOwner public constant returns (address) {
    return assetOwners[_index];
  }
}
