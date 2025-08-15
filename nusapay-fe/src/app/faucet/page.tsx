'use client'

import { useState } from 'react'
import { useAccount } from 'wagmi'
import { useUSDC } from '@/hooks/useUSDC'
import Threads from '@/components/Threads'

export default function FaucetPage() {
  const { address, isConnected } = useAccount()
  const { balance, mintUSDC, isMinting } = useUSDC()
  const [amount, setAmount] = useState('1000')

  const handleMintUSDC = async () => {
    if (!address || !amount) return
    const mintAmount = parseFloat(amount) * 1e6 // Convert to USDC decimals
    await mintUSDC({ args: [address, BigInt(mintAmount)] })
  }

  if (!isConnected) {
    return (
      <div className="relative min-h-screen overflow-hidden">
        {/* Threads Background */}
        <div className="fixed inset-0 z-0">
          <Threads
            color={[0.04, 0.33, 0.39]} // Cyan color matching the theme
            amplitude={1}
            distance={0}
            enableMouseInteraction={true}
          />
        </div>
        
        <div className="relative z-10 min-h-screen flex items-center justify-center">
          <div className="text-center bg-black/50 backdrop-blur-sm p-8 rounded-lg">
            <h2 className="text-2xl font-semibold text-white mb-4">
              Please connect your wallet first
            </h2>
            <p className="text-cyan-400">
              You need to connect your wallet to access the USDC faucet
            </p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="relative min-h-screen overflow-hidden">
      {/* Threads Background */}
      <div className="fixed inset-0 z-0">
        <Threads
          color={[0.04, 0.33, 0.39]} // Cyan color matching the theme
          amplitude={1}
          distance={0}
          enableMouseInteraction={true}
        />
      </div>
      
      <div className="relative z-10 min-h-screen">
        <div className="max-w-4xl mx-auto py-6 sm:px-6 lg:px-8 pt-32">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-white mb-2">USDC Faucet</h1>
            <p className="text-cyan-400">
              Get test USDC tokens for testing the payroll system
            </p>
          </div>
          
          <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg p-6 backdrop-blur-sm">
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-white mb-4">Current Balance</h3>
              <div className="bg-gray-800/50 rounded-lg p-4">
                <p className="text-cyan-300 text-sm">USDC Balance</p>
                <p className="text-2xl font-bold text-white">
                  {balance ? (Number(balance) / 1e6).toFixed(2) : '0'} USDC
                </p>
              </div>
            </div>

            <div className="mb-6">
              <h3 className="text-lg font-semibold text-white mb-4">Mint USDC</h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-cyan-300 mb-1">
                    Amount to Mint (USDC)
                  </label>
                  <input
                    type="number"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    placeholder="1000"
                    min="1"
                    step="1"
                    className="w-full px-3 py-2 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-gray-800/50 text-white placeholder-gray-400"
                  />
                  <p className="text-xs text-cyan-300/70 mt-1">
                    Enter the amount of USDC you want to mint
                  </p>
                </div>

                <button
                  onClick={handleMintUSDC}
                  disabled={isMinting || !amount || parseFloat(amount) <= 0}
                  className="w-full px-6 py-3 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 disabled:opacity-50 font-semibold transition-colors"
                >
                  {isMinting ? 'Minting USDC...' : `Mint ${amount} USDC`}
                </button>
              </div>
            </div>

            <div className="bg-cyan-900/30 border border-cyan-500/30 rounded-lg p-4">
              <h4 className="text-cyan-300 font-semibold mb-2">How it works:</h4>
              <ul className="text-cyan-200 text-sm space-y-1">
                <li>• Enter the amount of USDC you want to mint</li>
                <li>• Click "Mint USDC" to receive test tokens</li>
                <li>• Use these tokens to test the payroll system</li>
                <li>• Tokens are only for testing purposes</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
} 