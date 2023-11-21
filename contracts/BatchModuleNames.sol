// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IModule} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IModule.sol';

/**
 * @title BatchResponsesData contract
 * @notice This contract is used to get batch responses data from the oracle contract
 */
contract BatchModuleNames {
  constructor(IModule[] memory _modules) {
    string[] memory _returnData = new string[](_modules.length);

    for (uint256 _i = 0; _i < _modules.length; _i++) {
      IModule _module = _modules[_i];
      _returnData[_i] = _getModuleName(_module);
    }

    // encode return data
    bytes memory data = abi.encode(_returnData);

    // force constructor return via assembly
    assembly {
      let dataStart := add(data, 32) // abi.encode adds an additional offset
      return(dataStart, sub(msize(), dataStart))
    }
  }

  function _getModuleName(IModule _module) internal view returns (string memory) {
    return address(_module) == address(0) ? '' : _module.moduleName();
  }
}
