class CategoriesController < ApplicationController
  def index
    @categories = Category.root_categories.active.includes(:children)
  end

  def show
    @category = Category.find_by(name: params[:name])
    
    if @category.nil?
      redirect_to categories_path, alert: "Category not found"
      return
    end
    
    @subcategories = @category.children.active
    @breadcrumb_path = @category.ancestors.reverse + [@category]
  end
end
