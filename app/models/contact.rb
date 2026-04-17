class Contact < ApplicationRecord
  validates :name,  presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 254 }
  validates :body,  presence: true, length: { maximum: 2000 }
end
