# -*- coding: utf-8 -*-
module ViewStatus
  class Status
    attr_accessor :status
    attr_accessor :message
    attr_accessor :use_body_message
    
    attr_reader :none
    attr_reader :warning
    attr_reader :error
    attr_reader :success
    attr_reader :info
    
    #attr_writer :display
    def display(view)
      if view.class == Hash
        # 2xxが指定された場合は、200番台のステータスに同じdisplayフラグを設定する
        if view.key?('2xx')
          value = view['2xx']
          view['200']=value
          view['202']=value
          view['204']=value
          view.delete('2xx')
        end
        if view.key?('3xx')
          value = view['3xx']
          view['304']=value
          view.delete('3xx')
        end
        if view.key?('4xx')
          value = view['4xx']
          view['400']=value
          view['401']=value
          view['403']=value
          view['404']=value
          view.delete('4xx')
        end
        @display = @display.merge(view)
      end
    end

    #attr_writer :except
    def except(except)
      if except.class == Hash
        # 2xxが指定された場合は、200番台のステータスに同じdisplayフラグを設定する
        if except.key?('2xx')
          value = except['2xx']
          except['200']=value
          except['202']=value
          except['204']=value
          except.delete('2xx')
        end
        if except.key?('3xx')
          value = except['3xx']
          except['304']=value
          except.delete('3xx')
        end
        if except.key?('4xx')
          value = except['4xx']
          except['400']=value
          except['401']=value
          except['403']=value
          except['404']=value
          except.delete('4xx')
        end
        @except = @except.merge(except)
      end
    end

    #attr_writer :http_message
    def http_message(new_message)
      if new_message.class == Hash
        # 2xxが指定された場合は、200番台のステータスに同じメッセージを設定する
        if new_message.key?('2xx')
          value = new_message['2xx']
          new_message['200']=value
          new_message['202']=value
          new_message['204']=value
          new_message.delete('2xx')
        end
        if new_message.key?('3xx')
          value = new_message['3xx']
          new_message['304']=value
          new_message.delete('3xx')
        end
        if new_message.key?('4xx')
          value = new_message['4xx']
          new_message['400']=value
          new_message['401']=value
          new_message['403']=value
          new_message['404']=value
          new_message.delete('4xx')
        end
        @http_message = @http_message.merge(new_message)
      end
    end

    def initialize
      @status = "none"
      @message = ""
      @use_body_message = false
      
      @none = "none"
      @warning = "warning"
      @error = "error"
      @success = "success"
      @info = "info"
      
      @display = {"200"=>true,
                  "201"=>true,
                  "202"=>true,
                  "204"=>true,
                  "304"=>true,
                  "400"=>true,
                  "401"=>true,
                  "403"=>true,
                  "404"=>true
                 }

      @except = {"200"=>false,
                 "201"=>false,
                 "202"=>false,
                 "204"=>false,
                 "304"=>false,
                 "400"=>true,
                 "401"=>true,
                 "403"=>true,
                 "404"=>true
                }


      @http_message = {"200"=>"request success",
                       "201"=>"create success",
                       "202"=>"request accepted",
                       "204"=>"no content",
                       "304"=>"not modified",
                       "400"=>"bad request",
                       "401"=>"unauthorized",
                       "403"=>"forbidden",
                       "404"=>"not found"
                      }
    end
  
    def select_message(http_message)
      if http_message.class != HTTP::Message
        return
      end
      case http_message.status
      when 200
        create_message http_message, @success
      when 201
        create_message http_message, @success
      when 202
        create_message http_message, @success
      when 204
        create_message http_message, @success
      when 304
        create_message http_message, @success
      when 400
        create_message http_message, @error
      when 401
        create_message http_message, @error
      when 403
        create_message http_message, @error
      when 404
        create_message http_message, @error
      end
    end
    
    def create_message http_message, set_status
      @status = set_status
      if @use_body_message
        @message = http_message.body
      else
        @message = @http_message[http_message.status.to_s]
      end
      if !@display[http_message.status.to_s]
        @status = @none
      end
      if @except[http_message.status.to_s]
        raise @message
      end
    end
  end
end