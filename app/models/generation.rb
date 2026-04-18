class Generation < ApplicationRecord
  belongs_to :user

  serialize :serifus, coder: JSON, type: Array

  validates :genre,   presence: true
  validates :serifus, presence: true
  validate  :serifus_must_not_be_empty

  private

  def serifus_must_not_be_empty
    errors.add(:serifus, 'must not be empty') if serifus.blank? || serifus.empty?
  end
end
