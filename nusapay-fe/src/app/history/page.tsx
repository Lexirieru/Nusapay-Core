'use client'

import { useAccount } from 'wagmi'
import Threads from '@/components/Threads'
import { useTransactionHistory } from '@/hooks/useTransactionHistory'
import { TransactionDetails } from '@/components/TransactionDetails'
import { EmployeeDetailsPopup } from '@/components/EmployeeDetailsPopup'
import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'

export default function PayrollHistoryPage() {
  const { isConnected } = useAccount()
  const { 
    transactions, 
    loading, 
    error, 
    lastUpdated, 
    refreshHistory 
  } = useTransactionHistory()
  
  const [expandedRows, setExpandedRows] = useState<Set<string>>(new Set())
  const [selectedTransaction, setSelectedTransaction] = useState<any>(null)
  const [isPopupOpen, setIsPopupOpen] = useState(false)

  const toggleRowExpansion = (txHash: string) => {
    const newExpanded = new Set(expandedRows)
    if (newExpanded.has(txHash)) {
      newExpanded.delete(txHash)
    } else {
      newExpanded.add(txHash)
    }
    setExpandedRows(newExpanded)
  }

  const openEmployeePopup = (transaction: any) => {
    setSelectedTransaction(transaction)
    setIsPopupOpen(true)
  }

  const closeEmployeePopup = () => {
    setIsPopupOpen(false)
    setSelectedTransaction(null)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'SUCCESS':
        return 'bg-green-600/30 text-green-400'
      case 'PENDING':
        return 'bg-yellow-600/30 text-yellow-400'
      case 'FAILED':
        return 'bg-red-600/30 text-red-400'
      default:
        return 'bg-gray-600/30 text-gray-400'
    }
  }

  const formatAddress = (address: string) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`
  }

  const isRpcError = error?.includes('SSL handshake failed') || 
                    error?.includes('HTTP request failed') ||
                    error?.includes('525') ||
                    error?.includes('rpc.test2.btcs.network')

  if (!isConnected) {
    return (
      <div className="relative min-h-screen overflow-hidden">
        <div className="fixed inset-0 z-0">
          <Threads color={[0.04, 0.33, 0.39]} amplitude={1} distance={0} enableMouseInteraction={true} />
        </div>
        <div className="relative z-10 min-h-screen flex items-center justify-center">
          <div className="text-center bg-gray-800/20 border-y-1 border-cyan-300 backdrop-blur-sm p-8 rounded-lg">
            <h2 className="text-2xl font-semibold text-white mb-4">
              Please connect your wallet first
            </h2>
            <p className="text-cyan-400">You need to connect your wallet to view payroll history</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="relative min-h-screen overflow-hidden">
      <div className="fixed inset-0 z-0">
        <Threads color={[0.04, 0.33, 0.39]} amplitude={1} distance={0} enableMouseInteraction={true} />
      </div>
      <div className="relative z-10 min-h-screen">
        <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8 pt-32">
          <div className="mb-6">
            <div className="flex justify-between items-center">
              <div>
                <h1 className="text-3xl font-bold text-white">Payroll History</h1>
                <p className="text-cyan-400 mt-2">View all past payroll transactions</p>
                {lastUpdated && (
                  <p className="text-sm text-gray-400 mt-1">
                    Last updated: {lastUpdated.toLocaleString()}
                  </p>
                )}
              </div>
              <button
                onClick={refreshHistory}
                disabled={loading}
                className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 disabled:opacity-50 transition-colors flex items-center space-x-2"
              >
                {loading ? (
                  <>
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                      className="w-4 h-4 border-2 border-white border-t-transparent rounded-full"
                    />
                    <span>Loading...</span>
                  </>
                ) : (
                  <>
                    <span>🔄</span>
                    <span>Refresh</span>
                  </>
                )}
              </button>
            </div>
          </div>

          {/* RPC Error Message */}
          {isRpcError && (
            <div className="mb-6 bg-yellow-900/30 border border-yellow-500/30 rounded-lg p-4 backdrop-blur-sm">
              <div className="flex items-start space-x-3">
                <div className="text-yellow-400 text-xl">⚠️</div>
                <div className="flex-1">
                  <h3 className="text-yellow-300 font-semibold mb-2">Network Connection Issue</h3>
                  <p className="text-yellow-200 text-sm mb-3">
                    We're experiencing temporary issues connecting to the blockchain network. 
                    This is likely due to server maintenance or network congestion.
                  </p>
                  <div className="text-yellow-200 text-sm space-y-1">
                    <p>• Your transaction history may not be fully up to date</p>
                    <p>• Recent transactions might show as "PENDING"</p>
                    <p>• Please try refreshing in a few minutes</p>
                  </div>
                  <button
                    onClick={refreshHistory}
                    className="mt-3 text-yellow-300 hover:text-yellow-200 underline text-sm"
                  >
                    Try refreshing now
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Other Errors */}
          {error && !isRpcError && (
            <div className="mb-6 bg-red-900/30 border border-red-500/30 rounded-lg p-4 backdrop-blur-sm">
              <p className="text-red-400">Error: {error}</p>
              <button
                onClick={refreshHistory}
                className="mt-2 text-red-300 hover:text-red-200 underline"
              >
                Try again
              </button>
            </div>
          )}

          <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg overflow-hidden backdrop-blur-sm">
            {loading && transactions.length === 0 ? (
              <div className="p-8 text-center">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  className="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full mx-auto mb-4"
                />
                <p className="text-cyan-300">Loading transaction history...</p>
                {isRpcError && (
                  <p className="text-yellow-400 text-sm mt-2">
                    Network connection may be slow due to server issues
                  </p>
                )}
              </div>
            ) : transactions.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="w-full text-sm text-gray-300">
                  <thead className="bg-gray-800/50">
                    <tr>
                      <th className="px-4 py-3 text-left">Date</th>
                      <th className="px-4 py-3 text-left">Company</th>
                      <th className="px-4 py-3 text-left">Employees</th>
                      <th className="px-4 py-3 text-left">Amount</th>
                      <th className="px-4 py-3 text-left">Status</th>
                      <th className="px-4 py-3 text-left">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {transactions.map((item, idx) => (
                      <motion.tr
                        key={item.txHash}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: idx * 0.1 }}
                        className="border-t border-gray-700/50 hover:bg-gray-800/30 transition cursor-pointer"
                        onClick={() => openEmployeePopup(item)}
                      >
                        <td className="px-4 py-3">
                          {new Date(item.createdAt).toLocaleString()}
                        </td>
                        <td className="px-4 py-3">{item.companyName}</td>
                        <td className="px-4 py-3">{item.employee}</td>
                        <td className="px-4 py-3">
                          {item.amountTransfer} {item.currency} ({item.localCurrency})
                        </td>
                        <td className="px-4 py-3">
                          <span
                            className={`px-2 py-1 rounded text-xs font-semibold ${getStatusColor(item.status)}`}
                          >
                            {item.status}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <div className="flex items-center space-x-2">
                            <span className="font-mono truncate max-w-[120px]">
                              {formatAddress(item.txHash)}
                            </span>
                            <div className="flex space-x-1">
                              <button
                                onClick={(e) => {
                                  e.stopPropagation()
                                  openEmployeePopup(item)
                                }}
                                className="text-cyan-400 hover:text-cyan-300 transition-colors p-1"
                                title="View employee details"
                              >
                                👥
                              </button>
                              <button
                                onClick={(e) => {
                                  e.stopPropagation()
                                  toggleRowExpansion(item.txHash)
                                }}
                                className="text-cyan-400 hover:text-cyan-300 transition-colors p-1"
                                title="View transaction details"
                              >
                                {expandedRows.has(item.txHash) ? '▼' : '▶'}
                              </button>
                            </div>
                          </div>
                        </td>
                      </motion.tr>
                    ))}
                  </tbody>
                </table>

                {/* Expanded Details */}
                <AnimatePresence>
                  {transactions.map((item) => (
                    expandedRows.has(item.txHash) && (
                      <motion.tr
                        key={`details-${item.txHash}`}
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.3, ease: 'easeInOut' }}
                      >
                        <td colSpan={6} className="p-0">
                          <TransactionDetails
                            transaction={item}
                            isExpanded={true}
                            onToggle={() => toggleRowExpansion(item.txHash)}
                          />
                        </td>
                      </motion.tr>
                    )
                  ))}
                </AnimatePresence>
              </div>
            ) : (
              <div className="p-8 text-center">
                <div className="text-gray-500 mb-4">
                  <svg className="w-16 h-16 mx-auto text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                </div>
                <h3 className="text-lg font-medium text-gray-400 mb-2">No transactions found</h3>
                <p className="text-gray-500">
                  {isRpcError 
                    ? "Unable to load transactions due to network issues. Please try again later."
                    : "You haven't executed any payroll transactions yet. Execute your first payroll to see it here."
                  }
                </p>
                {isRpcError && (
                  <button
                    onClick={refreshHistory}
                    className="mt-4 px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors"
                  >
                    Retry Connection
                  </button>
                )}
              </div>
            )}
          </div>

          {/* Stats */}
          {transactions.length > 0 && (
            <div className="mt-6 grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg p-4 backdrop-blur-sm">
                <h3 className="text-sm font-medium text-cyan-300">Total Transactions</h3>
                <p className="text-2xl font-bold text-white">{transactions.length}</p>
              </div>
              <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg p-4 backdrop-blur-sm">
                <h3 className="text-sm font-medium text-cyan-300">Total USDC Sent</h3>
                <p className="text-2xl font-bold text-white">
                  {transactions.reduce((sum, tx) => sum + parseFloat(tx.amountTransfer || '0'), 0).toFixed(2)} USDC
                </p>
              </div>
              <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg p-4 backdrop-blur-sm">
                <h3 className="text-sm font-medium text-cyan-300">Successful</h3>
                <p className="text-2xl font-bold text-green-400">
                  {transactions.filter(tx => tx.status === 'SUCCESS').length}
                </p>
              </div>
              <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg p-4 backdrop-blur-sm">
                <h3 className="text-sm font-medium text-cyan-300">Pending</h3>
                <p className="text-2xl font-bold text-yellow-400">
                  {transactions.filter(tx => tx.status === 'PENDING').length}
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Employee Details Popup */}
      <EmployeeDetailsPopup
        isOpen={isPopupOpen}
        onClose={closeEmployeePopup}
        transaction={selectedTransaction}
      />
    </div>
  )
}
