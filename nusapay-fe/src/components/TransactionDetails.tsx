'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { getExplorerUrl } from '@/config/config'

interface TransactionDetailsProps {
  transaction: any
  isExpanded: boolean
  onToggle: () => void
}

export function TransactionDetails({ transaction, isExpanded, onToggle }: TransactionDetailsProps) {
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

  return (
    <div className="border-t border-gray-700/50">
      <button
        onClick={onToggle}
        className="w-full px-4 py-3 text-left hover:bg-gray-800/30 transition-colors flex items-center justify-between"
      >
        <span className="text-sm text-cyan-300">View Details</span>
        <motion.div
          animate={{ rotate: isExpanded ? 180 : 0 }}
          transition={{ duration: 0.2 }}
          className="text-cyan-300"
        >
          ▼
        </motion.div>
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: 'easeInOut' }}
            className="overflow-hidden"
          >
            <div className="px-4 pb-4 space-y-4">
              {/* Transaction Info */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="bg-gray-800/30 rounded-lg p-3">
                  <h4 className="text-sm font-semibold text-cyan-300 mb-2">Transaction Info</h4>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-400">Payroll ID:</span>
                      <span className="text-white font-mono">{transaction.txId}</span>
                    </div>
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

                <div className="bg-gray-800/30 rounded-lg p-3">
                  <h4 className="text-sm font-semibold text-cyan-300 mb-2">Transaction Hash</h4>
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
              </div>

              {/* Employee Details */}
              {transaction.employees && transaction.employees.length > 0 && (
                <div className="bg-gray-800/30 rounded-lg p-3">
                  <h4 className="text-sm font-semibold text-cyan-300 mb-3">Employee Details</h4>
                  <div className="space-y-3">
                    {transaction.employees.map((employee: string, index: number) => (
                      <div key={index} className="border border-gray-700/50 rounded-lg p-3">
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3 text-sm">
                          <div>
                            <span className="text-gray-400">Employee {index + 1}:</span>
                            <div className="flex items-center space-x-2 mt-1">
                              <span className="text-white font-mono truncate">
                                {formatAddress(employee)}
                              </span>
                              <button
                                onClick={() => copyToClipboard(employee, `employee-${index}`)}
                                className="text-cyan-400 hover:text-cyan-300 transition-colors"
                                title="Copy address"
                              >
                                {copiedField === `employee-${index}` ? '✓' : '📋'}
                              </button>
                            </div>
                          </div>
                          
                          <div>
                            <span className="text-gray-400">USDC Amount:</span>
                            <div className="text-white font-semibold">
                              {transaction.cryptoAmounts?.[index] || 'N/A'} USDC
                            </div>
                          </div>
                          
                          <div>
                            <span className="text-gray-400">Fiat Amount:</span>
                            <div className="text-white">
                              {transaction.fiatAmounts?.[index] ? 
                                `${Number(transaction.fiatAmounts[index]).toLocaleString()} ${transaction.currencies?.[index] || 'IDR'}` : 
                                'N/A'
                              }
                            </div>
                          </div>
                          
                          <div>
                            <span className="text-gray-400">Bank Account:</span>
                            <div className="text-white text-sm">
                              {transaction.bankAccounts?.[index] ? 
                                formatBankAccount(transaction.bankAccounts[index]) : 
                                'N/A'
                              }
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Summary */}
              <div className="bg-gray-800/30 rounded-lg p-3">
                <h4 className="text-sm font-semibold text-cyan-300 mb-2">Summary</h4>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                  <div>
                    <span className="text-gray-400">Total Recipients:</span>
                    <div className="text-white font-semibold">{transaction.employee}</div>
                  </div>
                  <div>
                    <span className="text-gray-400">Total USDC:</span>
                    <div className="text-white font-semibold">{transaction.amountTransfer} USDC</div>
                  </div>
                  <div>
                    <span className="text-gray-400">Total Fiat:</span>
                    <div className="text-white">
                      {transaction.fiatAmounts ? 
                        `${transaction.fiatAmounts.reduce((sum: number, amount: string) => sum + Number(amount), 0).toLocaleString()} ${transaction.localCurrency}` : 
                        'N/A'
                      }
                    </div>
                  </div>
                  <div>
                    <span className="text-gray-400">Status:</span>
                    <div className={`inline-block px-2 py-1 rounded text-xs font-semibold border ${getStatusColor(transaction.status)}`}>
                      {transaction.status}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
} 