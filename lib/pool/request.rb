class Pool::Request
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
  end

  def reject(msg)
    @conn.send_json({
      id: id,
      result: nil,
      error: [21, msg, nil]
    })
  end
end
