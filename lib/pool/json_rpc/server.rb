module JsonRPC
  class Server < EM::Connection
    @@parsing_error_response = "Error parsing request"

    def receive_data(data)
      process_request MultiJson.load(data, symbolize_keys: true)
    rescue => e
      send_data @@parsing_error_response
      close_connection_after_writing
      parsing_error e, data
    end

    def process_request(data)
      receive_request JsonRPC::Request.new(self, data[:id], data[:method], data[:params])
    end

    def parsing_error(error, data)
      puts "Error parsing data: #{data.inspect}"
      puts error.inspect
      puts error.backtrace
    end

    def start_server(addr = '0.0.0.0', port = 3333, options = nil, &block)
      raise Error, "EventMachine is not running" unless EM.reactor_running?
      EM.start_server addr, port, self.class, options, &block
    end
  end
end
