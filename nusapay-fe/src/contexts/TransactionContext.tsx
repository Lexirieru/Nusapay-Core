'use client'

import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react'

interface TransactionContextType {
  pendingTransactions: string[]
  addPendingTransaction: (txHash: string) => void
  removePendingTransaction: (txHash: string) => void
  clearPendingTransactions: () => void
  refreshHistory: () => void
  setRefreshHistoryCallback: (callback: () => void) => void
}

const TransactionContext = createContext<TransactionContextType | undefined>(undefined)

export function TransactionProvider({ children }: { children: ReactNode }) {
  const [pendingTransactions, setPendingTransactions] = useState<string[]>([])
  const [refreshHistoryCallback, setRefreshHistoryCallback] = useState<(() => void) | null>(null)

  const addPendingTransaction = useCallback((txHash: string) => {
    setPendingTransactions(prev => {
      if (!prev.includes(txHash)) {
        return [...prev, txHash]
      }
      return prev
    })
  }, [])

  const removePendingTransaction = useCallback((txHash: string) => {
    setPendingTransactions(prev => prev.filter(hash => hash !== txHash))
  }, [])

  const clearPendingTransactions = useCallback(() => {
    setPendingTransactions([])
  }, [])

  const refreshHistory = useCallback(() => {
    if (refreshHistoryCallback) {
      refreshHistoryCallback()
    }
  }, [refreshHistoryCallback])

  const registerRefreshCallback = useCallback((callback: () => void) => {
    setRefreshHistoryCallback(() => callback)
  }, [])

  return (
    <TransactionContext.Provider
      value={{
        pendingTransactions,
        addPendingTransaction,
        removePendingTransaction,
        clearPendingTransactions,
        refreshHistory,
        setRefreshHistoryCallback: registerRefreshCallback
      }}
    >
      {children}
    </TransactionContext.Provider>
  )
}

export function useTransactionContext() {
  const context = useContext(TransactionContext)
  if (context === undefined) {
    throw new Error('useTransactionContext must be used within a TransactionProvider')
  }
  return context
} 