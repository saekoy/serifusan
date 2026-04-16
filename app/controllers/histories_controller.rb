class HistoriesController < ApplicationController
  def index
    @logged_in = logged_in?
    @generations = logged_in? ? current_user.generations.order(created_at: :desc) : []
  end
end
