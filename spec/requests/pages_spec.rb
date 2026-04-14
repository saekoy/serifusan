require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /about' do
    before { get '/about' }

    it '200を返す' do
      expect(response).to have_http_status(:success)
    end

    it 'つくったきっかけのセクションが表示される' do
      expect(response.body).to include('つくったきっかけ')
    end

    it 'AIの利用についてのセクションが表示される' do
      expect(response.body).to include('AIの利用について')
    end

    it 'お問い合わせのセクションが表示される' do
      expect(response.body).to include('お問い合わせ')
    end

    it 'ボトムナビにアプリについてが表示される' do
      expect(response.body).to include('アプリについて')
    end

    context '未ログイン時' do
      it 'ログインしていない旨の表示がある' do
        expect(response.body).to include('ログインしていません')
      end
    end
  end
end
