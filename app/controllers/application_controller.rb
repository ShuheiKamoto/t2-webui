# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :protect

  protected
  def protect
    unless params[:controller] == "signup"
      unless session[:auth_key]
        return if params[:controller] == "home"
        redirect_to :controller => "home", :action => "index"
      end
    end
  end
end
