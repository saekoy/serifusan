class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 未ログイン時の1日あたり生成上限（.env で上書き可能。本番3、開発は100推奨）
  DAILY_GENERATION_LIMIT = ENV.fetch('DAILY_GENERATION_LIMIT', 3).to_i

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
