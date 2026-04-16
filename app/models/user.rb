class User < ApplicationRecord
  has_many :generations, dependent: :destroy
  has_many :favorites,   dependent: :destroy

  validates :firebase_uid, presence: true, uniqueness: true
end
