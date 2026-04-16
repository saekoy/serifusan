class Favorite < ApplicationRecord
  belongs_to :user

  validates :serifu, presence: true
  validates :genre,  presence: true
  validates :serifu, uniqueness: { scope: :user_id }
end
