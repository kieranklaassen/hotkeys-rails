class PagesController < ApplicationController
  def home
  end

  def clicked
    render plain: "Link was clicked!"
  end

  def focused
    render plain: "Focus page"
  end
end
