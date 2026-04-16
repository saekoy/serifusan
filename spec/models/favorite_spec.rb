require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let(:user) { User.create!(firebase_uid: 'uid-1', email: 'a@example.com') }

  describe 'associations' do
    it 'userに属する' do
      f = Favorite.new(user: user, serifu: 'こんにちは', genre: 'romance')
      expect(f.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'userがなければ無効' do
      f = Favorite.new(serifu: 'こんにちは', genre: 'romance')
      expect(f).to be_invalid
    end

    it 'serifuがなければ無効' do
      f = Favorite.new(user: user, genre: 'romance')
      expect(f).to be_invalid
    end

    it 'genreがなければ無効' do
      f = Favorite.new(user: user, serifu: 'こんにちは')
      expect(f).to be_invalid
    end

    it '同じユーザーで同じセリフは重複保存できない' do
      Favorite.create!(user: user, serifu: 'こんにちは', genre: 'romance')
      f = Favorite.new(user: user, serifu: 'こんにちは', genre: 'daily')
      expect(f).to be_invalid
    end

    it '別ユーザーなら同じセリフを保存できる' do
      other = User.create!(firebase_uid: 'uid-2', email: 'b@example.com')
      Favorite.create!(user: user, serifu: 'こんにちは', genre: 'romance')
      f = Favorite.new(user: other, serifu: 'こんにちは', genre: 'romance')
      expect(f).to be_valid
    end

    it '必須が揃っていれば有効' do
      f = Favorite.new(user: user, serifu: 'またね', genre: 'daily')
      expect(f).to be_valid
    end
  end

  describe 'memo' do
    it 'デフォルトは空文字で保存できる' do
      f = Favorite.create!(user: user, serifu: 'またね', genre: 'daily')
      expect(f.memo).to eq('')
    end

    it '任意で入力できる' do
      f = Favorite.create!(user: user, serifu: 'またね', genre: 'daily', memo: '4/10配信で使った')
      expect(f.reload.memo).to eq('4/10配信で使った')
    end
  end

  describe 'User#favorites' do
    it '関連から取得できる' do
      Favorite.create!(user: user, serifu: 'A', genre: 'romance')
      Favorite.create!(user: user, serifu: 'B', genre: 'daily')
      expect(user.favorites.count).to eq(2)
    end

    it 'user削除時にfavoritesも削除される' do
      Favorite.create!(user: user, serifu: 'A', genre: 'romance')
      expect { user.destroy }.to change(Favorite, :count).by(-1)
    end
  end
end
