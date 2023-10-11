# Prophet Batching Contracts

This repository contains Prophet contracts for batching the RPC calls.

If you're unfamiliar with how RPC batching works, please read [this thread](https://twitter.com/libevm/status/1610214982452449280).

## Contracts
- `BatchDisputesData`: returns all disputes of multiple requests
- `BatchRequestsData`: returns requests data combined with responses
- `BatchRequestsForFinalizeData`: returns ids of requests and their finalization status, also includes response ids
- `BatchResponsesData`: returns responses of a given request

## Usage
1. Install the [`@defi-wonderland/prophet-batching-abi`](https://www.npmjs.com/package/@defi-wonderland/prophet-batching-abi) package:
```bash
yarn add @defi-wonderland/prophet-batching-abi
```

2. Import the bytecode and fetch the data. Check [the SDK repo](https://github.com/defi-wonderland/prophet-sdk-private/tree/dev/src/batching) for examples of this.

## Licensing

The primary license for Prophet contracts is MIT, see [`LICENSE`](./LICENSE).

## Contributors

Prophet was built with ❤️ by [Wonderland](https://defi.sucks).

Wonderland is a team of top Web3 researchers, developers, and operators who believe that the future needs to be open-source, permissionless, and decentralized.

[DeFi sucks](https://defi.sucks), but Wonderland is here to make it better.
