class Generation < ApplicationRecord
  belongs_to :user

  serialize :serifus, coder: JSON, type: Array

  validates :genre,   presence: true
  # presence: true は nil を弾くだけで [] (空配列) は通すため、空配列を弾くカスタム検証も併用する
  validates :serifus, presence: true
  validate  :serifus_must_not_be_empty

  private

  def serifus_must_not_be_empty
    errors.add(:serifus, 'must not be empty') if serifus.blank? || serifus.empty?
  end
end
