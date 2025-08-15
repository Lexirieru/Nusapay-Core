'use client'
import SplitText from "@/components/anim/ShinyText/SplitText"
import Threads from '@/components/Threads'
import Image from "next/image"
import { FiTwitter, FiBook, FiGithub } from "react-icons/fi"

export default function Homepage() {
  const handleAnimationComplete = () => {
    console.log('All letters done')
  }

  return (
    <div className="relative h-fit w-full overflow-hidden">
      {/* Threads Background */}
      <div className="fixed inset-0 z-0">
        <Threads
          color={[0.04, 0.33, 0.39]}
          amplitude={1}
          distance={0}
          enableMouseInteraction={true}
        />
      </div>

      {/* Main Content */}
      <div className="relative z-10 min-h-[80vh] flex flex-col items-center justify-center text-center px-4 py-20 md:py-32 pt-32">
        <Image
          src="/NusaSVG.svg"
          alt="NusaPay Logo"
          width={198}
          height={173}
          className="mb-6"
        />

        <Image
          src="/NusaPay.png"
          alt="NusaPay"
          width={300}
          height={100}
          className="mb-3"
        />

        <SplitText
          text="The First Cross-Chain Cross Border Payment using Hyperlane on Core"
          className="text-2xl mb-3 font-semibold text-center"
          delay={75}
          duration={0.1}
          ease="power3.out"
          splitType="chars"
          from={{ opacity: 0, y: 40 }}
          to={{ opacity: 1, y: 0 }}
          threshold={0.1}
          rootMargin="-100px"
          textAlign="center"
          onLetterAnimationComplete={handleAnimationComplete}
        />

        <button
          className="bg-[#095564] text-white px-16 py-2 rounded-3xl border-y-1 text-sm md:text-base font-semibold shadow-lg hover:scale-105 transition-transform"
          onClick={() => {
            window.location.href = "/payroll"
          }}
        >
          Transfer Now
        </button>
      </div>

      {/* Social Icons - Right Bottom */}
      <div className="fixed bottom-6 right-6 flex flex-col gap-4 z-20">
        <a
          href="https://github.com/Lexirieru/Nusapay-Core" // ganti link nanti
          target="_blank"
          rel="noopener noreferrer"
          className="p-2 bg-black/50 border border-cyan-500/30 rounded-full hover:scale-110 transition-transform backdrop-blur-sm text-cyan-300"
        >
          <FiGithub size={20} />
        </a>

        <a
          href="https://x.com/nusapayfinance" // ganti link nanti
          target="_blank"
          rel="noopener noreferrer"
          className="p-2 bg-black/50 border border-cyan-500/30 rounded-full hover:scale-110 transition-transform backdrop-blur-sm text-cyan-300"
        >
          <FiTwitter size={20} />
        </a>

        <a
          href="https://nusapay.gitbook.io/nusapay-on-core-1/" // ganti link nanti
          target="_blank"
          rel="noopener noreferrer"
          className="p-2 bg-black/50 border border-cyan-500/30 rounded-full hover:scale-110 transition-transform backdrop-blur-sm text-cyan-300"
        >
          <FiBook size={20} />
        </a>
      </div>
    </div>
  )
}
