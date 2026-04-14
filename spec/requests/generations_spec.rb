require 'rails_helper'

RSpec.describe 'Generations', type: :request do
  let(:serifus) { (1..10).map { |i| "セリフ#{i}" } }

  before do
    allow_any_instance_of(GeminiService).to receive(:call).and_return(serifus)
  end

  describe 'POST /generations' do
    let(:valid_params) { { genre: 'romance', theme: '雨の日の告白' } }

    it '結果ページにリダイレクトする' do
      post '/generations', params: valid_params
      expect(response).to redirect_to('/result')
    end

    it 'セッションに結果を保存する' do
      post '/generations', params: valid_params
      expect(session[:latest_generation]).to be_present
      expect(session[:latest_generation]['serifus']).to eq(serifus)
      expect(session[:latest_generation]['genre']).to eq('romance')
    end

    it '未ログインの生成回数カウントを増やす' do
      post '/generations', params: valid_params
      expect(session[:gen_count]).to eq(1)
    end

    it '2回目の生成でカウントが2になる' do
      post '/generations', params: valid_params
      post '/generations', params: valid_params
      expect(session[:gen_count]).to eq(2)
    end

    context 'GeminiServiceが空配列を返した場合（API失敗）' do
      before do
        allow_any_instance_of(GeminiService).to receive(:call).and_return([])
      end

      it 'ホームにリダイレクトする' do
        post '/generations', params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it 'エラーメッセージをflashに入れる' do
        post '/generations', params: valid_params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET /result' do
    context 'セッションに結果がある場合' do
      before { post '/generations', params: { genre: 'romance', theme: '雨の日の告白' } }

      it '200を返す' do
        get '/result'
        expect(response).to have_http_status(:success)
      end

      it '10件のセリフを表示する' do
        get '/result'
        serifus.each do |s|
          expect(response.body).to include(s)
        end
      end

      it 'ジャンル名バッジを表示する' do
        get '/result'
        expect(response.body).to include('恋愛・甘々')
      end
    end

    context 'セッションに結果がない場合' do
      it 'ホームにリダイレクトする' do
        get '/result'
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
