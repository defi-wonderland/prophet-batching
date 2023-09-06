// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IOracle} from 'prophet-core-abi/contracts/IOracle.sol';
import {IModule} from 'prophet-core-abi/contracts/IModule.sol';

/**
  * @title BatchRequestsData contract
  * @notice This contract is used to get batch requests data from the oracle contract
  */
contract BatchRequestsData {

  struct ResponseWithId {
    bytes32 responseId;
    uint256 createdAt;
    address proposer;
    bytes32 requestId;
    bytes32 disputeId;
    bytes response;
  }
  
  struct RequestData {
    bytes32 _requestId;
    IOracle.FullRequest _request;
    ResponseWithId[] _responses;
    IOracle.Response _finalizedResponse;
    IOracle.DisputeStatus _disputeStatus;
    string requestModuleName;
    string responseModuleName;
    string disputeModuleName;
    string resolutionModuleName;
    string finalityModuleName;
  }

  constructor(IOracle _oracle, uint256 _startFrom, uint256 _amount) {
    RequestData[] memory _returnData = new RequestData[](_amount);

    IOracle.FullRequest[] memory _requests = _oracle.listRequests(_startFrom, _amount);

    for (uint256 _i = 0; _i < _requests.length; _i++) {
      IOracle.FullRequest memory _request = _requests[_i];

      bytes32 _requestId = keccak256(abi.encodePacked(_request.requester, address(_oracle), _request.nonce));

      bytes32[] memory _responseIds = _oracle.getResponseIds(_requestId);
      ResponseWithId[] memory _responses = new ResponseWithId[](_responseIds.length);

      for (uint256 _j = 0; _j < _responseIds.length; _j++) {
        IOracle.Response memory _response = _oracle.getResponse(_responseIds[_j]);

        _responses[_j] = ResponseWithId ({ 
          responseId: _responseIds[_j],
          createdAt: _response.createdAt,
          proposer: _response.proposer,
          requestId: _response.requestId,
          disputeId: _response.disputeId,
          response: _response.response 
        });
      }

      IOracle.Response memory _finalizedResponse = _oracle.getFinalizedResponse(_requestId);

      IOracle.DisputeStatus _disputeStatus = IOracle.DisputeStatus.None;
      if (_responseIds.length > 0) {
        bytes32 _latestResponseId = _responseIds[_responseIds.length - 1];
        _disputeStatus = _oracle.getDispute(_oracle.disputeOf(_latestResponseId)).status;
      }

      _returnData[_i] = RequestData({
        _requestId: _requestId,
        _request: _request,
        _responses: _responses,
        _finalizedResponse: _finalizedResponse,
        _disputeStatus: _disputeStatus,
        requestModuleName: _getModuleName(_request.requestModule),
        responseModuleName: _getModuleName(_request.responseModule),
        disputeModuleName: _getModuleName(_request.disputeModule),
        resolutionModuleName: _getModuleName(_request.resolutionModule),
        finalityModuleName: _getModuleName(_request.finalityModule)
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
