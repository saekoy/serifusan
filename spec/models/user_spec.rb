require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'firebase_uidがなければ無効' do
      u = User.new(email: 'a@example.com')
      expect(u).to be_invalid
    end

    it 'firebase_uidが重複すると無効' do
      User.create!(firebase_uid: 'uid-1', email: 'a@example.com')
      u = User.new(firebase_uid: 'uid-1', email: 'b@example.com')
      expect(u).to be_invalid
    end

    it 'firebase_uidがあれば有効（emailは任意）' do
      expect(User.new(firebase_uid: 'uid-1')).to be_valid
    end
  end

  describe 'associations' do
    it 'generationsを複数もてる' do
      user = User.create!(firebase_uid: 'uid-1', email: 'a@example.com')
      user.generations.create!(genre: 'romance', theme: 'T', serifus: ['a'])
      user.generations.create!(genre: 'daily',   theme: 'T2', serifus: ['b'])
      expect(user.generations.count).to eq(2)
    end
  end
end
