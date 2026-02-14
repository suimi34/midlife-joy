class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :photo
  has_many :reactions, dependent: :destroy

  validates :body, presence: true, length: { maximum: 20 }
  validate :body_format

  scope :tonight, -> {
    now = Time.current
    start_time = now.hour < 3 ? now.yesterday.change(hour: 18) : now.change(hour: 18)
    end_time = start_time + 9.hours
    where(created_at: start_time..end_time)
  }

  scope :feed, -> { tonight.order(created_at: :desc).limit(10) }

  private

  def body_format
    return if body.blank?

    errors.add(:body, "に改行は使えません") if body.include?("\n")
    errors.add(:body, "に絵文字は使えません") if body.match?(/\p{Emoji_Presentation}/)
    errors.add(:body, "にハッシュタグは使えません") if body.include?("#")
  end
end
