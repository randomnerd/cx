require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    job.constantize.perform_async
  end

  every(60.seconds, 'ProcessCurrencies')
end
