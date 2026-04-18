class GenerationsController < ApplicationController
  # Gemini API 悪用・過課金防止のための上限
  THEME_MAX_LENGTH        = 200
  CHARACTER_MAX_LENGTH    = 300
  FIRST_PERSON_MAX_LENGTH = 20
  TONE_MAX_LENGTH         = 20
  LOGGED_IN_DAILY_LIMIT   = ENV.fetch('LOGGED_IN_DAILY_LIMIT', 30).to_i

  def show
    return redirect_to(root_path) unless logged_in?

    target_id = params[:id].presence || session[:latest_generation_id]
    record    = current_user.generations.find_by(id: target_id)
    return redirect_to(root_path) unless record

    @generation    = { 'genre' => record.genre, 'theme' => record.theme, 'serifus' => record.serifus }
    @genre         = Genre.find(record.genre)
    @theme         = record.theme
    @serifus       = record.serifus
    @logged_in     = true
    @saved_serifus = current_user.favorites.where(serifu: @serifus).pluck(:serifu).to_set
  end

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

    if logged_in?
      record = current_user.generations.create!(
        genre: params[:genre],
        theme: params[:theme],
        serifus: serifus
      )
      session[:latest_generation_id] = record.id
      redirect_to result_path
    else
      increment_generation_count
      @generation    = { 'genre' => params[:genre], 'theme' => params[:theme], 'serifus' => serifus }
      @genre         = Genre.find(params[:genre])
      @theme         = params[:theme]
      @serifus       = serifus
      @logged_in     = false
      @saved_serifus = Set.new
      render :show
    end
  end
end
