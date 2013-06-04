# encoding: utf-8

require 'date'
require 'digest/sha1'

class AccountController < ApplicationController
  include ApplicationHelper

  def login
  	@title = "登入 - maruDiary"
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])

    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
	    redirect_to :posts
    else
	    flash.now[:class] = "alert"
      flash.now[:notice] = "您输入的 Email 或密码不正确，请重试"
    end
  end

  def signup
  	@title = "注册 - maruDiary"
    return unless request.post?
    begin
	    @user = User.new
	    @user.email = params[:user_email]
	    @user.password = params[:user_password]
	    @user.hint = params[:user_hint]
	    @user.save!
#	    UserMailer.registration_confirmation(@user).deliver
	    self.current_user = @user
	    flash[:class] = "alert alert-success"
	    flash[:notice] = "注册成功"
	    redirect_to :posts
    rescue
	    flash.now[:class] = "alert"
	    flash.now[:notice] = "您输入的 Email 已经被注册，请换个试试"
	    render :action => 'signup'
	  end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:class] = "alert alert-success"
    flash[:notice] = "您已登出"
    redirect_back_or_default(:controller => 'account', :action => 'login')
  end
end
