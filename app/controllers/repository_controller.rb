class RepositoryController < ApplicationController
  def index
    @app_list = []
    begin
      @view_status = ViewStatus::Status.new()
      con = ApiConnector::Connect.new()
      res = con.get("apps")
      # APIとの通信が成功しても画面にメッセージを表示しない
      @view_status.display({"200"=>false})
      @view_status.select_message(res)
      if res.status >= 400
        raise @view_status.message
      end
      # アプリケーション一覧の取得
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

  def detail_update(view_status, message, id, name, owner, minInstance, maxInstance, collaborators)
    begin
      # [/api/apps]に必要なJSONを生成
      postdata = {"id"=>id, "name"=>name, "owner"=>owner, "minInstance"=>minInstance, "maxInstance"=>maxInstance, "collaborators"=>collaborators}
      #puts postdata.to_json
      con = ApiConnector::Connect.new()
      view_status.http_message(message)
      view_status.select_message(con.put("apps", postdata.to_json))
    rescue => e
      raise e.message
    end
  end

  def detail
    begin
      @view_status = ViewStatus::Status.new()
      # アプリケーション詳細画面が開かれたときにAPIとの通信が成功してもメッセージは出さない。
      if params['mode'].blank?
        @view_status.display({"200"=>false})
      end
      # モードで各処理の振り分け
      case params['mode']
      # コラボレータのロール変更処理
      when "mod_collaborator_role"
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
      # コラボレータの削除処理
      when "del_collaborator"
        collaborators = JSON.parse(params[:collaborators]).reject! {|col| col['email'] == params[:del_collaborator]}
        message = {"2xx"=>"Succeeded in delete the collaborator!", "4xx"=>"Error in delete the collaborator!"}
        detail_update(@view_status, message, params[:appid], params[:name], {"email"=>params[:owner]}, params[:instance_count], params[:instance_count], collaborators)
      # コラボレータ追加処理
      when "add_collaborator"
        # コラボレータのIDが入力されていないときはエラー
        if params['new_col'].blank?
          @error_message_new_col_email = "Required"
          raise "Required Error"
        end
        collaborators = JSON.parse(params[:collaborators]) << {"email"=>params['new_col'],"role"=>params['new_role']}
        message = {"2xx"=>"Succeeded in add the collaborator!", "4xx"=>"Error in add the collaborator!"}
        detail_update(@view_status, message, params[:appid], params[:name], {"email"=>params[:owner]}, params[:instance_count], params[:instance_count], collaborators)
      # インスタンス数の変更処理
      when "mod_instance"
        message = {"2xx"=>"Succeeded in changing the instance!", "4xx"=>"Error in changing the instance!"}
        detail_update(@view_status, message, params[:appid], params[:name], {"email"=>params[:owner]}, params[:instance], params[:instance], JSON.parse(params[:collaborators]))
      end
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end

    # アプリケーション詳細表示処理
    # ######これ以降は、初期表示時もmodeが入っていても処理される
    @app_detail = {}
    begin
      con = ApiConnector::Connect.new()
      # アプリケーションIDをもとに、アプリケーションの情報を取得する
      res = con.get("apps", params[:appid])
      if params['mode'].blank?
        @view_status.select_message(res)
      end
      if res.status >= 400
        raise @view_status.message
      end
      app = JSON.parse(res.body)
      #p app
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
    # create処理(createボタン押下時のみ処理する。)
    if params['mode'] == "execute"
      @view_status = ViewStatus::Status.new()
      begin
        # アプリケーション名が入力されていない場合はエラー
        if params['application_name'].blank?
          raise "input application name!!"
        else
          postdata = '{"name":"' + params[:application_name] + '","owner":{"email":"' + session[:email] + '"}}'
          con = ApiConnector::Connect.new()
          # APIとの通信に成功した時のメッセージを設定
          @view_status.http_message({"200"=>"Creating application Succeeded!"})
          @view_status.select_message(con.post("apps", postdata))
        end
        # 成功時はhomeにリダイレクトする。
        redirect_to :controller => "home", :action => "index"
      rescue => e
        @view_status.status = @view_status.error
        @view_status.message = e.message
      end
    end
  end
  
  def upload
    @app_name = params['appname']
    if params[:mode] == "execute"
      @view_status = ViewStatus::Status.new()
      begin
        # ファイル名が未入力のとき
        if params[:warFile].blank?
          raise "input war file path!!"
        else
          # アップロードされたファイルを取得する
          file = params[:warFile]['warFile']
          filename = file.original_filename
          postdata = ""
          # ファイルがある場合
          if filename != "" then
            con = ApiConnector::Connect.new()
            # APIとの通信で成功したときのメッセージを設定
            @view_status.http_message({"200"=>"Uploading Warfile Succeeded!"})
            # APIへファイルを転送する
            postdata = [{ 'Content-Disposition' => 'form-data; name="warFile"; filename="' + filename + '"' ,
                          'Content-Type' => 'application/octet-stream', :content => file.read }, 
                          { 'Content-Disposition' => 'form-data; name="name"', :content => @app_name}]
            @view_status.select_message(con.file("warfiles", postdata))
          end
        end
        redirect_to :controller => "home", :action => "index"
      rescue => e
        @view_status.status = @view_status.error
        @view_status.message = e.message
      end
      
    end
  end
  
  def history
    @app_id = params[:appid]
    @app_name = params[:appname]
    @view_status = ViewStatus::Status.new()
    begin
      con = ApiConnector::Connect.new()
      res = con.get("warfiles","");
      if res.status >= 400
        raise @view_status.message
      end
      warfiles = JSON.parse(res.body)
      @disp_warfiles = []
      warfiles['warFiles'].each do |war|
        if war['appName'] == @app_name then
          date_format = "%Y/%m/%d %X"
          @disp_warfiles << {"version" => war['fileId'],
                             "date" => Time.at(war['registDt'] / 1000).strftime(date_format)}
        end
      end
    rescue => e
      @view_status.status = @view_status.error
      @view_status.message = e.message
    end
  end
end
