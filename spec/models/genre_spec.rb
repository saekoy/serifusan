require 'rails_helper'

RSpec.describe Genre, type: :model do
  describe '.all' do
    it '6件のジャンルを返す' do
      expect(Genre.all.size).to eq(6)
    end

    it '各ジャンルは slug / name / emoji を持つ' do
      Genre.all.each do |g|
        expect(g).to include(:slug, :name, :emoji)
      end
    end

    it '想定のslugがすべて含まれる' do
      slugs = Genre.all.map { |g| g[:slug] }
      expect(slugs).to contain_exactly('romance', 'tsundere', 'fantasy', 'daily', 'comedy', 'random')
    end
  end

  describe '.find' do
    it '存在するslugで該当ジャンルを返す' do
      genre = Genre.find('romance')
      expect(genre[:name]).to eq('恋愛・甘々')
      expect(genre[:emoji]).to eq('💕')
    end

    it '存在しないslugでnilを返す' do
      expect(Genre.find('unknown')).to be_nil
    end
  end
end
