# coding: utf-8
module ApiConnector
  require 'httpclient'

  class Connect
    def initialize
      @client = HTTPClient.new
      @url = "http://" + API_SERVER + "/api/"
    end
    def delete(api_name, key="")
      # delete
      if key != ""
        key = "/" + key
      end
      request( :delete, api_name, key, nil, nil, nil)
    end
    def get(api_name, key="", query=nil, body=nil)
      # get
      header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      if key != ""
        key = "/" + key
      end
      request( :get, api_name, key, query, body, header)
    end
    def put(api_name, body=nil)
      # put
      header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      request( :put, api_name, "", nil, body, header)
    end
    def post(api_name, body=nil)
      # post
      header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      request( :post, api_name, "", nil, body, header)
    end
    def file(api_name, body=nil)
      # file
      header = [['content-type', 'multipart/form-data']]
      request( :post, api_name, "", nil, body, header)
    end
    def request(method, api_name, key="", query=nil, body=nil, header=nil)
      #post    = url     body   header
      #request = method  url    query  body  header  follow_redirect
      @client.request( method, @url + api_name + key, query, body, header, nil)
    end
  end
end
