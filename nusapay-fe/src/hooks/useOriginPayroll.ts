import { useContractRead, useContractWrite } from 'wagmi'
import { originPayroll } from '@/abis/originPayroll'
import { CONTRACTS } from '@/lib/contracts'

export function useOriginPayroll() {
  // Check if user is owner
  const { data: owner } = useContractRead({
    address: CONTRACTS.coreTestnet.originPayroll,
    abi: originPayroll,
    functionName: 'owner'
  })

  // Get contract config
  const { data: config } = useContractRead({
    address: CONTRACTS.coreTestnet.originPayroll,
    abi: originPayroll,
    functionName: 'getConfig'
  })

  return {
    owner,
    config
  }
}

export function useExecutePayroll() {
  const { writeContract, isPending, isSuccess, data } = useContractWrite()

  const executePayroll = async (args: any) => {
    await writeContract({
      address: CONTRACTS.coreTestnet.originPayroll,
      abi: originPayroll,
      functionName: 'executePayrollBatch',
      ...args
    })
  }

  return {
    executePayroll,
    isLoading: isPending,
    isSuccess,
    data
  }
} 