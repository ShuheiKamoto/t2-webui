# coding: utf-8
class HomeController < ApplicationController

  require 'httpclient'
  require 'json'
  require 'digest/sha2'
  require 'oauth'

  def index
    # すでにログインを通過している場合は[/home]でMyApp一覧を表示する
    if session[:email] && session[:auth_access_token] && session[:auth_access_secret]
      redirect_to "/repository"
    end
  end

  def authorize
    begin
      @view_status = ViewStatus::Status.new()
      #puts "@view_status (new) = "+@view_status
      # email,passwordの必須チェック。
      if params[:email].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      if params[:password].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      puts "publish access_token start"
      # access_tokenの発行
      consumer = OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET,{
        :site => "http://"+API_SERVER,
        :http_method        => :post,
        :request_token_path => "/api/auth",
        :access_token_path => "/api/auth",
        :authorize_path => "/api/auth",
        :scheme => :header
      })
      puts "consumer created"
      puts "http://" + API_SERVER
      puts "params[:email] = " + params[:email]
      puts "params[:password] = " + params[:password]
      puts "CONSUMER_KEY = " + CONSUMER_KEY
      puts "CONSUMER_SECRET = " + CONSUMER_SECRET
      access_token = consumer.get_access_token(nil,{},{
        :x_auth_username => params[:email],
        :x_auth_password => params[:password],
        :x_auth_mode => "client_auth"
      })
      puts "show access_token information"
      puts "access_token.token = " + access_token.token
      puts "access_token.secret = " + access_token.secret
      # ログイン処理(ユーザ名・パスワードが一致すればOK)
      con = ApiConnector::Connect.new(access_token.token,access_token.secret)
      res = con.get("users")
 #     puts "response = "+res.code
      puts "user information got with access token"
      puts "call select_message"
      puts "@view_status = "+@view_status
      @view_status.select_message(res)
      # ユーザ一覧からユーザIDとパスワードが一致するかの確認
      users = JSON.parse(res.body)
      puts "JSON parse complete"
      users.each do |user|
        if params[:email] == user['email'] && Digest::SHA512.hexdigest(params[:password]) == user['password']
          session[:auth_access_token] = access_token.token
          session[:auth_access_secret] = access_token.secret
          session[:email] = user['email']
          break
        end
      end
      puts "set user information to SESSION"
    rescue => e
      puts "error"
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    
    if session[:email] && session[:auth_access_token] && session[:auth_access_secret]
      # session[:auth_key]が存在する場合はログインに成功しているので、ログイン成功ステータスをセットする。メッセージは表示しない。
      @view_status.display({"200"=>false})
      @view_status.status = @view_status.success
      redirect_to :controller => "home", :action => "index"
    else
      # session[:auth_key]が存在しない場合はログインに失敗しているので、メッセージで失敗を伝える。
      @view_status.status = @view_status.error
      @view_status.message = 'Can not log in because of an incorrect email or password!'
      render :controller => "home", :action => "index"
    end
  end

  def signout
    # セッションをクリアする
    reset_session
    
    # home画面にリダイレクトする
    redirect_to :controller => "home", :action => "index"
  end
end
