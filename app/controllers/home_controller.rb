# coding: utf-8
class HomeController < ApplicationController

  require 'httpclient'
  require 'json'
  require 'digest/sha2'

  def index
    if session[:auth_key]
      redirect_to "/repository"
    end
  end

  def authorize
    begin
      @view_status = ViewStatus::Status.new()
      if params[:email].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      if params[:password].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      con = ApiConnector::Connect.new()
      res = con.get("users")
      @view_status.display({"200"=>false})
      @view_status.select_message(res)
      if res.status >= 400
        raise @view_status.message
      end
      users = JSON.parse(res.body)
      users.each do |user|
        if params[:email] == user['email'] && Digest::SHA512.hexdigest(params[:password]) == user['password']
          session[:auth_key] = "key"
          session[:email] = user['email']
          break
        end
      end
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    
    if session[:auth_key]
      @view_status.status = @view_status.success
      redirect_to :controller => "home", :action => "index"
    else
      @view_status.message = 'Can not log in because of an incorrect email or password!'
      render :controller => "home", :action => "index"
    end
  end

  def signout
    reset_session
    
    redirect_to :controller => "home", :action => "index"
  end
end
