class PagesController < ApplicationController
  def index
    if current_user
      redirect_to '/trips'
    end
  end

  def about
  end
end
