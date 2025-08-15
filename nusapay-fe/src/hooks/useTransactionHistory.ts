import { useState, useEffect, useCallback } from 'react'
import { useAccount } from 'wagmi'
import { transactionService, TransactionHistory } from '@/api/transactionService'
import { useTransactionContext } from '@/contexts/TransactionContext'

export function useTransactionHistory() {
  const { address, isConnected } = useAccount()
  const { setRefreshHistoryCallback } = useTransactionContext()
  const [transactions, setTransactions] = useState<TransactionHistory[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null)

  const fetchTransactionHistory = useCallback(async (fromBlock?: number) => {
    if (!isConnected || !address) {
      setTransactions([])
      return
    }

    setLoading(true)
    setError(null)

    try {
      const history = await transactionService.getTransactionHistory(address, fromBlock)
      setTransactions(history)
      setLastUpdated(new Date())
    } catch (err) {
      console.error('Error fetching transaction history:', err)
      setError(err instanceof Error ? err.message : 'Failed to fetch transaction history')
    } finally {
      setLoading(false)
    }
  }, [isConnected, address])

  const refreshHistory = useCallback(() => {
    fetchTransactionHistory()
  }, [fetchTransactionHistory])

  const getTransactionByHash = useCallback(async (txHash: string): Promise<TransactionHistory | null> => {
    try {
      return await transactionService.getTransactionByHash(txHash)
    } catch (err) {
      console.error('Error fetching transaction by hash:', err)
      return null
    }
  }, [])

  const getTransactionStatus = useCallback(async (txHash: string): Promise<'PENDING' | 'SUCCESS' | 'FAILED'> => {
    try {
      return await transactionService.getTransactionStatus(txHash)
    } catch (err) {
      console.error('Error getting transaction status:', err)
      return 'PENDING'
    }
  }, [])

  // Auto-refresh transaction status for pending transactions
  const refreshPendingTransactions = useCallback(async () => {
    const pendingTransactions = transactions.filter(tx => tx.status === 'PENDING')
    
    if (pendingTransactions.length === 0) return

    const updatedTransactions = [...transactions]
    let hasUpdates = false

    for (const tx of pendingTransactions) {
      const status = await getTransactionStatus(tx.txHash)
      if (status !== 'PENDING') {
        const index = updatedTransactions.findIndex(t => t.txHash === tx.txHash)
        if (index !== -1) {
          updatedTransactions[index] = { ...updatedTransactions[index], status }
          hasUpdates = true
        }
      }
    }

    if (hasUpdates) {
      setTransactions(updatedTransactions)
      setLastUpdated(new Date())
    }
  }, [transactions, getTransactionStatus])

  // Register refresh callback with context
  useEffect(() => {
    setRefreshHistoryCallback(() => refreshHistory)
  }, [refreshHistory, setRefreshHistoryCallback])

  // Initial fetch
  useEffect(() => {
    fetchTransactionHistory()
  }, [fetchTransactionHistory])

  // Auto-refresh pending transactions every 30 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      refreshPendingTransactions()
    }, 30000)

    return () => clearInterval(interval)
  }, [refreshPendingTransactions])

  // Format transaction data for display
  const formatTransactionForDisplay = useCallback((tx: TransactionHistory) => {
    return {
      txId: tx.payrollId.slice(0, 8) + '...',
      employee: tx.employees.length > 0 ? `${tx.employees.length} employees` : 'No employees',
      companyName: 'NusaPay System',
      templateName: 'Batch Payroll',
      amountTransfer: tx.totalCryptoAmount,
      currency: 'USDC',
      localCurrency: tx.currencies.length > 0 ? tx.currencies[0] : 'IDR',
      status: tx.status,
      createdAt: new Date(tx.timestamp * 1000).toISOString(),
      bankAccountName: 'Batch Transfer',
      bankAccount: `${tx.totalRecipients} accounts`,
      txHash: tx.txHash,
      blockNumber: tx.blockNumber,
      gasUsed: tx.gasUsed,
      gasPrice: tx.gasPrice,
      // Additional details for expanded view
      employees: tx.employees,
      cryptoAmounts: tx.cryptoAmounts,
      fiatAmounts: tx.fiatAmounts,
      currencies: tx.currencies,
      bankAccounts: tx.bankAccounts
    }
  }, [])

  const formattedTransactions = transactions.map(formatTransactionForDisplay)

  return {
    transactions: formattedTransactions,
    rawTransactions: transactions,
    loading,
    error,
    lastUpdated,
    refreshHistory,
    getTransactionByHash,
    getTransactionStatus,
    refreshPendingTransactions
  }
} 