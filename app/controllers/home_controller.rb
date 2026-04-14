class HomeController < ApplicationController
  def index
    @genres = Genre.all
    @daily_limit = DAILY_GENERATION_LIMIT
    @gen_remaining = @daily_limit - generation_count_today
    @logged_in = logged_in?
  end
end
