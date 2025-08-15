'use client'

import { motion, AnimatePresence } from 'framer-motion'
import { useState } from 'react'
import { getExplorerUrl } from '@/config/config'

interface EmployeeDetailsPopupProps {
  isOpen: boolean
  onClose: () => void
  transaction: any
}

export function EmployeeDetailsPopup({ isOpen, onClose, transaction }: EmployeeDetailsPopupProps) {
  const [copiedField, setCopiedField] = useState<string | null>(null)

  const copyToClipboard = async (text: string, field: string) => {
    try {
      await navigator.clipboard.writeText(text)
      setCopiedField(field)
      setTimeout(() => setCopiedField(null), 2000)
    } catch (err) {
      console.error('Failed to copy to clipboard:', err)
    }
  }

  const formatAddress = (address: string) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`
  }

  const formatBankAccount = (bankAccount: string) => {
    const [bank, account] = bankAccount.split(':')
    return `${bank}: ${account}`
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'SUCCESS':
        return 'bg-green-600/30 text-green-400 border-green-500/30'
      case 'PENDING':
        return 'bg-yellow-600/30 text-yellow-400 border-yellow-500/30'
      case 'FAILED':
        return 'bg-red-600/30 text-red-400 border-red-500/30'
      default:
        return 'bg-gray-600/30 text-gray-400 border-gray-500/30'
    }
  }

  const formatCurrency = (amount: string, currency: string) => {
    const numAmount = parseFloat(amount)
    if (isNaN(numAmount)) return 'N/A'
    
    if (currency === 'IDR') {
      return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      }).format(numAmount)
    } else {
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: currency,
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(numAmount)
    }
  }

  if (!transaction) return null

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50"
          onClick={onClose}
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.8, y: 50 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.8, y: 50 }}
            transition={{ duration: 0.3, ease: "easeOut" }}
            className="bg-gray-900 border border-cyan-500/30 rounded-lg p-6 backdrop-blur-sm max-w-4xl w-full max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex justify-between items-center mb-6">
              <div>
                <h2 className="text-2xl font-bold text-white">Employee Payroll Details</h2>
                <p className="text-cyan-400 mt-1">Transaction: {transaction.txId}</p>
              </div>
              <button
                onClick={onClose}
                className="text-gray-400 hover:text-white transition-colors p-2"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            {/* Transaction Summary */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
              <div className="bg-gray-800/50 rounded-lg p-4 border border-gray-700/50">
                <h3 className="text-sm font-medium text-cyan-300 mb-1">Total Employees</h3>
                <p className="text-2xl font-bold text-white">{transaction.employees?.length || 0}</p>
              </div>
              <div className="bg-gray-800/50 rounded-lg p-4 border border-gray-700/50">
                <h3 className="text-sm font-medium text-cyan-300 mb-1">Total USDC</h3>
                <p className="text-2xl font-bold text-white">{transaction.amountTransfer} USDC</p>
              </div>
              <div className="bg-gray-800/50 rounded-lg p-4 border border-gray-700/50">
                <h3 className="text-sm font-medium text-cyan-300 mb-1">Status</h3>
                <div className={`inline-block px-3 py-1 rounded text-sm font-semibold border ${getStatusColor(transaction.status)}`}>
                  {transaction.status}
                </div>
              </div>
              <div className="bg-gray-800/50 rounded-lg p-4 border border-gray-700/50">
                <h3 className="text-sm font-medium text-cyan-300 mb-1">Date</h3>
                <p className="text-white">{new Date(transaction.createdAt).toLocaleString()}</p>
              </div>
            </div>

            {/* Employee List */}
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-white mb-4">Employee Details</h3>
              
              {transaction.employees && transaction.employees.length > 0 ? (
                <div className="space-y-4 max-h-96 overflow-y-auto">
                  {transaction.employees.map((employee: string, index: number) => (
                    <motion.div
                      key={index}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className="bg-gray-800/50 border border-gray-700/50 rounded-lg p-4 hover:bg-gray-800/70 transition-colors"
                    >
                      <div className="flex justify-between items-start mb-3">
                        <h4 className="text-lg font-semibold text-cyan-300">Employee {index + 1}</h4>
                        <div className="text-right">
                          <p className="text-white font-semibold text-lg">
                            {transaction.cryptoAmounts?.[index] || 'N/A'} USDC
                          </p>
                          <p className="text-gray-300 text-sm">
                            {transaction.fiatAmounts?.[index] && transaction.currencies?.[index] 
                              ? formatCurrency(transaction.fiatAmounts[index], transaction.currencies[index])
                              : 'N/A'
                            }
                          </p>
                        </div>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {/* Wallet Address */}
                        <div className="bg-gray-900/50 rounded-lg p-3">
                          <h5 className="text-sm font-medium text-gray-400 mb-2">Wallet Address</h5>
                          <div className="flex items-center space-x-2">
                            <span className="text-white font-mono text-sm truncate flex-1">
                              {formatAddress(employee)}
                            </span>
                            <button
                              onClick={() => copyToClipboard(employee, `employee-${index}`)}
                              className="text-cyan-400 hover:text-cyan-300 transition-colors p-1"
                              title="Copy address"
                            >
                              {copiedField === `employee-${index}` ? '✓' : '📋'}
                            </button>
                          </div>
                          <div className="mt-2">
                            <a
                              href={getExplorerUrl.address(employee)}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-cyan-400 hover:text-cyan-300 text-xs transition-colors"
                            >
                              View on Explorer →
                            </a>
                          </div>
                        </div>

                        {/* Bank Account */}
                        <div className="bg-gray-900/50 rounded-lg p-3">
                          <h5 className="text-sm font-medium text-gray-400 mb-2">Bank Account</h5>
                          <div className="flex items-center space-x-2">
                            <span className="text-white text-sm truncate flex-1">
                              {transaction.bankAccounts?.[index] ? 
                                formatBankAccount(transaction.bankAccounts[index]) : 
                                'N/A'
                              }
                            </span>
                            {transaction.bankAccounts?.[index] && (
                              <button
                                onClick={() => copyToClipboard(transaction.bankAccounts[index], `bank-${index}`)}
                                className="text-cyan-400 hover:text-cyan-300 transition-colors p-1"
                                title="Copy bank account"
                              >
                                {copiedField === `bank-${index}` ? '✓' : '📋'}
                              </button>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Amount Details */}
                      <div className="mt-3 pt-3 border-t border-gray-700/50">
                        <div className="grid grid-cols-2 gap-4 text-sm">
                          <div>
                            <span className="text-gray-400">USDC Amount:</span>
                            <p className="text-white font-semibold">
                              {transaction.cryptoAmounts?.[index] || 'N/A'} USDC
                            </p>
                          </div>
                          <div>
                            <span className="text-gray-400">Fiat Amount:</span>
                            <p className="text-white">
                              {transaction.fiatAmounts?.[index] && transaction.currencies?.[index] 
                                ? formatCurrency(transaction.fiatAmounts[index], transaction.currencies[index])
                                : 'N/A'
                              }
                            </p>
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <div className="text-gray-500 mb-4">
                    <svg className="w-16 h-16 mx-auto text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                  </div>
                  <h3 className="text-lg font-medium text-gray-400 mb-2">No Employee Data</h3>
                  <p className="text-gray-500">No employee information available for this transaction.</p>
                </div>
              )}
            </div>

            {/* Transaction Info */}
            <div className="mt-6 pt-6 border-t border-gray-700/50">
              <h3 className="text-lg font-semibold text-white mb-4">Transaction Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="bg-gray-800/50 rounded-lg p-3">
                  <h4 className="text-sm font-medium text-cyan-300 mb-2">Transaction Hash</h4>
                  <div className="flex items-center space-x-2">
                    <span className="text-white font-mono text-sm truncate flex-1">
                      {formatAddress(transaction.txHash)}
                    </span>
                    <button
                      onClick={() => copyToClipboard(transaction.txHash, 'txHash')}
                      className="text-cyan-400 hover:text-cyan-300 transition-colors"
                      title="Copy transaction hash"
                    >
                      {copiedField === 'txHash' ? '✓' : '📋'}
                    </button>
                  </div>
                  <div className="mt-2">
                    <a
                      href={getExplorerUrl.transaction(transaction.txHash)}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-cyan-400 hover:text-cyan-300 text-sm transition-colors"
                    >
                      View on Explorer →
                    </a>
                  </div>
                </div>

                <div className="bg-gray-800/50 rounded-lg p-3">
                  <h4 className="text-sm font-medium text-cyan-300 mb-2">Block Information</h4>
                  <div className="space-y-1 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-400">Block Number:</span>
                      <span className="text-white">{transaction.blockNumber?.toLocaleString() || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-400">Gas Used:</span>
                      <span className="text-white">{transaction.gasUsed?.toLocaleString() || 'N/A'}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-400">Gas Price:</span>
                      <span className="text-white">
                        {transaction.gasPrice ? `${(Number(transaction.gasPrice) / 1e9).toFixed(2)} Gwei` : 'N/A'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Close Button */}
            <div className="mt-6 flex justify-end">
              <button
                onClick={onClose}
                className="px-6 py-3 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition-colors font-semibold"
              >
                Close
              </button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
} 