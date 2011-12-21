# coding: utf-8
class SignupController < ApplicationController
  def index
  end

  def save
    @error_count = 0
    @request_status = {"status"=>"", "message"=>""}
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
    
    if @error_count > 0
      @request_status['status'] = "error"
      @request_status['message'] = "Please correct the error and then retry"
    else
      @request_status['status'] = "success"
      @request_status['message'] = "Registration Success! Please enjoy after login."
    end
    render :action => 'index'
  end
  
end
