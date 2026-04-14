class GenerationsController < ApplicationController
  DAILY_LIMIT = 3

  def create
    unless logged_in?
      if generation_count_today >= DAILY_LIMIT
        redirect_to root_path, alert: '今日の生成回数を使い切りました。ログインすると無制限になります。'
        return
      end
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

    increment_generation_count unless logged_in?

    redirect_to result_path
  end

  def show
    @generation = session[:latest_generation]
    return redirect_to(root_path) if @generation.blank?

    @genre    = Genre.find(@generation['genre'])
    @theme    = @generation['theme']
    @serifus  = @generation['serifus']
    @logged_in = logged_in?
  end

  private

  def logged_in?
    false # TODO: Firebase Auth導入後に差し替え
  end

  def generation_count_today
    return 0 if session[:gen_count_date] != Date.today.to_s

    session[:gen_count].to_i
  end

  def increment_generation_count
    if session[:gen_count_date] != Date.today.to_s
      session[:gen_count_date] = Date.today.to_s
      session[:gen_count] = 0
    end
    session[:gen_count] = session[:gen_count].to_i + 1
  end
end
