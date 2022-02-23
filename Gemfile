source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'rails', '~> 6.1'
gem 'bcrypt', '~> 3.1.13'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'faker'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'active_storage_validations', '~> 0.8.2'

group :production do
  gem 'pg', '~> 1.1.4'
end

group :development, :test do
  gem 'sqlite3', '~> 1.4'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rails-controller-testing', '~> 1.0.4'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'minitest',                 '~> 5.11.3'
  gem 'minitest-reporters',       '~> 1.3.8'
  gem 'guard',                    '~> 2.16.2'
  gem 'guard-minitest',           '~> 2.4.6'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'pry-rails'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
