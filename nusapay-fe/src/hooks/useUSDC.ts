import { useContractRead, useContractWrite } from 'wagmi'
import { useAccount } from 'wagmi'
import { mockUSDC } from '@/abis/mockUsdc'
import { CONTRACTS } from '@/lib/contracts'

export function useUSDC() {
  const { address } = useAccount()
  
  // Get USDC balance
  const { data: balance } = useContractRead({
    address: CONTRACTS.coreTestnet.mockUSDC,
    abi: mockUSDC,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address
    }
  })

  // Mint USDC
  const { writeContract: writeMintUSDC, isPending: isMinting } = useContractWrite()

  const mintUSDC = async (args: any) => {
    await writeMintUSDC({
      address: CONTRACTS.coreTestnet.mockUSDC,
      abi: mockUSDC,
      functionName: 'mint',
      ...args
    })
  }

  // Approve USDC
  const { writeContract: writeApproveUSDC, isPending: isApproving } = useContractWrite()

  const approveUSDC = async (args: any) => {
    await writeApproveUSDC({
      address: CONTRACTS.coreTestnet.mockUSDC,
      abi: mockUSDC,
      functionName: 'approve',
      ...args
    })
  }

  return {
    balance,
    mintUSDC,
    approveUSDC,
    isMinting,
    isApproving
  }
} 