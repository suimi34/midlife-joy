class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :reactions, dependent: :destroy

  validates :firebase_uid, presence: true, uniqueness: true

  def self.find_or_create_from_firebase(payload)
    find_or_create_by!(firebase_uid: payload["sub"]) do |user|
      user.display_name = payload["name"]
      user.avatar_url = payload["picture"]
    end
  end
end
