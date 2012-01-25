# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :protect
  before_filter :set_locale
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  protected
  def protect
    # signup画面は認証不要なページ。
    unless params[:controller] == "signup"
      # auth_keyがセッションに入っていない場合は、home画面に転送する。
      unless session[:auth_key]
        # home画面の場合はhome画面に飛ばさないようにする。(永久ループ防止)
        return if params[:controller] == "home"
        # homeにリダイレクトする。
        redirect_to :controller => "home", :action => "index"
      end
    end
  end
  
  def get_user_id email
    con = ApiConnector::Connect.new()
    res = con.get("users")
    users = JSON.parse(res.body)
    users.each do |user|
      if session[:email] == user['email']
        return user['id']
        break
      end
    end
  end
end
