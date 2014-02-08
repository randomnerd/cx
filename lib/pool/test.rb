#!/usr/bin/env ruby

require './util'

addr = '1qxok3VkmtxXxtT7RHTcbUuRr8DLkR8t2'
puts Util.address_to_pubkeyhash(addr).inspect

