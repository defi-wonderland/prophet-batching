// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from 'prophet-core-abi/contracts/IOracle.sol';
import {IModule} from 'prophet-core-abi/contracts/IModule.sol';

/**
  * @title BatchRequestsForFinalizeData contract
  * @notice This contract is used to get batch requests data from the oracle contract
  */
contract BatchRequestsForFinalizeData {
  struct RequestForFinalizeData {
    bytes32 requestId;
    uint256 finalizedAt;
    bytes32[] responses;
  }

  constructor(IOracle _oracle, uint256 _startFrom, uint256 _amount) {
    RequestForFinalizeData[] memory _returnData = new RequestForFinalizeData[](_amount);

    IOracle.FullRequest[] memory _requests = _oracle.listRequests(_startFrom, _amount);

    for (uint256 _i = 0; _i < _requests.length; _i++) {
      IOracle.FullRequest memory _request = _requests[_i];

      bytes32 _requestId = keccak256(abi.encodePacked(_request.requester, address(_oracle), _request.nonce));

      bytes32[] memory _responses = _oracle.getResponseIds(_requestId);

      _returnData[_i] = RequestForFinalizeData({
        requestId: _requestId,
        responses: _responses,
        finalizedAt: _request.finalizedAt
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
