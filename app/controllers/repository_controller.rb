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

  def detail_update
    @view_status = ViewStatus::Status.new()
    begin
      postdata = '{"email":"' + params[:email] + '","password":"' + params[:password] + '"}'
      con = ApiConnector::Connect.new()
      @view_status.http_message({"200"=>"Registration Success! Please enjoy after login."})
      @view_status.select_message(con.post("users", postdata))
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
  end

  def detail
    #p params
    case params['mode']
    when "mod_collaborator_role"
      #p "**************************************mod_collaborator_role"
      a = {"id"=>params[:appid],"name"=>params[:name],"owner"=>{"email"=>params[:owner]},"minInstance"=>params[:instance_count],"maxInstance"=>params[:instance_count],"collaborators"=>JSON.parse(params[:collaborators])}
      #p "----"
      #puts a
    when "del_collaborator"
      #p "**************************************del_collaborator"
      #p JSON.parse(params[:collaborators]).reject! {|col| col['email'] == params[:del_collaborator]}
      a = {"id"=>params[:appid],"name"=>params[:name],"owner"=>{"email"=>params[:owner]},"minInstance"=>params[:instance_count],"maxInstance"=>params[:instance_count],"collaborators"=>"collaborators"}
      #p "----"
      #puts a
    when "add_collaborator"
    when "mod_instance"
    end
    
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
                    "url" => app['url'],
                    "git_address" => "",
                    "datasource" => app['datasource'],
                    "owner" => (app['owner'])['email'],
                    "collaborators" => collaborators,
                    "instance_count" => app['appServerInstance'].count.to_s,
                    "version" => app['appVersion']}
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
  end
  
  def create
    if params['mode'] == "execute"
      @view_status = ViewStatus::Status.new()
      begin
        if params['application_name'].blank?
          raise "input application name!!"
        else
          postdata = '{"name":"' + params[:application_name] + '","owner":{"email":"' + session[:email] + '"}}'
          con = ApiConnector::Connect.new()
          @view_status.http_message({"200"=>"Creating application Succeeded!"})
          @view_status.select_message(con.post("apps", postdata))
        end
        redirect_to :controller => "home", :action => "index"
      rescue => e
        @view_status.status = @view_status.error
        @view_status.message = e.message
      end
    end
  end
  
  def upload
    
  end
  
  def history
    
  end
end
