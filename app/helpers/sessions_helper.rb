# -*- encoding : utf-8 -*-
module SessionsHelper
  def sign_in(user, remember)
    if remember
      cookies.signed[:remember_token] = {
        :value => [user.id, user.salt],
        :expires => 1.week.from_now.utc
      }
    else
      cookies.signed[:remember_token] = [user.id, user.salt]
    end
    current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    cookies.delete(:remember_token)
    current_user = nil
  end

  def deny_access
    redirect_to signin_path, :notice => "你没有权限进行此项操作."
  end

  private

  def user_from_remember_token
    User.authenticate_with_salt(*remember_token)
  end

  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end
end