class GenerationsController < ApplicationController
  def create
    if !logged_in? && generation_count_today >= DAILY_GENERATION_LIMIT
      redirect_to root_path, alert: '今日の生成回数を使い切りました。ログインすると無制限になります。'
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

    increment_generation_count unless logged_in?

    redirect_to result_path
  end

  def show
    @generation = session[:latest_generation]
    return redirect_to(root_path) if @generation.blank?

    @genre     = Genre.find(@generation['genre'])
    @theme     = @generation['theme']
    @serifus   = @generation['serifus']
    @logged_in = logged_in?
  end
end
