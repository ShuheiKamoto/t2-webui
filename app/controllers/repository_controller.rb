class RepositoryController < ApplicationController
  def index
    @app_list = []
    begin
      @request_status = {"status"=>"error", "message"=>""}
      con = ApiConnector::Connect.new()
      res = con.get("apps")
      apps = JSON.parse(res.body)
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
  end

  def show_info
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
