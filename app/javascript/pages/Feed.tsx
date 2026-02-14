import Layout from "@/components/Layout"
import FlashMessage from "@/components/FlashMessage"
import PostForm from "@/components/PostForm"
import PostCard from "@/components/PostCard"
import type { Post } from "@/types"

type Props = {
  posts: Post[]
}

export default function Feed({ posts }: Props) {
  return (
    <Layout>
      <h1 className="mb-8 text-center text-2xl font-bold text-text">
        今夜の至福
      </h1>

      <FlashMessage />
      <PostForm />

      <div className="divide-y divide-muted/20">
        {posts.length === 0 ? (
          <p className="py-12 text-center text-muted">
            まだ投稿がありません
          </p>
        ) : (
          posts.map((post) => <PostCard key={post.id} post={post} />)
        )}
      </div>
    </Layout>
  )
}
