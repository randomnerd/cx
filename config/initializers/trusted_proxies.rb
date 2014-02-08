module Rack
  class Request
    def trusted_proxy?(ip)
      ['10.0.1.14', '127.0.0.1'].include? ip
    end
  end
end

