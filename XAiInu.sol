/*
██╗░░██╗  ░█████╗░██╗  ██╗███╗░░██╗██╗░░░██╗
╚██╗██╔╝  ██╔══██╗██║  ██║████╗░██║██║░░░██║
░╚███╔╝░  ███████║██║  ██║██╔██╗██║██║░░░██║
░██╔██╗░  ██╔══██║██║  ██║██║╚████║██║░░░██║
██╔╝╚██╗  ██║░░██║██║  ██║██║░╚███║╚██████╔╝
╚═╝░░╚═╝  ╚═╝░░╚═╝╚═╝  ╚═╝╚═╝░░╚══╝░╚═════╝░
_____________________________________________
*  Site.....: https://xaiinu.net            *
*  Telegram.: https://t.me/Xaiinuofficial   *
*  X........: https://X.com/Xaiinuofficial  *
_____________________________________________
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @custom:security-contact support@xaiinu.net
contract XAiInu is ERC20, ERC20Burnable, ERC20Permit, Ownable {

    uint8 constant DECIMALS = 18;
    uint256 _supply = 2_000_000_000 * 10**DECIMALS;
    
    event enableTradingEvent(bool launch);

    constructor() ERC20("X Ai Inu", "XAiInu") Ownable(msg.sender) ERC20Permit("XAiInu")
    {
        _mint(msg.sender, _supply);
    }

    function claimStuckTokens(address token) external onlyOwner() {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        ERC20 ERC20token = ERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    receive() external payable {
    }

    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount) 
        public override returns (bool) {

        _approve(
            sender,
            _msgSender(),
            allowance(sender, _msgSender()) - amount
        );
        return _customTransferFrom(sender, recipient, amount);
    }

    function transfer(
        address recipient,
        uint256 amount) 
        public virtual override returns (bool){
        return _customTransferFrom(_msgSender(), recipient, amount);
    }

    function _customTransferFrom(
        address sender, 
        address recipient, 
        uint256 amount) 
        internal returns (bool) {
        require(Launched || sender == owner() || recipient == owner(), "Project is not launched.");
        super._transfer(sender, recipient, amount);
        return true;
    }
    
    bool public Launched = false;
    function launch() public onlyOwner() {
       require(!Launched,  "Project is already launched.");
       Launched = true;
       emit enableTradingEvent(Launched);
    }
   
}