class HomeController < ApplicationController
  DAILY_LIMIT = 3

  def index
    @genres = Genre.all
    @gen_remaining = DAILY_LIMIT # TODO: セッションベースのカウントをあとで実装
    @daily_limit = DAILY_LIMIT
    @logged_in = false # TODO: Firebase Auth導入後に差し替え
  end
end
