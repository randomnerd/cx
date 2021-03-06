source 'https://rubygems.org'
source "http://2edaf45f:4e8fa5c0@www.mikeperham.com/rubygems/"

gem 'rails', '4.0.3'
gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem "active_model_serializers", github: "erundook/active_model_serializers", branch: 'patch-1'
gem 'celluloid', github: 'celluloid/celluloid'
gem 'celluloid-io'
gem 'timers'

platforms :jruby do
  gem 'puma'
  gem 'closure-compiler'
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'krypt'
  gem 'jrjackson'
  gem 'therubyrhino'
end

platforms :ruby do
  gem 'pg'
  gem 'uglifier', '>= 1.3.0'
  gem 'oj'
  gem 'unicorn'
end

gem 'devise'
gem 'devise-async'
gem 'pusher'
gem "ember-rails", github: "emberjs/ember-rails"

gem 'inherited_resources', '~> 1.4.1'
gem 'has_scope'

gem 'dalli'

gem 'httparty'
gem 'sidekiq-pro'
gem 'sinatra', require: false
gem 'slim'
gem 'clockwork'
gem 'daemons'

gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-bundler'

gem 'newrelic_rpm'

gem 'rotp'
gem 'font-awesome-sass'

gem 'multi_json'

gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'

gem 'rack-attack'

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails', "~> 4.0"
  gem 'database_cleaner'
  gem 'quiet_assets'
end

group :staging, :production do
  gem 'rails-mailgun', git: "git://github.com/code-mancers/rails-mailgun.git"
end
