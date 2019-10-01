class CategoriesController < ApplicationController
  def index
    @category = Category.new
  end

  def create
    Category.create(name: params[:name], color: params[:color])
    redirect_to categories_path
  end
end
