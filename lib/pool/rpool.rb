#!/usr/bin/env ruby

require '../../config/environment'

EM.run do
  pool = PoolServer.new({currency: 25})
  pool.start_server do |conn|
    puts "New connection"
    conn.set_comm_inactivity_timeout 30
  end
end
