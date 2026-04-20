require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    before { get '/' }

    it '200を返す' do
      expect(response).to have_http_status(:success)
    end

    it 'タイトル「セリフさん」が表示される' do
      expect(response.body).to include('セリフさん')
    end

    it '6つのジャンル名が表示される' do
      %w[恋愛・甘々 ツンデレ ファンタジー 日常・癒し コメディ おまかせ].each do |name|
        expect(response.body).to include(name)
      end
    end

    it 'テーマ入力欄（textarea）がある' do
      expect(response.body).to match(/<textarea[^>]*name="theme"/)
    end

    it '生成ボタンが表示される' do
      expect(response.body).to include('セリフを生成する')
    end

    it 'ログインボタンが表示される（未ログイン時）' do
      expect(response.body).to include('ログイン')
    end

    it '今日の残り回数が 3/3 で表示される（未ログイン初期状態）' do
      expect(response.body).to include('3 / 3')
    end

    it 'ボトムナビ4項目が表示される' do
      %w[ホーム いいね 履歴 設定].each do |label|
        expect(response.body).to include(label)
      end
    end

    it 'ローディングオーバーレイ（hidden状態）がレイアウトに埋め込まれている' do
      expect(response.body).to include('id="loading-overlay"')
      expect(response.body).to include('セリフを考えているよ')
    end
  end

  describe 'flashメッセージの表示' do
    it 'flash[:alert] があればアラートバナーが表示される' do
      allow_any_instance_of(GeminiService).to receive(:call).and_return([])
      post '/generations', params: { genre: 'romance', theme: 'test' }
      follow_redirect!
      expect(response.body).to include('セリフ生成に失敗しました')
    end

    it '3回生成後の4回目は上限超過アラートが表示される' do
      fake_serifus = (1..10).map { |i| "セリフ#{i}" }
      allow_any_instance_of(GeminiService).to receive(:call).and_return(fake_serifus)
      3.times { post '/generations', params: { genre: 'romance', theme: 'test' } }
      post '/generations', params: { genre: 'romance', theme: 'test' }
      follow_redirect!
      expect(response.body).to include('今日の生成回数を使い切りました')
    end
  end
end
