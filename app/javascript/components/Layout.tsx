import type { ReactNode } from "react"

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-bg text-text">
      <div className="mx-auto max-w-lg px-4 py-8">
        {children}
      </div>
    </div>
  )
}
