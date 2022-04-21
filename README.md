# Proof of Integrity Pool

## Setup

1. Clone Repository

   ```sh
   $ git clone https://github.com/BEON-Tech-Studio/poi-pool.git
   $ cd poi-pool
   ```

2. Install Dependencies

   ```sh
   $ npm install
   ```

3. Run Tests

   ```sh
   $ npx hardhat test
   ```

   To compute their code coverage run `npx hardhat coverage`.

## Deploy

1. On `hardhat.config.js` configure the following constants for the `kovan` testnet:

   ```
   INFURA_API_KEY
   KOVAN_PRIVATE_KEY
   ```

2. Deploy on Ethereum `kovan` testnet:

   ```sh
   $ npx hardhat run scripts/deploy.js --network kovan
   ```

3. Interact with the console:

   ```sh
   $ npx hardhat console --network kovan
   ```

## License

MIT
