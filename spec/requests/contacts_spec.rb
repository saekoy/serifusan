require 'rails_helper'

RSpec.describe 'Contacts', type: :request do
  describe 'GET /contact' do
    it 'フォームを表示する' do
      get '/contact'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('お問い合わせ')
    end
  end

  describe 'POST /contact' do
    let(:valid_params) { { contact: { name: 'テスト', email: 'test@example.com', body: 'テスト本文' } } }

    it '正常な入力でContactを保存する' do
      expect do
        post '/contact', params: valid_params
      end.to change(Contact, :count).by(1)
    end

    it '保存後aboutページにリダイレクトする' do
      post '/contact', params: valid_params
      expect(response).to redirect_to(about_path)
      follow_redirect!
      expect(response.body).to include('お問い合わせを送信しました')
    end

    it '名前が空だと保存しない' do
      expect do
        post '/contact', params: { contact: { name: '', email: 'test@example.com', body: '本文' } }
      end.not_to change(Contact, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'メールが空でも保存できる' do
      expect do
        post '/contact', params: { contact: { name: 'テスト', email: '', body: '本文' } }
      end.to change(Contact, :count).by(1)
    end

    it '本文が空だと保存しない' do
      expect do
        post '/contact', params: { contact: { name: 'テスト', email: 'test@example.com', body: '' } }
      end.not_to change(Contact, :count)
    end

    it '本文が2000文字を超えると保存しない' do
      expect do
        post '/contact', params: { contact: { name: 'テスト', email: 'test@example.com', body: 'あ' * 2001 } }
      end.not_to change(Contact, :count)
    end
  end
end
