import { router } from "@inertiajs/react"
import { signInWithPopup } from "firebase/auth"
import { auth, googleProvider } from "@/lib/firebase"
import Layout from "@/components/Layout"

export default function Login() {
  const handleGoogleLogin = async () => {
    try {
      const result = await signInWithPopup(auth, googleProvider)
      const token = await result.user.getIdToken()
      router.post("/sessions", { token })
    } catch {
      // Firebase sign-in cancelled or failed
    }
  }

  return (
    <Layout>
      <div className="flex min-h-[60vh] flex-col items-center justify-center">
        <h1 className="mb-4 text-3xl font-bold text-text">今夜の至福</h1>
        <p className="mb-12 text-muted">静かな時間を、そっと置く場所</p>

        <button
          onClick={handleGoogleLogin}
          className="rounded bg-accent px-6 py-3 text-text"
        >
          Googleでログイン
        </button>
      </div>
    </Layout>
  )
}
