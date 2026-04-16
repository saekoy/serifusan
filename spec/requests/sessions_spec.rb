require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:verified_payload) do
    {
      uid: 'firebase-uid-123',
      email: 'test@example.com',
      display_name: 'テスト花子',
      photo_url: 'https://example.com/avatar.jpg',
      provider: 'google.com'
    }
  end

  describe 'POST /sessions' do
    context '有効なIDトークンの場合' do
      before do
        allow(FirebaseTokenVerifier).to receive(:verify).with('valid-token').and_return(verified_payload)
      end

      it '200を返す' do
        post '/sessions', params: { id_token: 'valid-token' }
        expect(response).to have_http_status(:success)
      end

      it 'Userを新規作成する' do
        expect do
          post '/sessions', params: { id_token: 'valid-token' }
        end.to change(User, :count).by(1)
      end

      it '作成されたUserに Firebase の情報が入る' do
        post '/sessions', params: { id_token: 'valid-token' }
        user = User.last
        expect(user.firebase_uid).to  eq('firebase-uid-123')
        expect(user.email).to         eq('test@example.com')
        expect(user.display_name).to  eq('テスト花子')
        expect(user.provider).to      eq('google.com')
      end

      it 'session[:user_id] に保存する' do
        post '/sessions', params: { id_token: 'valid-token' }
        expect(session[:user_id]).to eq(User.last.id)
      end

      it '既存ユーザーの場合は新規作成しない' do
        User.create!(firebase_uid: 'firebase-uid-123', email: 'old@example.com')
        expect do
          post '/sessions', params: { id_token: 'valid-token' }
        end.not_to change(User, :count)
      end

      it '既存ユーザーの情報は最新に更新される' do
        User.create!(firebase_uid: 'firebase-uid-123', display_name: '昔の名前')
        post '/sessions', params: { id_token: 'valid-token' }
        expect(User.last.display_name).to eq('テスト花子')
      end
    end

    context '無効なIDトークンの場合' do
      before do
        allow(FirebaseTokenVerifier).to receive(:verify)
          .and_raise(FirebaseTokenVerifier::VerificationError, 'Invalid signature')
      end

      it '401を返す' do
        post '/sessions', params: { id_token: 'bad-token' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'Userを作成しない' do
        expect do
          post '/sessions', params: { id_token: 'bad-token' }
        end.not_to change(User, :count)
      end

      it 'session[:user_id] に保存しない' do
        post '/sessions', params: { id_token: 'bad-token' }
        expect(session[:user_id]).to be_nil
      end
    end

    context 'id_token が欠けている場合' do
      it '400を返す' do
        post '/sessions', params: {}
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'DELETE /sessions' do
    it 'session[:user_id] を消す' do
      post '/sessions', params: { id_token: 'valid-token' }
      delete '/sessions'
      expect(session[:user_id]).to be_nil
    end

    it '200を返す' do
      delete '/sessions'
      expect(response).to have_http_status(:success)
    end
  end
end
