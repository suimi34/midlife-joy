import ReactionButton from "@/components/ReactionButton"
import type { Post } from "@/types"

function timeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime()
  const minutes = Math.floor(diff / 60000)
  if (minutes < 1) return "たった今"
  if (minutes < 60) return `${minutes}分前`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}時間前`
  return `${Math.floor(hours / 24)}日前`
}

export default function PostCard({ post }: { post: Post }) {
  return (
    <div className="py-6">
      <p className="text-xs text-muted">
        {post.user.display_name ?? "名無し"}
      </p>

      {post.photo_url && (
        <img
          src={post.photo_url}
          alt=""
          className="mt-3 w-full rounded"
        />
      )}

      <p className="mt-3 text-lg text-text">{post.body}</p>

      <div className="mt-3 flex items-center justify-between">
        <ReactionButton
          postId={post.id}
          reacted={post.reacted}
          count={post.reactions_count}
        />
        <span className="text-xs text-muted">{timeAgo(post.created_at)}</span>
      </div>
    </div>
  )
}
