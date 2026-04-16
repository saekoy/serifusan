require 'rails_helper'

RSpec.describe 'Histories', type: :request do
  describe 'GET /history' do
    context '未ログイン時' do
      before { get '/history' }

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
        expect(response.body).to include('履歴')
      end
    end

    context 'ログイン時' do
      let(:verified_payload) do
        { uid: 'uid-1', email: 'a@example.com', display_name: 'A', photo_url: nil, provider: 'google.com' }
      end

      before do
        allow(FirebaseTokenVerifier).to receive(:verify).and_return(verified_payload)
        post '/sessions', params: { id_token: 'valid' }
      end

      context '履歴がない場合' do
        it '200を返す' do
          get '/history'
          expect(response).to have_http_status(:success)
        end

        it '空メッセージを表示する' do
          get '/history'
          expect(response.body).to include('まだ生成履歴はありません')
        end
      end

      context '履歴がある場合' do
        let(:user) { User.find_by(firebase_uid: 'uid-1') }

        before do
          Generation.create!(user: user, genre: 'romance',  theme: '雨の日の告白', serifus: ['好きです'], created_at: 2.days.ago)
          Generation.create!(user: user, genre: 'tsundere', theme: 'ツンデレ特訓', serifus: ['別に'], created_at: 1.day.ago)
        end

        it '各履歴のテーマを表示する' do
          get '/history'
          expect(response.body).to include('雨の日の告白')
          expect(response.body).to include('ツンデレ特訓')
        end

        it 'ジャンル名を表示する' do
          get '/history'
          expect(response.body).to include('恋愛・甘々')
          expect(response.body).to include('ツンデレ')
        end

        it '新しい順に表示する' do
          get '/history'
          pos_new = response.body.index('ツンデレ特訓')
          pos_old = response.body.index('雨の日の告白')
          expect(pos_new).to be < pos_old
        end

        it '他ユーザーの履歴は表示しない' do
          other = User.create!(firebase_uid: 'other-uid', email: 'b@example.com')
          Generation.create!(user: other, genre: 'fantasy', theme: '他人の秘密テーマ', serifus: ['x'])
          get '/history'
          expect(response.body).not_to include('他人の秘密テーマ')
        end

        it '?genre=romance でロマンスだけ表示する' do
          get '/history', params: { genre: 'romance' }
          expect(response.body).to     include('雨の日の告白')
          expect(response.body).not_to include('ツンデレ特訓')
        end
      end
    end
  end
end
