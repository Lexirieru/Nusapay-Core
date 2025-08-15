import { Providers } from '@/providers'
import '@rainbow-me/rainbowkit/styles.css'
import './globals.css'
import type { Metadata } from 'next'
import { Poppins } from 'next/font/google'
import { Navbar } from '@/components/Navbar'
import { TransactionNotification } from '@/components/TransactionNotification'
import { RpcStatusIndicator } from '@/components/RpcStatusIndicator'

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700", "800", "900"],
})

export const metadata: Metadata = {
  title: "NusaPay",
  description: "Powered by IDRX",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={poppins.className + " bg-[#000000] text-white"}>
        <Providers>
          <Navbar />
          <TransactionNotification />
          <RpcStatusIndicator />
          {children}
        </Providers>
      </body>
    </html>
  )
}
