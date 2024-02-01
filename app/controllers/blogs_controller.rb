# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_permitted_blog, only: :show
  before_action :set_my_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(@blog.filter_premium(blog_params))
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_my_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def set_permitted_blog
    @blog = Blog.find(params[:id])
    return unless @blog.secret
    raise ActiveRecord::RecordNotFound, "Couldn't find Blog with 'id'=#{@blog.id}" if !user_signed_in?
    raise ActiveRecord::RecordNotFound, "Couldn't find Blog with 'id'=#{@blog.id}" unless @blog.user == current_user
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
