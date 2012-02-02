# coding: utf-8
module ApiConnector
  require 'httpclient'
  require 'oauth'

  class Connect
    def initialize access_token,access_secret
      @client = HTTPClient.new
      #@url = "http://" + API_SERVER + "/api/"
      @site = "http://" + API_SERVER
      @url = "/api/"
      @access_token = access_token
      @access_secret = access_secret
    end
    def delete(api_name,key="")
      # delete
      if key != ""
        key = "/" + key
      end
      puts "http request start to "+api_name+key
      created_access_token = use_access_token(@access_token, @access_secret)
      response = created_access_token.delete(@url+api_name+key)
      puts "http request complete (method: delete)"
      return response
      #return response
      #request( :delete, api_name, key, nil, nil, nil)
    end
    def get(api_name, key="", query=nil, body=nil)
      # get
      #header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      if key != ""
        key = "/" + key
      end
      puts "Connect class"
      puts "access_token = "+@access_token
      puts "access_secret = "+@access_secret
      created_access_token = use_access_token(@access_token, @access_secret)
      puts "created_access_token got"
      puts "http request start to "+api_name+key
      response = created_access_token.get(@url+api_name+key,{'Accept'=>'application/json'})
      puts "http request complete (method: get)"
      return response
      #request( :get, api_name, key, query, body, header)
    end
    def put(api_name, body=nil)
      # put
      #header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      created_access_token = use_access_token(@access_token, @access_secret)
      response = created_access_token.put(@url+api_name,body,{'Accept'=>'application/json','Content-Type'=>'application/json'})
      return response
      #request( :put, api_name, "", nil, body, header)
    end
    def post(api_name, body=nil)
      # post
      #header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      if api_name == "users"
        puts "http request start to "+api_name
        response = @client.request( method, @site + @url + api_name, query, body, header, nil)
        puts "http request complete (method: post)"
        return response
      else
        puts "http request start to "+api_name
        puts "postdata = "+body
        created_access_token = use_access_token(@access_token, @access_secret)
        response = created_access_token.post(@url+api_name,body,{'Accept'=>'application/json','Content-Type'=>'application/json'})
        puts "http request complete (method: post)"
        
      end
      #request( :post, api_name, "", nil, body, header)
    end
    def file(api_name, body=nil)
      # file
      #header = [['content-type', 'multipart/form-data']]
      created_access_token = use_access_token(@access_token, @access_secret)
      puts "http request start to "+api_name +" method file"
      response = created_access_token.post(@url+api_name,body,{'Content-Type' => 'multipart/form-data;boundary=------------------------abcABC'})
      puts "http request complete (method: file)"
      return response
      #request( :post, api_name, "", nil, body, header)
    end
    def request(method, api_name, key="", query=nil, body=nil, header=nil)
      #post    = url     body   header
      #request = method  url    query  body  header  follow_redirect
      @client.request( method, @site + @url + api_name + key, query, body, header, nil)
    end
    def use_access_token(access_token, access_secret)
      consumer = OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET,{
        :site => @site,
        :http_method => :post,
        :request_token_path => "/api/auth",
        :access_token_path => "/api/auth",
        :authorize_path => "/api/auth",
        :scheme => :header
      })
      access_token = OAuth::AccessToken.new(consumer,access_token,access_secret)
      return access_token
    end
  end
end
