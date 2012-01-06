# coding: utf-8
class HomeController < ApplicationController

  require 'httpclient'
  require 'json'
  require 'digest/sha2'

  def index
    # すでにログインを通過している場合は[/home]でMyApp一覧を表示する
    if session[:auth_key]
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
      # ログイン処理(ユーザ名・パスワードが一致すればOK)
      con = ApiConnector::Connect.new()
      res = con.get("users")
      @view_status.select_message(res)
      # ユーザ一覧からユーザIDとパスワードが一致するかの確認
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
