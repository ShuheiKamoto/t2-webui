class AccountController < ApplicationController
  def index
    @view_status = ViewStatus::Status.new()
    # APIとの通信が成功しても画面にメッセージを表示しない
    @view_status.display({"200"=>false})
    show @view_status
  end

  def show view_status, through_messege=false
    @consumer_key_list = []
    begin
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      res = con.get("consumer_key")
      if !through_messege
        view_status.select_message(res)
      end
      # アプリケーション一覧の取得
      consumer_key = JSON.parse(res.body)
      consumer_key.each do |key|
        if key['userId'] == get_user_id(session[:email])
          @consumer_key_list << {"userSideAppId"=>key['id'], "userSideAppName"=>key['userSideAppName'], "consumerKey"=>key['consumerKey'], "consumerSecret"=>key['consumerSecret']}
        end
      end
    rescue => e
      view_status.status = view_status.error
      view_status.message = e.message
    end
  end

  def add_application
    @view_status = ViewStatus::Status.new()
    begin
      # アプリケーション名が入力されていない場合はエラー
      if params['new_application_name'].blank?
        raise "input application name!!"
      else
        postdata = '{"userId":"' + get_user_id(session[:email]) + '","userSideAppName":"' + params[:new_application_name] + '"}}'
        con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
        # APIとの通信に成功した時のメッセージを設定
        @view_status.http_message({"200"=>"Creating consumerKey Succeeded!"})
        @view_status.select_message(con.post("consumer_key", postdata))
      end
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show @view_status, true
    render :controller => "account", :action => "index"
  end

  def delete_application
    @view_status = ViewStatus::Status.new()
    begin
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      # APIとの通信に成功した時のメッセージを設定
      @view_status.http_message({"2xx"=>"Delete consumerKey Succeeded!"})
      @view_status.select_message(con.delete("consumer_key", params[:appid]))
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show @view_status, true
    render :controller => "account", :action => "index"
  end

  def password_change
    @view_status = ViewStatus::Status.new()
    begin
      @error_count = 0
      save_validator
      # パスワード変更に必要な情報があるかのチェックを行い、エラーが1つでもあればエラーとする。
      if @error_count > 0
        raise "Please correct the error and then retry"
      else
        postdata = '{"email":"' + session[:email] + '","password":"' + params[:newpassword] + '","id":"' + get_user_id(session[:email]) + '"}'
        puts postdata
        con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
        # APIとの通信に成功した時のメッセージを設定
        @view_status.http_message({"2xx"=>"Changing password Succeeded!"})
        @view_status.select_message(con.put("users", postdata))
      end
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show @view_status, true
    render :controller => "account", :action => "index"
  end
  
  def save_validator
    # サインアップに必要な情報があるかのチェック
    @error_message_current_password = ""
    @error_message_newpassword = ""
    @error_message_confirmpassword = ""

    correctPassword = false
    con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
    res = con.get("users")
    # ユーザ一覧からユーザIDとパスワードが一致するかの確認
    users = JSON.parse(res.body)
    users.each do |user|
      if session[:email] == user['email'] && Digest::SHA512.hexdigest(params[:currentpassword]) == user['password']
        correctPassword = true
        break
      end
    end

    if !correctPassword
      @error_message_current_password += "Mismatch"
      @error_count += 1
    end
    if params[:newpassword] != params[:confirmpassword]
      @error_message_confirmpassword += "Mismatch"
      @error_count += 1
    end
    if params[:currentpassword].blank?
      @error_message_current_password += "Required"
      @error_count += 1
    end
    if params[:newpassword].blank?
      @error_message_newpassword += "Required"
      @error_count += 1
    end
    if params[:confirmpassword].blank?
      @error_message_confirmpassword += "Required"
      @error_count += 1
    end
  end
  
  def update_application_key
    @view_status = ViewStatus::Status.new()
    begin
      postdata = '{"userId":"' + get_user_id(session[:email]) + '","userSideAppName":"' + params[:appname] + '","id":"' + params[:appid] + '"}}'
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      # APIとの通信に成功した時のメッセージを設定
      @view_status.http_message({"2xx"=>"Updateing consumerKey Succeeded!"})
      @view_status.select_message(con.put("consumer_key", postdata))
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show @view_status, true
    render :controller => "account", :action => "index"
  end
end
