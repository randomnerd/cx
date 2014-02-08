module JsonRPC
  class Request
    attr_reader :rpc_method, :params, :id

    def initialize(conn, id, rpc_method, params)
      @id = id
      @conn = conn
      @rpc_method = rpc_method
      @params = params
    end

    def reply(result, close = false)
      response = {
        id: id,
        result: result,
        error: nil
      }

      @conn.send_json response, close
    rescue => e
      puts e.inspect
      puts e.backtrace
    end

    def reject(msg)
      response = {
        id: id,
        result: nil,
        error: [21, msg, nil]
      }
      @conn.send_json response
    end
  end
end
