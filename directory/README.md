# Stacks FT Standard

A reference implementation of the SIP-010 fungible-token standard in Clarity.

## Prerequisites

- Node.js >= 14
- npm
- Clarinet (`npm install -g @hirosystems/clarinet`)

## Project Layout

- `contracts/`: Clarity smart contracts
- `tests/`: Clarinet integration tests
- `Clarinet.toml`: network and accounts config

## Getting Started

```bash
# Clone repo
git clone <repo-url> && cd stacks-ft-standard

# Install dependencies
npm install

# Run tests
clarinet test
