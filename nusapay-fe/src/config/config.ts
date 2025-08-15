
import { http, createConfig } from "wagmi";
import { mainnet, linea, lineaSepolia } from "wagmi/chains";
import { metaMask } from "wagmi/connectors";


export const CONFIG = {
  // Blockchain Configuration
  CHAIN_ID: 4202, // Core Testnet
  CHAIN_NAME: 'Core Testnet',
  
  // Explorer URLs
  EXPLORER_BASE_URL: 'https://scan.test2.btcs.network',
  
  // API Configuration
  API_TIMEOUT: 30000, // 30 seconds
  
  // UI Configuration
  REFRESH_INTERVAL: 30000, // 30 seconds for auto-refresh
  
  // Exchange Rate (Static for now)
  USDC_TO_IDR_RATE: 16400,
} as const

// Helper functions for explorer URLs
export const getExplorerUrl = {
  transaction: (txHash: string) => `${CONFIG.EXPLORER_BASE_URL}/tx/${txHash}`,
  address: (address: string) => `${CONFIG.EXPLORER_BASE_URL}/address/${address}`,
  block: (blockNumber: number) => `${CONFIG.EXPLORER_BASE_URL}/block/${blockNumber}`,
}

export const wagmiConfig = createConfig({
  ssr: true,
  chains: [mainnet, linea, lineaSepolia],
  connectors: [metaMask()],
  transports: {
    [mainnet.id]: http(),
    [linea.id]: http(),
    [lineaSepolia.id]: http(),
  },
});
