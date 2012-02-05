# coding: utf-8
class SignupController < ApplicationController
  require 'httpclient'
  
  def index
  end

  def save
    @view_status = ViewStatus::Status.new()
    begin
      @error_count = 0
      save_validator
      # サインアップに必要な情報があるかのチェックを行い、エラーが1つでもあればエラーとする。
      if @error_count > 0
        raise "Please correct the error and then retry"
      else
        postdata = '{"email":"' + params[:email] + '","password":"' + params[:password] + '"}'
        con = ApiConnector::Connect.new("","")
        # APIとの通信に成功した場合のメッセージを設定
        @view_status.http_message({"200"=>"Registration Success! Please enjoy after login."})
        @view_status.select_message(con.post("users", postdata))
      end
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    ensure
      render :action => 'index'
    end
  end
  
  def save_validator
    # サインアップに必要な情報があるかのチェック
    @error_message_email = ""
    @error_message_password = ""
    @error_message_confirmpassword = ""
    if params[:password] != params[:confirmpassword]
      @error_message_confirmpassword += "Mismatch"
      @error_count += 1
    end
    if params[:email].blank?
      @error_message_email += "Required"
      @error_count += 1
    end
    if params[:password].blank?
      @error_message_password += "Required"
      @error_count += 1
    end
    if params[:confirmpassword].blank?
      @error_message_confirmpassword += "Required"
      @error_count += 1
    end
  end
end
