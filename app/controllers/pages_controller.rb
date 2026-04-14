class PagesController < ApplicationController
  def about
    @logged_in = logged_in?
  end
end
