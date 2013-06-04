# encoding: utf-8

class PostsController < ApplicationController
  before_filter :login_required
  
  def index
    @posts = current_user.posts.page(params[:page]).per(1)
  end

  def new
    @post = Post.new
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def create
    @post = Post.new(params[:post].merge!(:user => current_user))

    if @post.save
	    flash[:class] = "alert alert-success"
	    flash[:notice] = "已保存"
      redirect_to posts_url
    else
      render action: "new"
    end
  end

  def update
    @post = Post.find(params[:id])

    if @post.update_attributes(params[:post])
	    page = current_user.posts.collect{|x| x.id}.index(params[:id].to_i) + 1
	    flash[:class] = "alert alert-success"
	    flash[:notice] = "已保存"
      redirect_to :action => "index", :page => page
    else
      render action: "edit"
    end
  end
end
