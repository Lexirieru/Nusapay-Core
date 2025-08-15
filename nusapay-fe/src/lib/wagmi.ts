import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { mainnet, sepolia } from 'wagmi/chains'

// Custom chains untuk Core Testnet dan Base Sepolia
const coreTestnet = {
  id: 1114,
  name: 'Core Testnet',
  network: 'core-testnet',
  nativeCurrency: { 
    name: 'CORE', 
    symbol: 'CORE', 
    decimals: 18 
  },
  rpcUrls: { 
    default: { 
      http: ['https://rpc.test2.btcs.network'] 
    },
    public: { 
      http: ['https://rpc.test2.btcs.network'] 
    }
  },
  blockExplorers: {
    default: { 
      name: 'Core Testnet Explorer', 
      url: 'https://scan.test2.btcs.network' 
    }
  }
} as const

const baseSepolia = {
  id: 84532,
  name: 'Base Sepolia',
  network: 'base-sepolia',
  nativeCurrency: { 
    name: 'ETH', 
    symbol: 'ETH', 
    decimals: 18 
  },
  rpcUrls: { 
    default: { 
      http: ['https://sepolia.base.org'] 
    },
    public: { 
      http: ['https://sepolia.base.org'] 
    }
  },
  blockExplorers: {
    default: { 
      name: 'Base Sepolia Explorer', 
      url: 'https://sepolia.basescan.org' 
    }
  }
} as const

export const config = getDefaultConfig({
  appName: 'NusaPay',
  projectId: 'YOUR_WALLETCONNECT_PROJECT_ID', // Dapatkan dari https://cloud.walletconnect.com/
  chains: [coreTestnet, baseSepolia],
  ssr: true
}) 