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
      created_access_token = use_access_token(@access_token, @access_secret)
      response = created_access_token.delete(@url+api_name+key)
      return response
    end
    def get(api_name, key="", query=nil, body=nil)
      # get
      if key != ""
        key = "/" + key
      end
      created_access_token = use_access_token(@access_token, @access_secret)
      response = created_access_token.get(@url+api_name+key,{'Accept'=>'application/json'})
      return response
    end
    def put(api_name, body=nil)
      # put
      created_access_token = use_access_token(@access_token, @access_secret)
      response = created_access_token.put(@url+api_name,body,{'Accept'=>'application/json','Content-Type'=>'application/json'})
      return response
    end
    def post(api_name, body=nil)
      # post
      if api_name == "users"
        response = @client.request( method, @site + @url + api_name, query, body, header, nil)
        return response
      else
        created_access_token = use_access_token(@access_token, @access_secret)
        response = created_access_token.post(@url+api_name,body,{'Accept'=>'application/json','Content-Type'=>'application/json'})
        return response
#      end
    end
    def file(api_name, body=nil)
      # file
      created_access_token = use_access_token(@access_token, @access_secret)
      response = created_access_token.post(@url+api_name,body,{'Content-Type' => 'multipart/form-data;boundary=------------------------abcABC'})
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
