# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
require 'unicorn/worker_killer'
use Unicorn::WorkerKiller::Oom, (400 + Random.rand(32)) * 1024**2
