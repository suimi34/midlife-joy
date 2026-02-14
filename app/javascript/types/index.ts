export type FlashData = {
  notice?: string
  alert?: string
}

export type User = {
  id: number
  display_name: string | null
  avatar_url: string | null
}

export type Post = {
  id: number
  body: string
  reactions_count: number
  created_at: string
  user: User
  photo_url: string | null
  reacted: boolean
}

export type SharedProps = {
  current_user: User | null
  flash: FlashData
}
