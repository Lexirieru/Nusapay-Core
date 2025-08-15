'use client'

import { PayrollForm } from '@/components/PayrollForm'
import { useAccount } from 'wagmi'
import Threads from '@/components/Threads'

export default function PayrollPage() {
  const { isConnected } = useAccount()

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
          <div className="text-center bg-gray-800/20 border-y-1 border-cyan-300 backdrop-blur-sm p-8 rounded-lg">
            <h2 className="text-2xl font-semibold text-white mb-4">
              Please connect your wallet first
            </h2>
            <p className="text-cyan-400">
              You need to connect your wallet to access the history dashboard
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
        <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8 pt-32">
          <div className="mb-6">
            <h1 className="text-3xl font-bold text-white">Payroll Dashboard</h1>
            <p className="text-cyan-400 mt-2">
              Execute cross-chain payroll payments to your employees
            </p>
          </div>
          
          <PayrollForm />
        </div>
      </div>
    </div>
  )
} 