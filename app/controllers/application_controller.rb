# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :protect

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
end
