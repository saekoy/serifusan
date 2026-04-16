class HistoriesController < ApplicationController
  def index
    @logged_in = logged_in?
    @genre_filter = params[:genre].presence
    scope = logged_in? ? current_user.generations.order(created_at: :desc) : Generation.none
    scope = scope.where(genre: @genre_filter) if @genre_filter
    @generations = scope
  end
end
