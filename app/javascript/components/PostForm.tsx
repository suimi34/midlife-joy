import { useForm } from "@inertiajs/react"
import type { FormEvent, ChangeEvent } from "react"

export default function PostForm() {
  const { data, setData, post, processing, errors, reset } = useForm<{
    body: string
    photo: File | null
  }>({
    body: "",
    photo: null,
  })

  const handleBodyChange = (e: ChangeEvent<HTMLInputElement>) => {
    let value = e.target.value
    value = value.replace(/\n/g, "")
    value = value.replace(/#/g, "")
    value = value.replace(/\p{Emoji_Presentation}/gu, "")
    setData("body", value)
  }

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    post("/posts", {
      forceFormData: true,
      onSuccess: () => reset(),
    })
  }

  return (
    <form onSubmit={handleSubmit} className="mb-8">
      <input
        type="text"
        value={data.body}
        onChange={handleBodyChange}
        maxLength={20}
        placeholder="今夜の一言（20文字）"
        className="w-full rounded border border-muted/30 bg-transparent px-4 py-3 text-text placeholder-muted focus:border-accent focus:outline-none"
      />

      <div className="mt-3 flex items-center justify-between">
        <label className="cursor-pointer text-sm text-muted">
          写真を添付
          <input
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => setData("photo", e.target.files?.[0] ?? null)}
          />
        </label>

        <button
          type="submit"
          disabled={processing || data.body.length === 0}
          className="rounded bg-accent px-4 py-2 text-sm text-text disabled:opacity-40"
        >
          投稿
        </button>
      </div>

      {errors.body && (
        <p className="mt-2 text-xs text-red-400">{errors.body}</p>
      )}
    </form>
  )
}
