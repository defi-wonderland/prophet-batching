// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from 'prophet-core-abi/contracts/IOracle.sol';

/**
  * @title BatchResponsesData contract
  * @notice This contract is used to get batch responses data from the oracle contract
 */
contract BatchResponsesData {

  constructor(IOracle _oracle, bytes32 _requestId) {
    bytes32[] memory _responseIds = _oracle.getResponseIds(_requestId);
    IOracle.Response[] memory _returnData = new IOracle.Response[](_responseIds.length);
    
    for (uint256 _i = 0; _i < _responseIds.length; _i++) {
        IOracle.Response memory _response = _oracle.getResponse(_responseIds[_i]);
        _returnData[_i] = _response;
    }
    
    // encode return data
    bytes memory data = abi.encode(_returnData);
    
    // force constructor return via assembly
    assembly {
        let dataStart := add(data, 32) // abi.encode adds an additional offset
        return(dataStart, sub(msize(), dataStart))
    }
  }
}
