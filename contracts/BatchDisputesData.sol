// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IOracle.sol';

/**
 * @title BatchDisputeData contract
 * @notice This contract retrieves the disputes for a range of requests
 */
contract BatchDisputesData {
  struct DisputeWithId {
    bytes32 disputeId;
    bytes32 responseId;
    uint256 disputeCreatedAt;
    uint256 responseCreatedAt;
    IOracle.DisputeStatus status;
  }

  struct DisputeData {
    bytes32 requestId;
    uint256 requestCreatedAt;
    bool isFinalized;
    DisputeWithId[] disputes;
  }

  constructor(IOracle _oracle, uint256 _startFrom, uint256 _amount) {
    DisputeData[] memory _returnData = new DisputeData[](_amount);

    bytes32[] memory _requestsIds = _oracle.listRequestIds(_startFrom, _amount);

    for (uint256 _i = 0; _i < _requestsIds.length; _i++) {
      bytes32 _requestId = _requestsIds[_i];
      bytes32[] memory _responseIds = _oracle.getResponseIds(_requestsIds[_i]);

      DisputeWithId[] memory _disputes = new DisputeWithId[](_responseIds.length);

      for (uint256 _j = 0; _j < _responseIds.length; _j++) {
        bytes32 _responseId = _responseIds[_j];
        bytes32 _disputeId = _oracle.disputeOf(_responseId);
        _disputes[_j] = DisputeWithId({
          disputeId: _disputeId,
          responseId: _responseId,
          disputeCreatedAt: _oracle.createdAt(_disputeId),
          responseCreatedAt: _oracle.createdAt(_responseId),
          status: _oracle.disputeStatus(_disputeId)
        });
      }

      _returnData[_i].requestId = _requestId;
      _returnData[_i].requestCreatedAt = _oracle.createdAt(_requestId);
      _returnData[_i].isFinalized = _oracle.finalizedAt(_requestId) != 0;
      _returnData[_i].disputes = _disputes;
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
