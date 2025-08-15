'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { transactionService } from '@/api/transactionService'

export function RpcStatusIndicator() {
  const [isHealthy, setIsHealthy] = useState<boolean | null>(null)
  const [isChecking, setIsChecking] = useState(false)

  const checkRpcHealth = async () => {
    setIsChecking(true)
    try {
      const health = await transactionService.checkRpcHealth()
      setIsHealthy(health)
    } catch (error) {
      console.error('RPC health check failed:', error)
      setIsHealthy(false)
    } finally {
      setIsChecking(false)
    }
  }

  useEffect(() => {
    checkRpcHealth()
    
    // Check every 30 seconds
    const interval = setInterval(checkRpcHealth, 30000)
    return () => clearInterval(interval)
  }, [])

  if (isHealthy === null) return null

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -20 }}
        className="fixed top-4 left-4 z-40"
      >
        <div className={`px-3 py-2 rounded-lg backdrop-blur-sm border text-sm font-medium flex items-center space-x-2 ${
          isHealthy 
            ? 'bg-green-900/30 border-green-500/30 text-green-400' 
            : 'bg-red-900/30 border-red-500/30 text-red-400'
        }`}>
          <motion.div
            animate={{ 
              scale: isChecking ? [1, 1.2, 1] : 1,
              rotate: isChecking ? 360 : 0
            }}
            transition={{ 
              duration: isChecking ? 1 : 0,
              repeat: isChecking ? Infinity : 0
            }}
            className={`w-2 h-2 rounded-full ${
              isHealthy ? 'bg-green-400' : 'bg-red-400'
            }`}
          />
          <span>
            {isChecking ? 'Checking...' : isHealthy ? 'RPC Connected' : 'RPC Issues'}
          </span>
          {!isHealthy && (
            <button
              onClick={checkRpcHealth}
              className="text-xs underline hover:no-underline"
              title="Retry connection"
            >
              Retry
            </button>
          )}
        </div>
      </motion.div>
    </AnimatePresence>
  )
} 