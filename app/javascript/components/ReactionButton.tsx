import { router } from "@inertiajs/react"

type Props = {
  postId: number
  reacted: boolean
  count: number
}

export default function ReactionButton({ postId, reacted, count }: Props) {
  const handleClick = () => {
    if (reacted) {
      router.delete(`/reactions/${postId}`, { preserveScroll: true })
    } else {
      router.post("/reactions", { post_id: postId }, { preserveScroll: true })
    }
  }

  return (
    <button
      onClick={handleClick}
      className={`text-sm ${reacted ? "text-accent" : "text-muted"}`}
    >
      🟫 {count > 0 && count}
    </button>
  )
}
