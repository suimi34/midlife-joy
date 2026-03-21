export type FlashData = {
  notice?: string;
  alert?: string;
};

export type User = {
  id: number;
  display_name: string | null;
  avatar_url: string | null;
};

export const BREWING_METHODS = [
  { value: "drip", label: "ドリップ" },
  { value: "espresso", label: "エスプレッソ" },
  { value: "instant", label: "インスタント" },
  { value: "moka_pot", label: "マキネッタ" },
  { value: "french_press", label: "フレンチプレス" },
  { value: "aeropress", label: "エアロプレス" },
  { value: "siphon", label: "サイフォン" },
  { value: "cold_brew", label: "水出し" },
] as const;

export type BrewingMethodValue = (typeof BREWING_METHODS)[number]["value"];

export type Post = {
  id: number;
  body: string;
  brewing_method: BrewingMethodValue | null;
  reactions_count: number;
  created_at: string;
  user: User;
  photo_url: string | null;
  reacted: boolean;
};

export type SharedProps = {
  current_user: User | null;
  flash: FlashData;
};
