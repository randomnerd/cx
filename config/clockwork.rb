require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    job.constantize.perform_async
  end

  every(4.minutes, 'ProcessCurrencies')
  every(1.minute, 'ProcessMiningScores')
end
