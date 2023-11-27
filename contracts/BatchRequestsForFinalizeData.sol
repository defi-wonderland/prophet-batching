// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IOracle.sol';

/**
 * @title BatchRequestsForFinalizeData contract
 * @notice This contract is used to get batch requests min data from the oracle contract to finalize the requests
 */
contract BatchRequestsForFinalizeData {
  struct ResponseData {
    bytes32 responseId;
    uint256 responseCreatedAt;
  }

  struct RequestForFinalizeData {
    bytes32 requestId;
    uint256 requestCreatedAt;
    uint256 finalizedAt;
    ResponseData[] responses;
  }

  constructor(IOracle _oracle, uint256 _startFrom, uint256 _amount) {
    RequestForFinalizeData[] memory _returnData = new RequestForFinalizeData[](_amount);

    bytes32[] memory _requestsIds = _oracle.listRequestIds(_startFrom, _amount);

    for (uint256 _i = 0; _i < _requestsIds.length; _i++) {
      bytes32 _requestId = _requestsIds[_i];

      bytes32[] memory _responsesIds = _oracle.getResponseIds(_requestId);
      ResponseData[] memory _responses = new ResponseData[](_responsesIds.length);

      for (uint256 _j = 0; _j < _responsesIds.length; _j++) {
        _responses[_j] = ResponseData({responseId: _responsesIds[_j], responseCreatedAt: _oracle.createdAt(_responsesIds[_j])});
      }

      _returnData[_i] = RequestForFinalizeData({
        requestId: _requestId,
        requestCreatedAt: _oracle.createdAt(_requestId),
        finalizedAt: _oracle.finalizedAt(_requestId),
        responses: _responses
      });
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
