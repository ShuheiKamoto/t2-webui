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
      @request_status = {"status"=>"error", "message"=>""}
      if params[:email].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      if params[:password].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      con = ApiConnector::Connect.new()
      res = con.get("users")
      users = JSON.parse(res.body)
      users.each do |user|
        if params[:email] == user['email'] && Digest::SHA512.hexdigest(params[:password]) == user['password']
          session[:auth_key] = "key"
          session[:email] = user['email']
          break
        end
      end
      
      @request_status['message'] = "login Success!"
    rescue HTTPClient::BadResponseError => e
      @request_status['message'] = "Failed to register. Please try again..."
    rescue RuntimeError => e
      @request_status['message'] = e.message
    rescue => e
      @request_status['message'] = e.message
    end
    
    if session[:auth_key]
      @request_status['status'] = "success"
      redirect_to :controller => "home", :action => "index"
    else
      @request_status['message'] = 'Can not log in because of an incorrect email or password!'
      render :controller => "home", :action => "index"
    end
  end

  def signout
    reset_session
    
    redirect_to :controller => "home", :action => "index"
  end
end
