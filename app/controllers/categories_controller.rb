class CategoriesController < ApplicationController
  def index
    @categories = ['szyby', 'klamki', 'podnóżki']
  end
end
