# coding: utf-8
class SignupController < ApplicationController
  require 'httpclient'
  
  def index
  end

  def save
    begin
      @error_count = 0
      @request_status = {"status"=>"error", "message"=>""}
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
        raise "Please correct the error and then retry"
      else
        hc = HTTPClient.new
        #html = hc.get_content("http://localhost:8080/api/users/", "post")
        #p html
        
        postdata = '{"email":"' + params[:email] + '","password":"' + params[:password] + '"}'
        puts hc.post_content("http://" + API_SERVER + "/api/users/", postdata, [['content-type', 'application/json'], ['Accept', 'application/json']])
        
        
        @request_status['status'] = "success"
        @request_status['message'] = "Registration Success! Please enjoy after login."
      end
    rescue HTTPClient::BadResponseError => e
      @request_status['message'] = "Failed to register. Please try again..."
    rescue RuntimeError => e
      @request_status['message'] = e.message
    ensure
      render :action => 'index'
    end
  end
end