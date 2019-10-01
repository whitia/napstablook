class CategoriesController < ApplicationController
  def index
    @category = Category.new
  end

  def create
    Category.create(name: params[:category][:name], color: params[:category][:color])
    redirect_to categories_path
  end
end
