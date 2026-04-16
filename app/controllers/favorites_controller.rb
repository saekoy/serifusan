class FavoritesController < ApplicationController
  before_action :require_login, only: %i[create update destroy]

  def index
    @logged_in = logged_in?
    @genre_filter = params[:genre].presence
    scope = logged_in? ? current_user.favorites.order(created_at: :desc) : Favorite.none
    scope = scope.where(genre: @genre_filter) if @genre_filter
    @favorites = scope
  end

  def create
    fav = current_user.favorites.find_or_initialize_by(serifu: params[:serifu])
    fav.genre = params[:genre] if fav.new_record?
    fav.save

    respond_to do |format|
      format.html { redirect_back_or_to(favorites_path) }
      format.json { head :created }
    end
  end

  def update
    fav = current_user.favorites.find_by(id: params[:id])
    fav&.update(memo: params[:memo].to_s)

    respond_to do |format|
      format.html { redirect_to favorites_path }
      format.json { head :ok }
    end
  end

  def destroy
    fav = current_user.favorites.find_by(id: params[:id])
    fav&.destroy

    respond_to do |format|
      format.html { redirect_to favorites_path }
      format.json { head :ok }
    end
  end

  private

  def require_login
    head :unauthorized unless logged_in?
  end
end
