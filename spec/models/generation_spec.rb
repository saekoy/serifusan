require 'rails_helper'

RSpec.describe Generation, type: :model do
  let(:user) { User.create!(firebase_uid: 'uid-1', email: 'a@example.com') }

  describe 'associations' do
    it 'userに属する' do
      g = Generation.new(user: user, genre: 'romance', theme: 'テーマ', serifus: ['A'])
      expect(g.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'userがなければ無効' do
      g = Generation.new(genre: 'romance', theme: 'テーマ', serifus: ['A'])
      expect(g).to be_invalid
    end

    it 'genreがなければ無効' do
      g = Generation.new(user: user, theme: 'テーマ', serifus: ['A'])
      expect(g).to be_invalid
    end

    it 'themeがなくても有効（テーマ任意）' do
      g = Generation.new(user: user, genre: 'romance', serifus: ['A'])
      expect(g).to be_valid
    end

    it 'serifusが空配列なら無効' do
      g = Generation.new(user: user, genre: 'romance', theme: 'テーマ', serifus: [])
      expect(g).to be_invalid
    end

    it '必須が揃っていれば有効' do
      g = Generation.new(user: user, genre: 'romance', theme: 'テーマ', serifus: %w[A B])
      expect(g).to be_valid
    end
  end

  describe 'serifus (JSON配列保存)' do
    it '配列として保存・取得できる' do
      g = Generation.create!(user: user, genre: 'romance', theme: 'テーマ', serifus: %w[こんにちは またね])
      expect(Generation.find(g.id).serifus).to eq(%w[こんにちは またね])
    end
  end

  describe 'User#generations' do
    it '関連から取得できる' do
      Generation.create!(user: user, genre: 'romance', theme: 'T1', serifus: ['a'])
      expect(user.generations.count).to eq(1)
    end

    it 'user削除時にgenerationsも削除される' do
      Generation.create!(user: user, genre: 'romance', theme: 'T1', serifus: ['a'])
      expect { user.destroy }.to change(Generation, :count).by(-1)
    end
  end
end
