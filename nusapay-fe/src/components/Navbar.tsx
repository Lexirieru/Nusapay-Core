"use client";

import { ConnectWallet } from "./ConnectWallet";
import Link from "next/link";
import { usePathname } from "next/navigation";

export function Navbar() {
  const pathname = usePathname();

  const navItems = [
    { name: "Payroll Dashboard", href: "/payroll" },
    { name: "Faucet", href: "/faucet" },
    { name: "History", href: "/history" },
  ];

  return (
    <nav className="fixed top-0 z-50 w-full backdrop-blur-xl backdrop-saturate-200 bg-white/5 shadow-md">
      <div className="max-w-7xl mx-auto px-6 sm:px-8">
        <div className="flex justify-between items-center py-4">
          <div className="flex items-center space-x-8">
            <div>
              <Link href="/" className="block">
                <h1 className="text-2xl font-bold text-white">NusaPay</h1>
                <p className="text-gray-300 text-sm">
                  Cross-Chain Payment System
                </p>
              </Link>
            </div>

            <div className="hidden md:flex space-x-6">
              {navItems.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                    pathname === item.href
                      ? "bg-cyan-400/20 text-cyan-400"
                      : "text-gray-300 hover:text-white hover:bg-white/10"
                  }`}
                >
                  {item.name}
                </Link>
              ))}
            </div>
          </div>

          <ConnectWallet />
        </div>
      </div>
    </nav>
  );
}
