# Enhanced Stacks Fungible Token with Governance

A comprehensive fungible token implementation on the Stacks blockchain with built-in governance functionality.

## Overview

This project implements a secure, feature-rich fungible token contract along with a governance system that allows token holders to participate in decentralized decision-making.

## Features

### Fungible Token Contract (`fungible-token.clar`)

#### Phase 1 Features
- Basic ERC-20 style functionality (transfer, approve, transfer-from)
- Token metadata (name, symbol, decimals)
- Balance and allowance tracking

#### Phase 2 Enhancements
- **Bug Fixes**: 
  - Fixed map declarations and data structure issues
  - Corrected initialization logic
  - Improved error handling with proper constants

- **Security Enhancements**:
  - Input validation for all functions
  - Authorization checks for admin functions
  - Prevention of self-transfers
  - Overflow protection
  - Event logging for transfer tracking

- **New Functionality**:
  - Mint function (owner only)
  - Burn function (token holder only)
  - Ownership transfer
  - Enhanced metadata retrieval
  - Transfer event logging
  - Total supply tracking

### Governance Contract (`governance.clar`)

A comprehensive DAO governance system that enables:

- **Proposal Creation**: Token holders with minimum threshold can create proposals
- **Voting System**: Weighted voting based on token holdings
- **Quorum Requirements**: Configurable quorum thresholds for proposal validity
- **Execution**: Automatic execution of passed proposals
- **Time-based Voting**: Configurable voting periods with delays

#### Governance Features
- Minimum proposal threshold: 1,000 tokens
- Configurable voting duration (24 hours to 7 days)
- Quorum requirement (default 10% of total supply)
- Anti-double voting protection
- Vote weight based on token balance
- Proposal status tracking

## Contract Architecture

```
┌─────────────────────┐    ┌─────────────────────┐
│  Fungible Token     │◄───│    Governance       │
│                     │    │                     │
│ • Transfer          │    │ • Create Proposals  │
│ • Approve           │    │ • Vote              │
│ • Mint/Burn         │    │ • Execute           │
│ • Events            │    │ • Admin Functions   │
└─────────────────────┘    └─────────────────────┘
```

## Security Measures

1. **Access Control**: Owner-only functions for critical operations
2. **Input Validation**: All inputs are validated before processing
3. **Reentrancy Protection**: State changes before external calls
4. **Integer Overflow Protection**: Checked arithmetic operations
5. **Event Logging**: Comprehensive event system for transparency
6. **Error Handling**: Descriptive error codes and messages

## Usage

### Deploying the Contracts

```bash
# Start local devnet
clarinet integrate

# Deploy contracts
clarinet deploy --devnet
```

### Basic Token Operations

```clarity
;; Initialize the token (owner only)
(contract-call? .fungible-token initialize 'SP1234... u1000000)

;; Transfer tokens
(contract-call? .fungible-token transfer 'SP5678... u1000)

;; Approve spending
(contract-call? .fungible-token approve 'SP9ABC... u500)

;; Check balance
(contract-call? .fungible-token get-balance 'SP1234...)
```

### Governance Operations

```clarity
;; Create a proposal (requires minimum tokens)
(contract-call? .governance create-proposal 
  "Increase token supply"
  "Proposal to mint additional 100,000 tokens for development"
  u1008) ;; 7 days voting period

;; Vote on proposal
(contract-call? .governance vote u1 true u5000) ;; Vote YES with 5000 tokens

;; Execute passed proposal
(contract-call? .governance execute-proposal u1)
```

## Testing

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/fungible-token_test.ts

# Check contract syntax
clarinet check
```

## Error Codes

### Fungible Token Errors
- `u100`: Not authorized
- `u101`: Insufficient balance
- `u102`: Insufficient allowance
- `u103`: Already initialized
- `u104`: Invalid amount
- `u105`: Same sender and recipient

### Governance Errors
- `u200`: Not authorized
- `u201`: Proposal not found
- `u202`: Voting period ended
- `u203`: Voting period not ended
- `u204`: Already voted
- `u205`: Insufficient balance
- `u206`: Invalid duration

## Configuration

### Token Configuration
- **Name**: MyToken
- **Symbol**: MTK
- **Decimals**: 6
- **Total Supply**: 1,000,000 tokens

### Governance Configuration
- **Min Proposal Threshold**: 1,000 tokens
- **Min Voting Duration**: 144 blocks (~24 hours)
- **Max Voting Duration**: 1,008 blocks (~7 days)
- **Default Quorum**: 10% of total supply
- **Voting Delay**: 10 blocks

## Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks CLI](https://github.com/blockstack/stacks-blockchain/releases)

### Project Structure
```
├── contracts/
│   ├── fungible-token.clar    # Main token contract
│   └── governance.clar        # Governance contract
├── tests/
│   ├── fungible-token_test.ts
│   └── governance_test.ts
├── Clarinet.toml             # Project configuration
└── README.md                 # This file
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## Roadmap

- [ ] Add more governance proposal types
- [ ] Implement time-locked transfers
- [ ] Add pausable functionality
- [ ] Create web interface for governance
- [ ] Add snapshot voting integration
- [ ] Implement vesting schedules

## License

MIT License - see LICENSE file for details.

## Security Considerations

- Always test thoroughly on devnet/testnet before mainnet deployment
- Consider getting a security audit for production use
- Monitor governance proposals carefully
- Implement multi-sig for critical operations


