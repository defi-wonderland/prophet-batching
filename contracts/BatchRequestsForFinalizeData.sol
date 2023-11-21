// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IOracle.sol';
import {IModule} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IModule.sol';

/**
 * @title BatchRequestsForFinalizeData contract
 * @notice This contract is used to get batch requests min data from the oracle contract to finalize the requests
 */
contract BatchRequestsForFinalizeData {
  struct RequestForFinalizeData {
    bytes32 requestId;
    uint256 finalizedAt;
    bytes32[] responseIds;
  }

  constructor(IOracle _oracle, uint256 _startFrom, uint256 _amount) {
    RequestForFinalizeData[] memory _returnData = new RequestForFinalizeData[](_amount);

    bytes32[] memory _requestsIds = _oracle.listRequestIds(_startFrom, _amount);

    for (uint256 _i = 0; _i < _requestsIds.length; _i++) {
      bytes32 _requestId = _requestsIds[_i];

      bytes32[] memory _responses = _oracle.getResponseIds(_requestId);

      _returnData[_i] = RequestForFinalizeData({requestId: _requestId, finalizedAt: _oracle.finalizedAt(_requestId), responseIds: _responses});
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
