class RepositoryController < ApplicationController
  def index
    @app_list = []
    begin
      @view_status = ViewStatus::Status.new()
      con = ApiConnector::Connect.new()
      res = con.get("apps")
      @view_status.display({"200"=>false})
      @view_status.select_message(res)
      if res.status >= 400
        raise @view_status.message
      end
      apps = JSON.parse(res.body)
      apps.each do |app|
        if (app['owner'])['email'] == session[:email]
          @app_list << {"id"=>app['id'], "name"=>app['name']}
        end
      end
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
  end

  def detail
    @app_detail = {}
    begin
      @view_status = ViewStatus::Status.new()
      con = ApiConnector::Connect.new()
      res = con.get("apps", params[:appid])
      @view_status.display({"200"=>false})
      @view_status.select_message(res)
      if res.status >= 400
        raise @view_status.message
      end
      app = JSON.parse(res.body)
      p app
      collaborators = []
      app['collaborators'].each do |col|
        collaborators << {"email"=>col['email'], "role"=>col['role']}
      end
      @app_detail = {"id" => app['id'], 
                    "name" => app['name'],
                    "url" => "",
                    "git_address" => "",
                    "datasource" => "",
                    "owner" => (app['owner'])['email'],
                    "collaborators" => collaborators,
                    "instance_count" => app['appServerInstance'].count.to_s,
                    "version" => app['appVersion']}
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
  end
end
