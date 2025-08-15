'use client'

import { useAccount } from 'wagmi'
import Threads from '@/components/Threads'
import { useEffect, useState } from 'react'

interface PayrollHistory {
  txId: string
  employee: string
  companyName: string
  templateName: string
  amountTransfer: string
  currency: string
  localCurrency: string
  status: string
  createdAt: string
  bankAccountName: string
  bankAccount: string
  txHash: string
}

export default function PayrollHistoryPage() {
  const { isConnected } = useAccount()
  const [history, setHistory] = useState<PayrollHistory[]>([])

  useEffect(() => {
    // TODO: Ganti ini pake fetch dari API kamu
    const mockData: PayrollHistory[] = [
      {
        txId: 'TX123456',
        employee: '0xAbC123...xyz',
        companyName: 'PT Nusantara',
        templateName: 'Monthly Salary',
        amountTransfer: '1000',
        currency: 'USDC',
        localCurrency: 'IDR',
        status: 'SUCCESS',
        createdAt: '2025-08-15T10:00:00Z',
        bankAccountName: 'Budi Santoso',
        bankAccount: '1234567890',
        txHash: '0xHASH123456'
      },
      {
        txId: 'TX654321',
        employee: '0xDeF456...uvw',
        companyName: 'PT Garuda',
        templateName: 'Freelance Payment',
        amountTransfer: '500',
        currency: 'USDC',
        localCurrency: 'IDR',
        status: 'PENDING',
        createdAt: '2025-08-14T12:30:00Z',
        bankAccountName: 'Siti Aminah',
        bankAccount: '9876543210',
        txHash: '0xHASH654321'
      }
    ]
    setHistory(mockData)
  }, [])

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
            <h1 className="text-3xl font-bold text-white">Payroll History</h1>
            <p className="text-cyan-400 mt-2">View all past payroll transactions</p>
          </div>

          <div className="bg-gray-900/50 border border-gray-700/50 rounded-lg overflow-x-auto backdrop-blur-sm">
            <table className="w-full text-sm text-gray-300">
              <thead className="bg-gray-800/50">
                <tr>
                  <th className="px-4 py-3 text-left">Date</th>
                  <th className="px-4 py-3 text-left">Company</th>
                  <th className="px-4 py-3 text-left">Employee</th>
                  <th className="px-4 py-3 text-left">Amount</th>
                  <th className="px-4 py-3 text-left">Status</th>
                  <th className="px-4 py-3 text-left">Tx Hash</th>
                </tr>
              </thead>
              <tbody>
                {history.length > 0 ? (
                  history.map((item, idx) => (
                    <tr key={idx} className="border-t border-gray-700/50 hover:bg-gray-800/30 transition">
                      <td className="px-4 py-3">{new Date(item.createdAt).toLocaleString()}</td>
                      <td className="px-4 py-3">{item.companyName}</td>
                      <td className="px-4 py-3 truncate max-w-[150px]">{item.employee}</td>
                      <td className="px-4 py-3">
                        {item.amountTransfer} {item.currency} ({item.localCurrency})
                      </td>
                      <td className="px-4 py-3">
                        <span
                          className={`px-2 py-1 rounded text-xs font-semibold ${
                            item.status === 'SUCCESS'
                              ? 'bg-green-600/30 text-green-400'
                              : item.status === 'PENDING'
                              ? 'bg-yellow-600/30 text-yellow-400'
                              : 'bg-red-600/30 text-red-400'
                          }`}
                        >
                          {item.status}
                        </span>
                      </td>
                      <td className="px-4 py-3 truncate max-w-[120px]">{item.txHash}</td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={6} className="px-4 py-6 text-center text-gray-500">
                      No payroll history found
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
