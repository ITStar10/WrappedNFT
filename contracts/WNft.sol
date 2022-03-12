// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WNft is ERC1155, ERC1155Holder, Ownable {
   
    IERC1155 public FNFT;
    mapping(uint256 => bool) exists;
    

    constructor(IERC1155 _FNFT) ERC1155("") {
        FNFT = _FNFT;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, ERC1155Receiver) returns (bool) {
        return ERC1155.supportsInterface(interfaceId) || ERC1155Receiver.supportsInterface(interfaceId);
    }

    function _createWrappedFnt(address to, uint tokenId) internal {
        _mint(to, tokenId, 1, "");
    }

    function onERC1155Received(
        address,
        address from,
        uint256 id,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (msg.sender == address(FNFT)) {
            if (!exists[id]) {
                _createWrappedFnt(from, id);
            } else {
                _safeTransferFrom(address(this), from, id, 1, "");
            }
            exists[id] = true;
        } else if (msg.sender == address(this)) {
            FNFT.safeTransferFrom(address(this), from, id, 1, "");
            exists[id] = false;
        }

        return this.onERC1155Received.selector;
    }
}