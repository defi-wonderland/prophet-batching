// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IOracle.sol';

/**
 * @title BatchResponsesData contract
 * @notice This contract is used to get batch responses data from the oracle contract
 */
contract BatchResponsesData {
  struct ResponseData {
    bytes32 responseId;
    uint256 createdAt;
    bytes32 disputeId;
  }

  constructor(IOracle _oracle, bytes32 _requestId) {
    bytes32[] memory _responseIds = _oracle.getResponseIds(_requestId);
    ResponseData[] memory _returnData = new ResponseData[](_responseIds.length);

    for (uint256 _i = 0; _i < _responseIds.length; _i++) {
      bytes32 _responseId = _responseIds[_i];
      ResponseData memory _response = ResponseData({
        responseId: _responseIds[_i],
        createdAt: _oracle.createdAt(_responseId),
        disputeId: _oracle.disputeOf(_responseId)
      });
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
