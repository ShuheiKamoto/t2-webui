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
      # email,passwordの必須チェック。
      if params[:email].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      if params[:password].blank?
        raise 'Can not log in because of an incorrect email or password!'
      end
      # access_tokenの発行
      consumer = OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET,{
        :site => "http://"+API_SERVER,
        :http_method        => :post,
        :request_token_path => "/api/auth",
        :access_token_path => "/api/auth",
        :authorize_path => "/api/auth",
        :scheme => :header
      })
      access_token = consumer.get_access_token(nil,{},{
        :x_auth_username => params[:email],
        :x_auth_password => params[:password],
        :x_auth_mode => "client_auth"
      })
      # ログイン処理(ユーザ名・パスワードが一致すればOK)
      con = ApiConnector::Connect.new(access_token.token,access_token.secret)
      res = con.get("users")
      @view_status.select_message(res)
      # ユーザ一覧からユーザIDとパスワードが一致するかの確認
      users = JSON.parse(res.body)
      users.each do |user|
        if params[:email] == user['email'] && Digest::SHA512.hexdigest(params[:password]) == user['password']
          session[:auth_access_token] = access_token.token
          session[:auth_access_secret] = access_token.secret
          session[:email] = user['email']
          break
        end
      end
    rescue => e
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
