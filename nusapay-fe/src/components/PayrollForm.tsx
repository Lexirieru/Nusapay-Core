'use client'

import { useState } from 'react'
import { useAccount } from 'wagmi'
import { useOriginPayroll, useExecutePayroll } from '@/hooks/useOriginPayroll'
import { useUSDC } from '@/hooks/useUSDC'
import { CONTRACTS } from '@/lib/contracts'
import { motion, AnimatePresence } from 'framer-motion'
import { useTransactionContext } from '@/contexts/TransactionContext'

interface Employee {
  name: string
  address: string
  cryptoAmount: string
  fiatAmount: string
  currency: string
  bankName: string
  bankAccount: string
}

interface PayrollFormProps {
  onSuccess: (details: any) => void;
}

// Static exchange rate: 1 USDC = 16400 IDR
const USDC_TO_IDR_RATE = 16400

// List of Indonesian banks
const INDONESIAN_BANKS = [
  { code: 'BCA', name: 'Bank Central Asia (BCA)' },
  { code: 'MDR', name: 'Bank Mandiri' },
  { code: 'BRI', name: 'Bank Rakyat Indonesia (BRI)' },
  { code: 'BNI', name: 'Bank Negara Indonesia (BNI)' },
  { code: 'CIMB', name: 'CIMB Niaga' },
  { code: 'DBS', name: 'DBS Indonesia' },
  { code: 'OCBC', name: 'OCBC NISP' },
  { code: 'PANIN', name: 'Bank Panin' },
  { code: 'PERMATA', name: 'Bank Permata' },
  { code: 'MAYAPADA', name: 'Bank Mayapada' },
  { code: 'MEGA', name: 'Bank Mega' },
  { code: 'BUKOPIN', name: 'Bank Bukopin' },
  { code: 'BTPN', name: 'Bank BTPN' },
  { code: 'JAGO', name: 'Bank Jago' },
  { code: 'SEA', name: 'Bank Seabank Indonesia' },
  { code: 'OTHER', name: 'Other Bank' }
]

export function PayrollForm({ onSuccess }: PayrollFormProps) {
  const { address } = useAccount()
  const { owner } = useOriginPayroll()
  const { executePayroll, isLoading: isExecuting } = useExecutePayroll()
  const { balance, approveUSDC, isApproving } = useUSDC()
  const { addPendingTransaction, refreshHistory } = useTransactionContext()

  const [employees, setEmployees] = useState<Employee[]>([
    {
      name: 'Name',
      address: '',
      cryptoAmount: '',
      fiatAmount: '',
      currency: 'IDR',
      bankName: '',
      bankAccount: ''
    }
  ])

  const [gasPayment] = useState('0')
  const [isTransferring, setIsTransferring] = useState(false)

  // Check if user is owner
  const isOwner = address && owner && address.toLowerCase() === owner.toLowerCase()

  // Calculate total crypto amount
  const totalCryptoAmount = employees.reduce((sum, emp) => {
    return sum + (parseFloat(emp.cryptoAmount) || 0)
  }, 0)

  // Convert USDC to IDR
  const convertUSDCToIDR = (usdcAmount: string): string => {
    const usdc = parseFloat(usdcAmount) || 0
    return (usdc * USDC_TO_IDR_RATE).toString()
  }

  // Add new employee row
  const addEmployee = () => {
    setEmployees([...employees, {
      name: `Name ${employees.length + 1}`,
      address: '',
      cryptoAmount: '',
      fiatAmount: '',
      currency: 'IDR',
      bankName: '',
      bankAccount: ''
    }])
  }

  // Remove employee row
  const removeEmployee = (index: number) => {
    if (employees.length > 1) {
      setEmployees(employees.filter((_, i) => i !== index))
    }
  }

  // Update employee data
  const updateEmployee = (index: number, field: keyof Employee, value: string) => {
    const newEmployees = [...employees]
    
    if (field === 'cryptoAmount') {
      // Auto-convert USDC to IDR when crypto amount changes
      newEmployees[index] = { 
        ...newEmployees[index], 
        [field]: value,
        fiatAmount: convertUSDCToIDR(value)
      }
    } else if (field === 'currency') {
      // Reset fiat amount when currency changes
      newEmployees[index] = { 
        ...newEmployees[index], 
        [field]: value,
        fiatAmount: value === 'IDR' ? convertUSDCToIDR(newEmployees[index].cryptoAmount) : ''
      }
    } else {
      newEmployees[index] = { ...newEmployees[index], [field]: value }
    }
    
    setEmployees(newEmployees)
  }

  // Execute payroll with automatic approval
  const handleExecutePayroll = async () => {
    try {
      setIsTransferring(true)

      // Step 1: Approve USDC first
      const totalAmount = totalCryptoAmount * 1e6
      console.log('Approving USDC amount:', totalAmount)
      
      await approveUSDC({ 
        args: [CONTRACTS.coreTestnet.originPayroll, BigInt(totalAmount)] 
      })
      
      // Step 2: Execute payroll after approval
      const employeeAddresses = employees.map(emp => emp.address)
      const cryptoAmounts = employees.map(emp => BigInt((parseFloat(emp.cryptoAmount) * 1e6).toString()))
      const fiatAmounts = employees.map(emp => BigInt(emp.fiatAmount))
      const currencies = employees.map(emp => emp.currency)
      const bankAccounts = employees.map(emp => `${emp.bankName}:${emp.bankAccount}`)

      console.log('Executing payroll...')
      await executePayroll({
        args: [employeeAddresses, cryptoAmounts, fiatAmounts, currencies, bankAccounts],
        value: BigInt((parseFloat(gasPayment) * 1e18).toString())
      })

      // Simulate 3 second loading
      await new Promise(resolve => setTimeout(resolve, 3000))

      // Set success details and call the onSuccess callback
      const successDetails = {
        transactionHash: 'Transaction submitted successfully',
        totalAmount: totalCryptoAmount,
        employeeCount: employees.length,
        employees: employees.map((emp, index) => ({
          name: emp.name,
          address: emp.address,
          usdcAmount: emp.cryptoAmount,
          fiatAmount: emp.fiatAmount,
          currency: emp.currency,
          bank: `${emp.bankName}:${emp.bankAccount}`
        })),
        timestamp: new Date().toLocaleString()
      }
      
      onSuccess(successDetails);
      setIsTransferring(false)
      
      // Refresh transaction history after a delay to allow blockchain to update
      setTimeout(() => {
        refreshHistory()
      }, 5000)
      
    } catch (error) {
      console.error('Error in payroll execution:', error)
      setIsTransferring(false)
      throw error
    }
  }

  return (
    <div className="space-y-6">
      {/* Exchange Rate Info */}
      <div className="bg-cyan-900/30 border border-cyan-500/30 rounded-lg p-4 backdrop-blur-sm">
        <h3 className="text-lg font-semibold text-cyan-300 mb-2">Exchange Rate</h3>
        <p className="text-cyan-200">
          1 USDC = {USDC_TO_IDR_RATE.toLocaleString()} IDR (Static Rate)
        </p>
        <p className="text-sm text-cyan-300/80 mt-1">
          Fiat Amount will be automatically calculated from USDC Amount
        </p>
      </div>

      {/* Balance and Setup Section */}
      <div className="bg-gray-900/50 rounded-lg p-4 backdrop-blur-sm border border-gray-700/50">
        <h3 className="text-lg font-semibold mb-4 text-white">Setup & Balance</h3>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <p className="text-sm text-cyan-300">USDC Balance</p>
            <p className="text-lg font-semibold text-white">
              {balance ? (Number(balance) / 1e6).toFixed(2) : '0'} USDC
            </p>
          </div>
          
          <div>
            <p className="text-sm text-cyan-300">Required Amount</p>
            <p className="text-lg font-semibold text-white">{totalCryptoAmount.toFixed(2)} USDC</p>
          </div>
          
          <div>
            <p className="text-sm text-cyan-300">Status</p>
            <p className="text-lg font-semibold text-white">
              {balance && Number(balance) >= totalCryptoAmount * 1e6 ? '✅ Ready' : '❌ Insufficient'}
            </p>
          </div>
        </div>
      </div>

      {/* Payroll Form */}
      <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg p-6 backdrop-blur-sm">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold text-white">Payroll Details</h3>
          <button
            onClick={addEmployee}
            className="px-3 py-1 bg-cyan-600 text-white rounded text-sm hover:bg-cyan-700 transition-colors"
          >
            + Add Employee
          </button>
        </div>

        {employees.map((employee, index) => (
          <div key={index} className="border border-gray-700/50 rounded-lg p-4 mb-4 bg-gray-800/30 backdrop-blur-sm">
            <div className="flex justify-between items-center mb-3">
              {/* <h4 className="font-medium text-white">Employee {index + 1}</h4> */}
              <div className="flex items-center space-x-2">
                <input
                  type="text"
                  value={employee.name}
                  onChange={(e) => updateEmployee(index, 'name', e.target.value)}
                  className="font-medium text-white  border-none outline-none bg-gray-700/50 px-2 py-1 rounded transition-colors"
                  placeholder="Employee Name"
                />
                <svg 
                  className="w-4 h-4 text-gray-400" 
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  <path 
                    strokeLinecap="round" 
                    strokeLinejoin="round" 
                    strokeWidth={2} 
                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" 
                  />
                </svg>
              </div>
              {employees.length > 1 && (
                <button
                  onClick={() => removeEmployee(index)}
                  className="text-red-400 hover:text-red-300 transition-colors"
                >
                  Remove
                </button>
              )}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-cyan-300 mb-1">
                  Address
                </label>
                <input
                  type="text"
                  value={employee.address}
                  onChange={(e) => updateEmployee(index, 'address', e.target.value)}
                  placeholder="0x..."
                  className="w-full px-3 py-2 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-gray-800/50 text-white placeholder-gray-400"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-cyan-300 mb-1">
                  USDC Amount
                </label>
                <input
                  type="number"
                  value={employee.cryptoAmount}
                  onChange={(e) => updateEmployee(index, 'cryptoAmount', e.target.value)}
                  placeholder="1000"
                  step="0.01"
                  className="w-full px-3 py-2 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-gray-800/50 text-white placeholder-gray-400"
                />
                {employee.cryptoAmount && (
                  <p className="text-xs text-cyan-300/70 mt-1">
                    ≈ {(parseFloat(employee.cryptoAmount) * USDC_TO_IDR_RATE).toLocaleString()} IDR
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-cyan-300 mb-1">
                  Fiat Amount
                </label>
                <input
                  type="number"
                  value={employee.fiatAmount}
                  onChange={(e) => updateEmployee(index, 'fiatAmount', e.target.value)}
                  placeholder="16400000"
                  className="w-full px-3 py-2 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-gray-800/50 text-white placeholder-gray-400"
                  readOnly={employee.currency === 'IDR'}
                />
                {employee.currency === 'IDR' && (
                  <p className="text-xs text-cyan-300/70 mt-1">
                    Auto-calculated from USDC Amount
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-cyan-300 mb-1">
                  Currency
                </label>
                <select
                  value={employee.currency}
                  onChange={(e) => updateEmployee(index, 'currency', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-gray-800/50 text-white"
                >
                  <option value="IDR">IDR</option>
                  <option value="USD">USD</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-cyan-300 mb-1">
                  Bank
                </label>
                <select
                  value={employee.bankName}
                  onChange={(e) => updateEmployee(index, 'bankName', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-gray-800/50 text-white"
                >
                  <option value="">Select Bank</option>
                  {INDONESIAN_BANKS.map((bank) => (
                    <option key={bank.code} value={bank.code}>
                      {bank.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-cyan-300 mb-1">
                  Account Number
                </label>
                <input
                  type="text"
                  value={employee.bankAccount}
                  onChange={(e) => updateEmployee(index, 'bankAccount', e.target.value)}
                  placeholder="1234567890"
                  className="w-full px-3 py-2 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-gray-800/50 text-white placeholder-gray-400"
                />
                {employee.bankName && employee.bankAccount && (
                  <p className="text-xs text-cyan-300/70 mt-1">
                    {INDONESIAN_BANKS.find(bank => bank.code === employee.bankName)?.name}: {employee.bankAccount}
                  </p>
                )}
              </div>
            </div>
          </div>
        ))}

        {/* Execute Button */}
        <div className="mt-6">
          <button
            onClick={handleExecutePayroll}
            disabled={isExecuting || isApproving || isTransferring}
            className="w-full px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 font-semibold transition-colors"
          >
            {isApproving ? 'Approving USDC...' : isExecuting ? 'Executing Payroll...' : isTransferring ? 'Transferring...' : 'Execute Payroll'}
          </button>
          
          {/* Loading Animation */}
          <AnimatePresence>
            {(isApproving || isExecuting || isTransferring) && (
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="mt-4"
              >
                <div className="flex items-center justify-center space-x-2">
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                    className="w-5 h-5 border-2 border-cyan-400 border-t-transparent rounded-full"
                  />
                  <p className="text-sm text-cyan-300">
                    {isApproving ? 'Step 1: Approving USDC tokens...' : isExecuting ? 'Step 2: Executing payroll transaction...' : 'Processing cross-chain transfer...'}
                  </p>
                </div>
                
                {/* Progress Bar */}
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: "100%" }}
                  transition={{ duration: 3, ease: "easeInOut" }}
                  className="mt-3 h-2 bg-cyan-900/50 rounded-full overflow-hidden"
                >
                  <motion.div
                    animate={{ 
                      background: [
                        "linear-gradient(90deg, #0891b2, #06b6d4)",
                        "linear-gradient(90deg, #06b6d4, #22d3ee)",
                        "linear-gradient(90deg, #22d3ee, #67e8f9)"
                      ]
                    }}
                    transition={{ duration: 2, repeat: Infinity }}
                    className="h-full w-full"
                  />
                </motion.div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  )
}