class RepositoryController < ApplicationController
  def index
    @view_status = ViewStatus::Status.new()
    @view_status.display({"200"=>false})
    application_list @view_status
  end

  def application_list view_status, through_messege=false
    @app_list = []
    begin
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      res = con.get("apps")
      if !through_messege
        view_status.select_message(res)
      end
      # アプリケーション一覧の取得
      puts "response = "+res.body
      apps = JSON.parse(res.body)
      puts "JSON parse complete"
      apps.each do |app|
        if (app['owner'])['email'] == session[:email]
          @app_list << {"id"=>app['id'], "name"=>app['name']}
        end
      end
    rescue => e
      view_status.status = view_status.error
      view_status.message = e.message
    end
  end

  def detail_update(view_status, message, id, name, owner, minInstance, maxInstance, collaborators)
    begin
      # [/api/apps]に必要なJSONを生成
      postdata = {"id"=>id, "name"=>name, "owner"=>owner, "minInstance"=>minInstance, "maxInstance"=>maxInstance, "collaborators"=>collaborators}
      #puts postdata.to_json
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      view_status.http_message(message)
      view_status.select_message(con.put("apps", postdata.to_json))
    rescue => e
      raise e.message
    end
  end

  def detail
    @view_status = ViewStatus::Status.new()
    # APIとの通信が成功しても画面にメッセージを表示しない
    @view_status.display({"200"=>false})
    show_detail @view_status
  end

  def mod_collaborator_role
    @view_status = ViewStatus::Status.new()
    begin
      collaborators = JSON.parse(params[:collaborators])
      collaborators.each do |col|
        if col['email']==params['mod_collaborator']
          col['role']=params['mod_role']
        end
      end
      # 成功時・失敗時のメッセージを設定
      message = {"2xx"=>"Succeeded in changing the rules!", "4xx"=>"Error in changing the rules!"}
      # 更新処理
      detail_update(@view_status, message, params[:appid], params[:name], {"email"=>params[:owner]}, params[:instance_count], params[:instance_count], collaborators)
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show_detail @view_status, true
    render :controller => "repository", :action => "detail"
  end

  def del_collaborator
    @view_status = ViewStatus::Status.new()
    begin
      collaborators = JSON.parse(params[:collaborators]).reject! {|col| col['email'] == params[:del_collaborator]}
      message = {"2xx"=>"Succeeded in delete the collaborator!", "4xx"=>"Error in delete the collaborator!"}
      detail_update(@view_status, message, params[:appid], params[:name], {"email"=>params[:owner]}, params[:instance_count], params[:instance_count], collaborators)
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show_detail @view_status, true
    render :controller => "repository", :action => "detail"
  end

  def add_collaborator
    @view_status = ViewStatus::Status.new()
    begin
      # コラボレータのIDが入力されていないときはエラー
      if params['new_col'].blank?
        @error_message_new_col_email = "Required"
        raise "Required Error"
      end
      collaborators = JSON.parse(params[:collaborators]) << {"email"=>params['new_col'],"role"=>params['new_role']}
      message = {"2xx"=>"Succeeded in add the collaborator!", "4xx"=>"Error in add the collaborator!"}
      detail_update(@view_status, message, params[:appid], params[:name], {"email"=>params[:owner]}, params[:instance_count], params[:instance_count], collaborators)
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show_detail @view_status, true
    render :controller => "repository", :action => "detail"
  end

  def mod_instance
    @view_status = ViewStatus::Status.new()
    begin
      message = {"2xx"=>"Succeeded in changing the instance!", "4xx"=>"Error in changing the instance!"}
      detail_update(@view_status, message, params[:appid], params[:name], {"email"=>params[:owner]}, params[:instance], params[:instance], JSON.parse(params[:collaborators]))
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    show_detail @view_status, true
    render :controller => "repository", :action => "detail"
  end

  def show_detail view_status, through_messege=false
    @app_detail = {}
    begin
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      # アプリケーションIDをもとに、アプリケーションの情報を取得する
      res = con.get("apps", params[:appid])
      if !through_messege
        view_status.select_message(res)
      end
      app = JSON.parse(res.body)
      collaborators = []
      # 画面表示に必要なコラボレータの情報を、必要なものだけ格納
      app['collaborators'].each do |col|
        collaborators << {"email"=>col['email'], "role"=>col['role']}
      end
      # viewに転送するHash
      @app_detail = {"id" => app['id'], 
                    "name" => app['name'],
                    "url" => app['url'],
                    "git_repository" => app['git_repository'],
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
  end
  
  def create_save
    @view_status = ViewStatus::Status.new()
    begin
      # アプリケーション名が入力されていない場合はエラー
      if params['application_name'].blank?
        @error_message_appname = "Required"
        raise "input application name!!"
      else
        postdata = '{"name":"' + params[:application_name] + '","owner":{"email":"' + session[:email] + '"}}'
        con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
        # APIとの通信に成功した時のメッセージを設定
        @view_status.http_message({"200"=>"Creating application Succeeded!"})
        @view_status.select_message(con.post("apps", postdata))
      end
      # 成功時はhomeにリダイレクトする。
      application_list @view_status, true
      render :controller => "home", :action => "index"
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
      render :controller => "repository", :action => "create"
    end
  end
  
  def delete
    @view_status = ViewStatus::Status.new()
    begin
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      # APIとの通信に成功した時のメッセージを設定
      @view_status.http_message({"2xx"=>"Deleting application Succeeded!"})
      @view_status.select_message(con.delete("apps", params[:appid]))
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
    application_list @view_status, true
    render :controller => "home", :action => "index"
  end
  
  def upload
    @app_name = params['appname']
  end
  
  def upload_save
    @app_name = params['appname']
    @view_status = ViewStatus::Status.new()
    begin
      # ファイル名が未入力のとき
      if params[:warFile].blank?
        @error_message_appfile = "Required"
        raise "input war file path!!"
      else
        # アップロードされたファイルを取得する
        file = params[:warFile]['warFile']
        filename = file.original_filename
        postdata = ""
        # ファイルがある場合
        if filename != "" then
          con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
          # APIとの通信で成功したときのメッセージを設定
          @view_status.http_message({"200"=>"Uploading Warfile Succeeded!"})
          # APIへファイルを転送する
          postdata = [{ 'Content-Disposition' => 'form-data; name="warFile"; filename="' + filename + '"' ,
                        'Content-Type' => 'application/octet-stream', :content => file.read }, 
                        { 'Content-Disposition' => 'form-data; name="name"', :content => @app_name}]
          @view_status.select_message(con.file("warfiles", postdata))
        end
      end
      application_list @view_status, true
      render :controller => "home", :action => "index"
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
      render :controller => "repository", :action => "upload"
    end
  end
  
  def history
    @view_status = ViewStatus::Status.new()
    @view_status.display({"200"=>false})
    history_list @view_status
  end
  
  def history_list view_status, through_messege=false
    @app_id = params[:appid]
    @app_name = params[:appname]
    begin
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      res = con.get("warfiles","");
      if !through_messege
        view_status.select_message(res)
      end
      puts "response = "+res.body
      warfiles = JSON.parse(res.body)
      puts "JSON parse complete"
      @disp_warfiles = []
      puts "start input data to warfiles"
      warfiles.each do |war|
        if war['appName'] == @app_name then
          date_format = "%Y/%m/%d %X"
          puts "date_format = "+ date_format
          @disp_warfiles << {"version" => war['fileId'],
                             "date" => Time.at(war['registDt'] / 1000).strftime(date_format)}
        end
        puts war['appName'] +","+ @app_name
      end
    rescue => e
      view_status.status = @view_status.error
      view_status.message = e.message
    end
  end
  
  def deploy
    @view_status = ViewStatus::Status.new()
    begin
      postdata = '{"appName":"' + params[:appname] + '","appVersion":"' + params[:appversion] + '"}'
      con = ApiConnector::Connect.new(session[:auth_access_token],session[:auth_access_secret])
      # APIとの通信に成功した時のメッセージを設定
      @view_status.http_message({"2xx"=>"Updateing application Succeeded!"})
      @view_status.select_message(con.put("app_version", postdata))
      history_list @view_status, true
    rescue => e
      view_status.status = @view_status.error
      view_status.message = e.message
    ensure
      render :controller => "repository", :action => "history"
    end
  end
end
