'use client'

import { PayrollForm } from '@/components/PayrollForm'
import { useAccount } from 'wagmi'
import Threads from '@/components/Threads'
import { motion, AnimatePresence } from 'framer-motion'
import { useState } from 'react'


export default function PayrollPage() {
  const { isConnected } = useAccount()
  const [isSuccess, setIsSuccess] = useState(false)
  const [successDetails, setSuccessDetails] = useState<any>(null)

  const handleSuccess = (details: any) =>{
    setSuccessDetails(details);
    setIsSuccess(true)
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
              You need to connect your wallet to access the payroll dashboard
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
          
          <PayrollForm onSuccess={handleSuccess} />
        </div>
      </div>
        <AnimatePresence>
          {isSuccess && successDetails && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50"
              onClick={() => setIsSuccess(false)}
            >
              <motion.div
                initial={{ opacity: 0, scale: 0.8, y: 50 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.8, y: 50 }}
                transition={{ duration: 0.5, ease: "easeOut" }}
                className="bg-gray-900 border border-green-500/30 rounded-lg p-6 backdrop-blur-sm max-w-2xl w-full max-h-[90vh] overflow-y-auto"
                onClick={(e) => e.stopPropagation()}
              >
                {/* Close Button */}
                <button
                  onClick={() => setIsSuccess(false)}
                  className="absolute top-4 right-4 text-gray-400 hover:text-white transition-colors"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>

                <motion.div 
                  className="flex items-center mb-6"
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.2, duration: 0.5 }}
                >
                  <motion.div 
                    className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center mr-4"
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ delay: 0.3, type: "spring", stiffness: 200 }}
                  >
                    <motion.svg 
                      className="w-7 h-7 text-white" 
                      fill="none" 
                      stroke="currentColor" 
                      viewBox="0 0 24 24"
                      initial={{ pathLength: 0 }}
                      animate={{ pathLength: 1 }}
                      transition={{ delay: 0.5, duration: 0.5 }}
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </motion.svg>
                  </motion.div>
                  <motion.h3 
                    className="text-2xl font-semibold text-green-400"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.4, duration: 0.5 }}
                  >
                    Payroll Executed Successfully!
                  </motion.h3>
                </motion.div>
              
                <motion.div 
                  className="space-y-6"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.6, duration: 0.5 }}
                >
                  <motion.div 
                    className="grid grid-cols-1 md:grid-cols-2 gap-4"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.7, duration: 0.5 }}
                  >
                    <motion.div
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.8, duration: 0.3 }}
                      className="bg-gray-800/50 rounded-lg p-4"
                    >
                      <p className="text-sm text-green-300 mb-1">Transaction Hash</p>
                      <p className="text-white font-mono text-sm break-all">{successDetails.transactionHash}</p>
                    </motion.div>
                    <motion.div
                      initial={{ opacity: 0, x: 20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.9, duration: 0.3 }}
                      className="bg-gray-800/50 rounded-lg p-4"
                    >
                      <p className="text-sm text-green-300 mb-1">Total Amount</p>
                      <p className="text-white font-semibold text-lg">{successDetails.totalAmount} USDC</p>
                    </motion.div>
                    <motion.div
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 1.0, duration: 0.3 }}
                      className="bg-gray-800/50 rounded-lg p-4"
                    >
                      <p className="text-sm text-green-300 mb-1">Employee Count</p>
                      <p className="text-white font-semibold text-lg">{successDetails.employeeCount} employees</p>
                    </motion.div>
                    <motion.div
                      initial={{ opacity: 0, x: 20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 1.1, duration: 0.3 }}
                      className="bg-gray-800/50 rounded-lg p-4"
                    >
                      <p className="text-sm text-green-300 mb-1">Timestamp</p>
                      <p className="text-white">{successDetails.timestamp}</p>
                    </motion.div>
                  </motion.div>

                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 1.2, duration: 0.5 }}
                  >
                    <motion.h4 
                      className="text-green-300 font-semibold mb-3 text-lg"
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: 1.3, duration: 0.3 }}
                    >
                      Employee Details:
                    </motion.h4>
                    <div className="space-y-3 max-h-64 overflow-y-auto">
                      {successDetails.employees.map((emp: any, index: number) => (
                        <motion.div 
                          key={index} 
                          className="bg-gray-800/70 rounded-lg p-4 border border-gray-700/50"
                          initial={{ opacity: 0, x: -20, scale: 0.95 }}
                          animate={{ opacity: 1, x: 0, scale: 1 }}
                          transition={{ 
                            delay: 1.4 + (index * 0.1), 
                            duration: 0.4,
                            type: "spring",
                            stiffness: 100
                          }}
                          whileHover={{ scale: 1.02 }}
                        >
                          <div className="flex justify-between items-start">
                            <div>
                              <p className="text-white font-medium text-lg">{emp.name}</p>
                              <p className="text-gray-300 text-sm font-mono">{emp.address}</p>
                              <p className="text-cyan-300 text-sm">{emp.bank}</p>
                            </div>
                            <div className="text-right">
                              <p className="text-white font-semibold text-lg">{emp.usdcAmount} USDC</p>
                              <p className="text-gray-300">{emp.fiatAmount} {emp.currency}</p>
                            </div>
                          </div>
                        </motion.div>
                      ))}
                    </div>
                  </motion.div>

                  {/* Action Buttons */}
                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 1.5, duration: 0.5 }}
                    className="flex justify-end space-x-3 pt-4 border-t border-gray-700/50"
                  >
                    <button
                      onClick={() => setIsSuccess(false)}
                      className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-semibold"
                    >
                      Close
                    </button>
                  </motion.div>
                </motion.div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
    </div>
  )
}