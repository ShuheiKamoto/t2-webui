# coding: utf-8
module ApiConnector
  require 'net/http'
  require 'uri'
  require 'oauth'
  require 'net/http/post/multipart'

  Net::HTTP.version_1_2

  class Connect
    def initialize access_token,access_secret
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
      response = created_access_token.get(@url + api_name + key, {'Accept'=>'application/json'})
      return response
    end
    def put(api_name, body=nil)
      # put
      created_access_token = use_access_token(@access_token, @access_secret)
      response = created_access_token.put(@url + api_name, body, {'Accept' => 'application/json', 'Content-Type' => 'application/json'})
      return response
    end
    def post(api_name, body=nil)
      # post
      response = nil
      header = {'Accept' => 'application/json','Content-Type'=>'application/json'}
      if api_name == "users"
        Net::HTTP.start(URI.parse(@site).host,URI.parse(@site).port) {|http|
          response = http.post(@url + api_name, body, header)
        }
      else
        created_access_token = use_access_token(@access_token, @access_secret)
        response = created_access_token.post(@url + api_name, body, header)
      end
      return response
    end
    def file(api_name, file_param_name, file_io, filename, post_params={})
      # file
      created_access_token = use_access_token(@access_token, @access_secret)
      post_data = { file_param_name => UploadIO.new(file_io, "application/octet-stream", filename) }
      post_data = post_data.merge(post_params)
      request = Net::HTTP::Post::Multipart.new(@url + api_name, post_data )
      created_access_token.sign! request
      response = Net::HTTP.start(URI.parse(@site).host,URI.parse(@site).port) do |http|
        http.request(request)
      end
      return response
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
