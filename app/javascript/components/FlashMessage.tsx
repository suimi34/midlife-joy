import { usePage } from "@inertiajs/react"
import type { SharedProps } from "@/types"

export default function FlashMessage() {
  const { flash } = usePage<SharedProps>().props

  if (!flash.notice && !flash.alert) return null

  return (
    <div className="mb-6">
      {flash.notice && (
        <p className="text-sm text-muted">{flash.notice}</p>
      )}
      {flash.alert && (
        <p className="text-sm text-red-400">{flash.alert}</p>
      )}
    </div>
  )
}
