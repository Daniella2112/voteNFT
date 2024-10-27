# Voting NFT Smart Contract

This Clarity smart contract, `vote-nft`, is designed to record votes by minting unique, non-fungible tokens (NFTs) on the Stacks blockchain. Each time a user votes, they receive an NFT representing that vote. The contract tracks the total number of votes cast and maintains a record of the number of NFTs each user has earned. This can be used in scenarios where users are incentivized to participate through NFTs, which can serve as proof of participation.

## Contract Overview

- **Token Name**: `vote-nft`
- **Token Type**: Non-fungible (NFT), indexed by `uint`
- **Data Variables**:
  - `total-votes`: Stores the total number of votes cast.
- **Maps**:
  - `voter-nft-count`: Maps each voter's principal to their total number of vote NFTs earned.

## Functions

### 1. **Voting Function**: `(vote)`

The primary purpose of this function is to register a vote from the caller and mint an NFT as proof of their participation.

- **Parameters**: None
- **Execution Flow**:
  1. **Increment Total Votes**: Adds `1` to the total vote count, stored in `total-votes`.
  2. **Mint NFT**: Assigns a new NFT (with an ID corresponding to the new vote count) to the voter.
  3. **Update Voter's NFT Count**: Updates the voter's total vote NFT count in the `voter-nft-count` map.
- **Return**: `ok` message upon successful vote registration and NFT minting.
- **Errors**: Uses `try!` to handle errors during NFT minting.

### 2. **Get Total Votes**: `(get-total-votes)`

A read-only function that returns the total number of votes cast.

- **Parameters**: None
- **Return**: The current value of `total-votes`, indicating the number of votes cast so far.

### 3. **Get NFT Count**: `(get-nft-count)`

A read-only function to retrieve the number of vote NFTs a specific user has.

- **Parameters**:
  - `voter`: Principal (the address of the voter whose NFT count is to be retrieved).
- **Return**: The count of NFTs the specified voter has.

## Usage

### 1. Voting Process

Users vote by calling the `vote` function. Each time a user votes:
- The contract increments the `total-votes` count by `1`.
- A unique NFT (with the current `total-votes` count as its ID) is minted to the voter.
- The voter's NFT count is updated.

### 2. Retrieving Information

To track voting activity:
- Use `get-total-votes` to see the number of votes cast so far.
- Use `get-nft-count` with a voter's principal to see how many NFTs they hold, representing their total votes.

### Example Calls

**Registering a Vote**:
```clarity
(contract-call? .vote-nft vote)
```

**Retrieving Total Votes**:
```clarity
(contract-call? .vote-nft get-total-votes)
```

**Retrieving a Voter's NFT Count**:
```clarity
(contract-call? .vote-nft get-nft-count <voter-principal>)
```

## Data Structures

### Non-Fungible Token (NFT)

- **`vote-nft`**: A non-fungible token (NFT) indexed by `uint`, representing each vote. Each unique NFT ID corresponds to an individual vote cast in the contract.

### Data Variables

- **`total-votes`** (`uint`): Tracks the total number of votes cast.

### Maps

- **`voter-nft-count`**: A mapping from each voter's principal address to their vote NFT count.

## Error Handling

This contract uses the `try!` function to handle errors in minting NFTs. If the NFT minting fails, the `vote` function will return an error, preventing the transaction from completing.

## License

This contract is released under the MIT License.

