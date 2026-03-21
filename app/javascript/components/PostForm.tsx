import { useForm } from "@inertiajs/react"
import type { FormEvent, ChangeEvent } from "react"
import { BREWING_METHODS } from "@/types"
import type { BrewingMethodValue } from "@/types"

export default function PostForm() {
  const { data, setData, post, processing, errors, reset } = useForm<{
    post: {
      body: string
      photo: File | null
      brewing_method: BrewingMethodValue | ""
    }
  }>({
    post: {
      body: "",
      photo: null,
      brewing_method: "",
    },
  })

  const handleBodyChange = (e: ChangeEvent<HTMLInputElement>) => {
    let value = e.target.value
    value = value.replace(/\n/g, "")
    value = value.replace(/#/g, "")
    value = value.replace(/\p{Emoji_Presentation}/gu, "")
    setData("post", { ...data.post, body: value })
  }

  const handleBrewingMethod = (value: BrewingMethodValue) => {
    const next = data.post.brewing_method === value ? "" : value
    setData("post", { ...data.post, brewing_method: next })
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
        value={data.post.body}
        onChange={handleBodyChange}
        maxLength={20}
        placeholder="今夜の一言（20文字）"
        className="w-full rounded border border-muted/30 bg-transparent px-4 py-3 text-text placeholder-muted focus:border-accent focus:outline-none"
      />

      <div className="mt-3 flex flex-wrap gap-2">
        {BREWING_METHODS.map((m) => (
          <button
            key={m.value}
            type="button"
            onClick={() => handleBrewingMethod(m.value)}
            className={`rounded-full border px-3 py-1 text-xs transition-colors ${
              data.post.brewing_method === m.value
                ? "border-accent bg-accent text-text"
                : "border-muted/30 text-muted hover:border-muted"
            }`}
          >
            {m.label}
          </button>
        ))}
      </div>

      <div className="mt-3 flex items-center justify-between">
        <label className="cursor-pointer text-sm text-muted">
          写真を添付
          <input
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => setData("post", { ...data.post, photo: e.target.files?.[0] ?? null })}
          />
        </label>

        <button
          type="submit"
          disabled={processing || data.post.body.length === 0}
          className="rounded bg-accent px-4 py-2 text-sm text-text disabled:opacity-40"
        >
          投稿
        </button>
      </div>

      {errors["post.body"] && (
        <p className="mt-2 text-xs text-red-400">{errors["post.body"]}</p>
      )}
      {errors["post.brewing_method"] && (
        <p className="mt-2 text-xs text-red-400">{errors["post.brewing_method"]}</p>
      )}
    </form>
  )
}
