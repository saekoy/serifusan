class Contact < ApplicationRecord
  validates :name,  presence: true, length: { maximum: 50 }
  validates :email, length: { maximum: 254 }, allow_blank: true
  validates :body,  presence: true, length: { maximum: 2000 }
end
