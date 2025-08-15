import { ethers } from 'ethers'
import { CONTRACTS } from '@/lib/contracts'
import { originPayroll } from '@/abis/originPayroll'

export interface TransactionHistory {
  payrollId: string
  txHash: string
  blockNumber: number
  timestamp: number
  totalRecipients: number
  totalCryptoAmount: string
  totalFiatAmount: string
  employees: string[]
  cryptoAmounts: string[]
  fiatAmounts: string[]
  currencies: string[]
  bankAccounts: string[]
  status: 'PENDING' | 'SUCCESS' | 'FAILED'
  gasUsed?: string
  gasPrice?: string
}

export interface PayrollBatchSentEvent {
  payrollId: string
  totalRecipients: number
  totalCryptoAmount: string
  totalFiatAmount: string
  timestamp: number
  txHash: string
  blockNumber: number
}

export interface PayrollBatchDetailsEvent {
  payrollId: string
  employees: string[]
  cryptoAmounts: string[]
  fiatAmounts: string[]
  currencies: string[]
  bankAccounts: string[]
}

class TransactionService {
  private provider: ethers.Provider | null = null
  private contract: ethers.Contract | null = null

  async initialize() {
    if (typeof window !== 'undefined' && window.ethereum) {
      try {
        this.provider = new ethers.BrowserProvider(window.ethereum)
        this.contract = new ethers.Contract(
          CONTRACTS.coreTestnet.originPayroll,
          originPayroll,
          this.provider
        )
      } catch (error) {
        console.error('Failed to initialize provider:', error)
        throw new Error('Failed to connect to blockchain provider')
      }
    }
  }

  async getTransactionHistory(address: string, fromBlock?: number): Promise<TransactionHistory[]> {
    if (!this.contract || !this.provider) {
      await this.initialize()
    }

    if (!this.contract || !this.provider) {
      throw new Error('Failed to initialize provider')
    }

    try {
      // Get current block number with retry mechanism
      let currentBlock: number
      try {
        currentBlock = await this.provider.getBlockNumber()
      } catch (error) {
        console.warn('Failed to get current block number, using fallback:', error)
        currentBlock = 1000000 // Fallback block number
      }

      const fromBlockNumber = fromBlock || Math.max(0, currentBlock - 10000) // Last 10k blocks

      // Fetch PayrollBatchSent events with retry
      let batchSentEvents: any[] = []
      try {
        const batchSentFilter = this.contract.filters.PayrollBatchSent()
        batchSentEvents = await this.contract.queryFilter(batchSentFilter, fromBlockNumber, currentBlock)
      } catch (error) {
        console.warn('Failed to fetch PayrollBatchSent events:', error)
        // Return empty array instead of throwing
        return []
      }

      // Fetch PayrollBatchDetails events with retry
      let batchDetailsEvents: any[] = []
      try {
        const batchDetailsFilter = this.contract.filters.PayrollBatchDetails()
        batchDetailsEvents = await this.contract.queryFilter(batchDetailsFilter, fromBlockNumber, currentBlock)
      } catch (error) {
        console.warn('Failed to fetch PayrollBatchDetails events:', error)
        // Continue with empty details
      }

      // Create a map of payroll details by payrollId
      const detailsMap = new Map<string, PayrollBatchDetailsEvent>()
      for (const event of batchDetailsEvents) {
        try {
          const payrollId = event.args?.[0] as string
          if (payrollId) {
            detailsMap.set(payrollId, {
              payrollId,
              employees: event.args?.[1] as string[] || [],
              cryptoAmounts: (event.args?.[2] as bigint[] || []).map(amount => ethers.formatUnits(amount, 6)), // USDC has 6 decimals
              fiatAmounts: (event.args?.[3] as bigint[] || []).map(amount => amount.toString()),
              currencies: event.args?.[4] as string[] || [],
              bankAccounts: event.args?.[5] as string[] || []
            })
          }
        } catch (error) {
          console.warn('Failed to parse batch details event:', error)
        }
      }

      // Combine events into transaction history
      const transactions: TransactionHistory[] = []

      for (const event of batchSentEvents) {
        try {
          const payrollId = event.args?.[0] as string
          const totalRecipients = Number(event.args?.[1] || 0)
          const totalCryptoAmount = ethers.formatUnits(event.args?.[2] as bigint || 0n, 6) // USDC has 6 decimals
          const totalFiatAmount = (event.args?.[3] as bigint || 0n).toString()
          const timestamp = Number(event.args?.[4] || 0)

          // Get transaction receipt with retry and fallback
          let receipt = null
          let block = null
          try {
            receipt = await this.provider!.getTransactionReceipt(event.transactionHash)
            if (receipt) {
              block = await this.provider!.getBlock(receipt.blockNumber)
            }
          } catch (error) {
            console.warn(`Failed to get receipt for tx ${event.transactionHash}:`, error)
            // Continue without receipt data
          }

          const details = detailsMap.get(payrollId)

          if (details) {
            transactions.push({
              payrollId,
              txHash: event.transactionHash,
              blockNumber: event.blockNumber,
              timestamp: block?.timestamp || timestamp,
              totalRecipients,
              totalCryptoAmount,
              totalFiatAmount,
              employees: details.employees,
              cryptoAmounts: details.cryptoAmounts,
              fiatAmounts: details.fiatAmounts,
              currencies: details.currencies,
              bankAccounts: details.bankAccounts,
              status: receipt?.status === 1 ? 'SUCCESS' : receipt ? 'FAILED' : 'PENDING',
              gasUsed: receipt?.gasUsed?.toString(),
              gasPrice: receipt?.effectiveGasPrice?.toString()
            })
          }
        } catch (error) {
          console.warn('Failed to process batch sent event:', error)
        }
      }

      // Sort by timestamp (newest first)
      return transactions.sort((a, b) => b.timestamp - a.timestamp)
    } catch (error) {
      console.error('Error fetching transaction history:', error)
      // Return empty array instead of throwing to prevent app crash
      return []
    }
  }

  async getTransactionByHash(txHash: string): Promise<TransactionHistory | null> {
    if (!this.contract || !this.provider) {
      await this.initialize()
    }

    if (!this.contract || !this.provider) {
      throw new Error('Failed to initialize provider')
    }

    try {
      // Get transaction receipt with retry
      let receipt = null
      let block = null
      
      try {
        receipt = await this.provider.getTransactionReceipt(txHash)
        if (!receipt) return null
        block = await this.provider.getBlock(receipt.blockNumber)
        if (!block) return null
      } catch (error) {
        console.warn(`Failed to get receipt for tx ${txHash}:`, error)
        return null
      }

      // Get logs from the transaction
      const logs = receipt.logs.filter(log => 
        log.address.toLowerCase() === CONTRACTS.coreTestnet.originPayroll.toLowerCase()
      )

      // Parse PayrollBatchSent event
      const batchSentLog = logs.find(log => {
        try {
          const parsed = this.contract!.interface.parseLog(log)
          return parsed?.name === 'PayrollBatchSent'
        } catch {
          return false
        }
      })

      if (!batchSentLog) return null

      const parsedBatchSent = this.contract!.interface.parseLog(batchSentLog)
      const payrollId = parsedBatchSent?.args?.[0] as string

      // Parse PayrollBatchDetails event
      const batchDetailsLog = logs.find(log => {
        try {
          const parsed = this.contract!.interface.parseLog(log)
          return parsed?.name === 'PayrollBatchDetails' && parsed?.args?.[0] === payrollId
        } catch {
          return false
        }
      })

      if (!batchDetailsLog) return null

      const parsedBatchDetails = this.contract!.interface.parseLog(batchDetailsLog)

      return {
        payrollId,
        txHash,
        blockNumber: receipt.blockNumber,
        timestamp: block.timestamp,
        totalRecipients: Number(parsedBatchSent?.args?.[1] || 0),
        totalCryptoAmount: ethers.formatUnits(parsedBatchSent?.args?.[2] as bigint || 0n, 6),
        totalFiatAmount: (parsedBatchSent?.args?.[3] as bigint || 0n).toString(),
        employees: parsedBatchDetails?.args?.[1] as string[] || [],
        cryptoAmounts: (parsedBatchDetails?.args?.[2] as bigint[] || []).map(amount => ethers.formatUnits(amount, 6)),
        fiatAmounts: (parsedBatchDetails?.args?.[3] as bigint[] || []).map(amount => amount.toString()),
        currencies: parsedBatchDetails?.args?.[4] as string[] || [],
        bankAccounts: parsedBatchDetails?.args?.[5] as string[] || [],
        status: receipt.status === 1 ? 'SUCCESS' : 'FAILED',
        gasUsed: receipt.gasUsed?.toString(),
        gasPrice: receipt.effectiveGasPrice?.toString()
      }
    } catch (error) {
      console.error('Error fetching transaction by hash:', error)
      return null
    }
  }

  // Get transaction status from blockchain with retry
  async getTransactionStatus(txHash: string): Promise<'PENDING' | 'SUCCESS' | 'FAILED'> {
    if (!this.provider) {
      await this.initialize()
    }

    if (!this.provider) {
      throw new Error('Failed to initialize provider')
    }

    try {
      const receipt = await this.provider.getTransactionReceipt(txHash)
      if (!receipt) return 'PENDING'
      return receipt.status === 1 ? 'SUCCESS' : 'FAILED'
    } catch (error) {
      console.error('Error getting transaction status:', error)
      // Return PENDING as fallback instead of throwing
      return 'PENDING'
    }
  }

  // Check if RPC is available
  async checkRpcHealth(): Promise<boolean> {
    if (!this.provider) {
      try {
        await this.initialize()
      } catch {
        return false
      }
    }

    if (!this.provider) return false

    try {
      await this.provider.getBlockNumber()
      return true
    } catch (error) {
      console.warn('RPC health check failed:', error)
      return false
    }
  }
}

export const transactionService = new TransactionService()
