// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IOracle.sol';
import {IModule} from '@defi-wonderland/prophet-core-abi/solidity/interfaces/IModule.sol';

/**
 * @title BatchRequestsData contract
 * @notice This contract is used to get batch requests data from the oracle contract
 */
contract BatchRequestsData {
  struct ResponseData {
    bytes32 responseId;
    uint256 createdAt;
    bytes32 disputeId;
  }

  struct RequestData {
    bytes32 requestId;
    ResponseData[] responses;
    bytes32 finalizedResponseId;
    IOracle.DisputeStatus disputeStatus;
  }

  constructor(IOracle _oracle, uint256 _startFrom, uint256 _amount) {
    RequestData[] memory _returnData = new RequestData[](_amount);

    bytes32[] memory _requestsIds = _oracle.listRequestIds(_startFrom, _amount);

    for (uint256 _i = 0; _i < _requestsIds.length; _i++) {
      bytes32 _requestId = _requestsIds[_i];
      bytes32[] memory _responseIds = _oracle.getResponseIds(_requestId);
      ResponseData[] memory _responses = new ResponseData[](_responseIds.length);

      for (uint256 _j = 0; _j < _responseIds.length; _j++) {
        bytes32 _responseId = _responseIds[_j];

        _responses[_j] = ResponseData({
          responseId: _responseId,
          createdAt: _oracle.createdAt(_responseId),
          disputeId: _oracle.disputeOf(_responseId)
        });
      }

      bytes32 _finalizedResponseId = _oracle.getFinalizedResponseId(_requestId);

      IOracle.DisputeStatus _disputeStatus = IOracle.DisputeStatus.None;
      if (_responseIds.length > 0) {
        bytes32 _latestResponseId = _responseIds[_responseIds.length - 1];
        _disputeStatus = _oracle.disputeStatus(_oracle.disputeOf(_latestResponseId));
      }

      _returnData[_i] = RequestData({
        requestId: _requestId,
        responses: _responses,
        finalizedResponseId: _finalizedResponseId,
        disputeStatus: _disputeStatus
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

  function _getModuleName(IModule _module) internal view returns (string memory) {
    return address(_module) == address(0) ? '' : _module.moduleName();
  }
}
