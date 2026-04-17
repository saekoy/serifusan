class Favorite < ApplicationRecord
  SERIFU_MAX_LENGTH = 500
  MEMO_MAX_LENGTH   = 300

  belongs_to :user

  validates :serifu, presence: true, length: { maximum: SERIFU_MAX_LENGTH }
  validates :serifu, uniqueness: { scope: :user_id }
  validates :memo,   length: { maximum: MEMO_MAX_LENGTH }, allow_blank: true
  validates :genre,  presence: true, inclusion: { in: ->(_) { Genre::LIST.map { |g| g[:slug] } } }
end
