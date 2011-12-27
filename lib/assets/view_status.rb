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
        @display = @display.merge(view)
      end
    end

    #attr_writer :http_message
    def http_message(new_message)
      if new_message.class == Hash
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