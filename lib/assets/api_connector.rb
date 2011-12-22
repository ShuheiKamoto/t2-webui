# coding: utf-8
module ApiConnector
  require 'httpclient'

  class Connect
    def initialize
      @client = HTTPClient.new
      @url = "http://" + API_SERVER + "/api/"
    end
    #def delete()
      # delete
    #end
    def get(api_name, body=nil)
      header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      request( :get, api_name, body, header)
    end
    #def put()
      # put
    #end
    def post(api_name, body=nil)
      # post
      header = [['content-type', 'application/json'], ['Accept', 'application/json']]
      request( :post, api_name, body, header)
    end
    def request(method, api_name, body=nil, header=nil)
      #post    = url     body   header
      #request = method  url    query  body  header  follow_redirect
      @client.request( method, @url + api_name + "/", nil, body, header, nil)
    end
  end
end
