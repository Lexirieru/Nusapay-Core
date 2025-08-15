'use client'

import { useTransactionContext } from '@/contexts/TransactionContext'
import { motion, AnimatePresence } from 'framer-motion'
import { useState, useEffect } from 'react'

export function TransactionNotification() {
  const { pendingTransactions } = useTransactionContext()
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    if (pendingTransactions.length > 0) {
      setIsVisible(true)
    } else {
      setIsVisible(false)
    }
  }, [pendingTransactions])

  if (pendingTransactions.length === 0) return null

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ opacity: 0, y: -50 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -50 }}
          className="fixed top-4 right-4 z-50"
        >
          <div className="bg-yellow-900/90 border border-yellow-500/50 rounded-lg p-4 backdrop-blur-sm shadow-lg">
            <div className="flex items-center space-x-3">
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                className="w-4 h-4 border-2 border-yellow-400 border-t-transparent rounded-full"
              />
              <div>
                <h4 className="text-yellow-300 font-semibold text-sm">
                  Processing Transactions
                </h4>
                <p className="text-yellow-200 text-xs">
                  {pendingTransactions.length} transaction{pendingTransactions.length > 1 ? 's' : ''} pending
                </p>
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
} 