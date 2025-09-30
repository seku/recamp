class Admin::CategoriesController < ApplicationController
  # HTTP Basic Authentication for admin access
  http_basic_authenticate_with name: "mrv", password: "filipiny"

  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_category, only: [:new, :create]

  # GET /admin/categories
  def index
    @categories = Category.root_categories.includes(:children).ordered_by_position
  end

  # GET /admin/categories/:id
  def show
    @subcategories = @category.children.ordered_by_position
  end

  # GET /admin/categories/new
  def new
    @category = Category.new(parent: @parent_category)
  end

  # POST /admin/categories
  def create
    @category = Category.new(category_params)
    @category.parent = @parent_category

    if @category.save
      redirect_to admin_category_path(@category), notice: "Category created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/categories/:id/edit
  def edit
  end

  # PATCH/PUT /admin/categories/:id
  def update
    if @category.update(category_params)
      redirect_to admin_category_path(@category), notice: "Category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/categories/:id
  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: "Category deleted successfully."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def set_parent_category
    @parent_category = Category.find_by(id: params[:parent_id])
  end

  def category_params
    params.require(:category).permit(
      :name,
      :active,
      :identifier,
      :position,
      :parent_id,
      benefits_attributes: [:id, :title, :desc, :_destroy]
    )
  end
end
