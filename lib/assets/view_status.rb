# -*- coding: utf-8 -*-
module ViewStatus
  class Status
    attr_accessor :status
    attr_accessor :message
    
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
        @status = @success
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 201
        @status = @success
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 202
        @status = @success
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 204
        @status = @success
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 304
        @status = @success
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 400
        @status = @error
        #@message = http_message.body
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 401
        @status = @error
        #@message = http_message.body
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 403
        @status = @error
        #@message = http_message.body
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      when 404
        @status = @error
        #@message = http_message.body
        @message = @http_message[http_message.status.to_s]
        if !@display[http_message.status.to_s]
          @status = @none
        end
      end
    end
  end
end