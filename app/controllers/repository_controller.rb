class RepositoryController < ApplicationController
  def index
#      if session[:auth_key]
      #redirect_to :controller => "repository", :action => "index"
		@app_list = []
		begin
		  @request_status = {"status"=>"error", "message"=>""}
		   hc = HTTPClient.new
		  html = hc.get_content("http://" + API_SERVER + "/api/apps/")
		  apps = JSON.parse(html)
		   apps.each do |app|
		    if (app['owner'])['email'] == session[:email]
		      @app_list << app['name']
		    end
		  end
		  @request_status['status'] = "none"
		rescue HTTPClient::BadResponseError => e
		  @request_status['message'] = "Failed to register. Please try again..."
		rescue RuntimeError => e
		  @request_status['message'] = e.message
		rescue => e
		  @request_status['message'] = e.message
		end

		#render :template => 'home/dashboard'
#    end
  end


  def showInfo
  	@issue = Issue.find(params[:id])
    @comment = IssueComment.new
    @comments = IssueComment.where(:parent_id => params[:id]).order("created_at")
    @body = @issue.body

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue }
    end
  end
end