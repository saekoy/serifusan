require 'rails_helper'

RSpec.describe 'Favorites', type: :request do
  let(:verified_payload) do
    { uid: 'uid-1', email: 'a@example.com', display_name: 'A', photo_url: nil, provider: 'google.com' }
  end

  def sign_in!
    allow(FirebaseTokenVerifier).to receive(:verify).and_return(verified_payload)
    post '/sessions', params: { id_token: 'valid' }
  end

  describe 'GET /favorites' do
    context '未ログイン時' do
      before { get '/favorites' }

      it '200を返す' do
        expect(response).to have_http_status(:success)
      end

      it 'ログイン誘導メッセージを表示する' do
        expect(response.body).to include('いいねしたセリフは、ログインするといつでも見返せます')
      end

      it 'ログインCTAが表示される' do
        expect(response.body).to include('data-gis-button')
      end

      it 'ボトムナビが表示される' do
        expect(response.body).to include('いいね')
      end
    end

    context 'ログイン時' do
      before { sign_in! }

      context 'お気に入りがない場合' do
        it '空メッセージを表示する' do
          get '/favorites'
          expect(response.body).to include('まだいいねしたセリフはありません')
        end
      end

      context 'お気に入りがある場合' do
        let(:user) { User.find_by(firebase_uid: 'uid-1') }

        before do
          Favorite.create!(user: user, serifu: 'ずっとそばにいてね', genre: 'romance', created_at: 2.days.ago)
          Favorite.create!(user: user, serifu: '別に心配じゃないし', genre: 'tsundere', created_at: 1.day.ago)
        end

        it 'セリフを表示する' do
          get '/favorites'
          expect(response.body).to include('ずっとそばにいてね')
          expect(response.body).to include('別に心配じゃないし')
        end

        it 'ジャンル名を表示する' do
          get '/favorites'
          expect(response.body).to include('恋愛・甘々')
          expect(response.body).to include('ツンデレ')
        end

        it '新しい順に表示する' do
          get '/favorites'
          pos_new = response.body.index('別に心配じゃないし')
          pos_old = response.body.index('ずっとそばにいてね')
          expect(pos_new).to be < pos_old
        end

        it '他ユーザーのお気に入りは表示しない' do
          other = User.create!(firebase_uid: 'other', email: 'b@example.com')
          Favorite.create!(user: other, serifu: '他人のひみつセリフ', genre: 'fantasy')
          get '/favorites'
          expect(response.body).not_to include('他人のひみつセリフ')
        end

        it '?genre=romance でロマンスだけ表示する' do
          get '/favorites', params: { genre: 'romance' }
          expect(response.body).to     include('ずっとそばにいてね')
          expect(response.body).not_to include('別に心配じゃないし')
        end
      end
    end
  end

  describe 'POST /favorites' do
    let(:valid_params) { { serifu: 'またねって言って', genre: 'romance' } }

    context '未ログイン時' do
      it '401を返す' do
        post '/favorites', params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'Favoriteを作成しない' do
        expect do
          post '/favorites', params: valid_params
        end.not_to change(Favorite, :count)
      end
    end

    context 'ログイン時' do
      before { sign_in! }

      it 'Favoriteを作成する' do
        expect do
          post '/favorites', params: valid_params
        end.to change(Favorite, :count).by(1)
      end

      it 'ログイン中ユーザーに紐づく' do
        post '/favorites', params: valid_params
        expect(Favorite.last.user).to eq(User.find_by(firebase_uid: 'uid-1'))
      end

      it 'serifu/genreが保存される' do
        post '/favorites', params: valid_params
        f = Favorite.last
        expect(f.serifu).to eq('またねって言って')
        expect(f.genre).to eq('romance')
      end

      it '同じセリフの2回目は作成しない（重複防止）' do
        post '/favorites', params: valid_params
        expect do
          post '/favorites', params: valid_params
        end.not_to change(Favorite, :count)
      end
    end
  end

  describe 'PATCH /favorites/:id' do
    let(:user) { User.find_by(firebase_uid: 'uid-1') }

    context 'ログイン時' do
      before { sign_in! }

      it '自分のFavoriteのmemoを更新できる' do
        fav = Favorite.create!(user: user, serifu: 'メモ付けたい', genre: 'daily')
        patch "/favorites/#{fav.id}", params: { memo: '4/15配信で使った' }
        expect(fav.reload.memo).to eq('4/15配信で使った')
      end

      it '他ユーザーのFavoriteは更新できない' do
        other = User.create!(firebase_uid: 'other', email: 'b@example.com')
        fav = Favorite.create!(user: other, serifu: '他人のやつ', genre: 'daily', memo: '元のメモ')
        patch "/favorites/#{fav.id}", params: { memo: 'いじっちゃだめ' }
        expect(fav.reload.memo).to eq('元のメモ')
      end
    end

    context '未ログイン時' do
      it '401を返す' do
        u = User.create!(firebase_uid: 'uid-1', email: 'a@example.com')
        fav = Favorite.create!(user: u, serifu: 'だめ', genre: 'daily')
        patch "/favorites/#{fav.id}", params: { memo: 'x' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /favorites/:id' do
    let(:user) { User.find_by(firebase_uid: 'uid-1') }

    context 'ログイン時' do
      before { sign_in! }

      it '自分のFavoriteを削除できる' do
        fav = Favorite.create!(user: user, serifu: '消してね', genre: 'daily')
        expect do
          delete "/favorites/#{fav.id}"
        end.to change(Favorite, :count).by(-1)
      end

      it '他ユーザーのFavoriteは削除できない' do
        other = User.create!(firebase_uid: 'other', email: 'b@example.com')
        fav = Favorite.create!(user: other, serifu: 'ひと様のお気に入り', genre: 'daily')
        expect do
          delete "/favorites/#{fav.id}"
        end.not_to change(Favorite, :count)
      end
    end

    context '未ログイン時' do
      it '401を返す' do
        user = User.create!(firebase_uid: 'uid-1', email: 'a@example.com')
        fav = Favorite.create!(user: user, serifu: '消えないで', genre: 'daily')
        delete "/favorites/#{fav.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
