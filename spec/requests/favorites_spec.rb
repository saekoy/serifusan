require 'rails_helper'

RSpec.describe 'Favorites', type: :request do
  describe 'GET /favorites' do
    before { get '/favorites' }

    context '未ログイン時' do
      it '200を返す' do
        expect(response).to have_http_status(:success)
      end

      it 'ログイン誘導メッセージを表示する' do
        expect(response.body).to include('ログインが必要です')
      end

      it 'ログインCTAが表示される' do
        expect(response.body).to include('ログインする')
      end

      it 'ボトムナビが表示される' do
        expect(response.body).to include('お気に入り')
      end
    end
  end
end
