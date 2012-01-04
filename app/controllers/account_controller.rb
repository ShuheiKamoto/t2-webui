class AccountController < ApplicationController
  def index
  end

  def add_application
    render :controller => "account", :action => "index"
  end

  def delete_application
    render :controller => "account", :action => "index"
  end

  def password_change
    render :controller => "account", :action => "index"
  end
  
  def update_application_key
    render :controller => "account", :action => "index"
  end
end
