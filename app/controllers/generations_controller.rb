class GenerationsController < ApplicationController
  # Gemini API 悪用・過課金防止のための上限
  THEME_MAX_LENGTH        = 200
  CHARACTER_MAX_LENGTH    = 300
  FIRST_PERSON_MAX_LENGTH = 20
  TONE_MAX_LENGTH         = 20
  LOGGED_IN_DAILY_LIMIT   = ENV.fetch('LOGGED_IN_DAILY_LIMIT', 30).to_i

  def create
    # 入力長ガード（長文プロンプトでの過課金防止）
    if params[:theme].to_s.length        > THEME_MAX_LENGTH ||
       params[:character].to_s.length    > CHARACTER_MAX_LENGTH ||
       params[:first_person].to_s.length > FIRST_PERSON_MAX_LENGTH ||
       params[:tone].to_s.length         > TONE_MAX_LENGTH
      redirect_to root_path, alert: '入力が長すぎます。短くしてもう一度お試しください。'
      return
    end

    # ジャンルガード（未知のslugでAIに変なプロンプトを送らない）
    unless Genre.find(params[:genre])
      redirect_to root_path, alert: 'ジャンルの指定が不正です。'
      return
    end

    # レート制限（未ログイン：セッション内カウント／ログイン：DB内カウント）
    if logged_in?
      if current_user.generations.where(created_at: Time.current.all_day).count >= self.class::LOGGED_IN_DAILY_LIMIT
        redirect_to root_path, alert: '今日の生成回数を使い切りました。また明日お試しください。'
        return
      end
    elsif generation_count_today >= DAILY_GENERATION_LIMIT
      redirect_to root_path, alert: '今日の生成回数を使い切りました。ログインすると回数が増えます。'
      return
    end

    serifus = GeminiService.new(
      genre: params[:genre],
      theme: params[:theme],
      first_person: params[:first_person],
      tone: params[:tone],
      character: params[:character]
    ).call

    if serifus.empty?
      redirect_to root_path, alert: 'セリフ生成に失敗しました。少し時間をおいて再度お試しください。'
      return
    end

    session[:latest_generation] = {
      'genre'      => params[:genre],
      'theme'      => params[:theme],
      'serifus'    => serifus,
      'created_at' => Time.current.iso8601
    }

    if logged_in?
      current_user.generations.create!(
        genre:   params[:genre],
        theme:   params[:theme],
        serifus: serifus
      )
    else
      increment_generation_count
    end

    redirect_to result_path
  end

  def show
    @generation = session[:latest_generation]
    return redirect_to(root_path) if @generation.blank?

    @genre     = Genre.find(@generation['genre'])
    @theme     = @generation['theme']
    @serifus   = @generation['serifus']
    @logged_in = logged_in?
    @saved_serifus = logged_in? ? current_user.favorites.where(serifu: @serifus).pluck(:serifu).to_set : Set.new
  end
end
