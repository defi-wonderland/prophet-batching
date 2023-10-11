// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from '@defi-wonderland/prophet-core-abi/contracts/IOracle.sol';
import {IModule} from '@defi-wonderland/prophet-core-abi/contracts/IModule.sol';

/**
 * @title BatchDisputeData contract
 * @notice This contract retrieves the disputes for a range of requests
 */
contract BatchDisputesData {
  struct DisputeWithId {
    bytes32 disputeId;
    uint256 createdAt;
    address disputer;
    address proposer;
    bytes32 responseId;
    bytes32 requestId;
    IOracle.DisputeStatus status;
  }

  struct DisputesData {
    bytes32 requestId;
    bool isFinalized;
    DisputeWithId[] disputes;
  }

  constructor(IOracle _oracle, uint256 _startFrom, uint256 _amount) {
    DisputesData[] memory _returnData = new DisputesData[](_amount);

    bytes32[] memory _requestsIds = _oracle.listRequestIds(_startFrom, _amount);

    for (uint256 _i = 0; _i < _requestsIds.length; _i++) {
      IOracle.Request memory _request = _oracle.getRequest(_requestsIds[_i]);
      _returnData[_i].requestId = _requestsIds[_i];
      _returnData[_i].isFinalized = _request.finalizedAt != 0;
      bytes32[] memory _responseIds = _oracle.getResponseIds(_requestsIds[_i]);

      DisputeWithId[] memory _disputes = new DisputeWithId[](_responseIds.length);

      for (uint256 _j = 0; _j < _responseIds.length; _j++) {
        IOracle.Dispute memory _dispute;
        bytes32 _disputeId = _oracle.disputeOf(_responseIds[_j]);
        _dispute = _oracle.getDispute(_disputeId);
        _disputes[_j] = DisputeWithId({
          disputeId: _disputeId,
          createdAt: _dispute.createdAt,
          disputer: _dispute.disputer,
          proposer: _dispute.proposer,
          responseId: _dispute.responseId,
          requestId: _dispute.requestId,
          status: _dispute.status
        });
      }

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
