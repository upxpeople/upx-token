// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./UPXBurnable.sol";
import "./UPXAccessControl.sol";

contract UPX is ERC20, UPXBurnable, UPXAccessControl {
  using SafeMath for uint256;

  string private _tokenName = "UPX People DAO";
  string private _tokenSymbol = "UPX";
  uint8 private _decimals = 18;
  uint256 private _maximumSupply = 100000000000 * (10 ** _decimals);

  bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");

  constructor() ERC20(_tokenName, _tokenSymbol) {
      _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function grantBurnRole(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(_account != address(0), "UPX: cannot grant role to zero address");

      _grantRole(BURN_ROLE, _account);
  }

  function revokeBurnRole(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(hasRole(BURN_ROLE, _account), "UPX: unauthorized address");

      _revokeRole(BURN_ROLE, _account);
  }

  function mint(address _account, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(_amount > 0, "UPX: cannot mint zero");

      uint256 currentSupply = totalSupply();
      uint256 newSupply = currentSupply.add(_amount);

      require(newSupply <= _maximumSupply, "UPX: maximum supply volume exceeded");

      _mint(_account, _amount);
  }

  function burn(uint256 _amount) public override onlyRole(BURN_ROLE) {
      require(_amount > 0, "UPX: cannot burn zero");

      uint256 balance = balanceOf(msg.sender);
      
      require(_amount <= balance, "UPX: exceeded wallet balance");

      _burn(msg.sender, _amount);
  }

  function maximumSupply() public view virtual returns (uint256) {
      return _maximumSupply;
  }

  function decimals() public view virtual override returns (uint8) {
      return _decimals;
  }
}