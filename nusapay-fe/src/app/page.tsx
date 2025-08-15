'use client'

import { getMe } from "@/utils/auth"
import Image from "next/image"
import Threads from '@/components/Threads'

export default function Homepage() {
  return (
    <div className="relative h-fit w-full overflow-hidden">
      
      {/* Threads Background */}
      <div className="fixed inset-0 z-0">
        <Threads
          color={[0.04, 0.33, 0.39]} // Cyan color matching the theme
          amplitude={1}
          distance={0}
          enableMouseInteraction={true}
        />
      </div>

      {/* Main Content */}
      <div className="relative z-10 min-h-[80vh] flex flex-col items-center justify-center text-center px-4 py-20 md:py-32 pt-32">
        {/* Logo */}
        <Image
          src="/NusaSVG.svg"
          alt="NusaPay Logo"
          width={198}
          height={173}
          className="mb-6"
        />

        {/* NusaPay Title */}
        <Image
          src="/NusaPay.png"
          alt="NusaPay"
          width={300}
          height={100}
          className="mb-3"
        />

        {/* Subtitle */}
        <p className="text-cyan-400 text-sm sm:text-base md:text-lg font-medium mb-10">
          The First Cross-Chain Cross Border Payment using Hyperlane on Core
        </p>

        {/* Button */}
        <button
          className="bg-[#095564] text-white px-16 py-2 rounded-3xl border-y-1 text-sm md:text-base font-semibold shadow-lg hover:scale-105 transition-transform"
          onClick={() => {
            window.location.href = "/payroll";
          }}
        >
          Transfer Now
        </button>
      </div>
    </div>
  )
}
