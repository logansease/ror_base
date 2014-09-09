source 'http://rubygems.org'

ruby '2.1.1'
gem 'rails', '4.1.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'webrat', '0.7.1'       
gem 'gravatar_image_tag', '0.1.0'  
gem 'will_paginate', '3.0.4'
gem 'faker', '0.3.1'
gem 'json'
gem 'koala', '1.3.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mail'
gem 'protected_attributes'
gem 'friendly_id', '~> 5.0.3'
gem 'rails_autolink'

gem "carrierwave"
gem 'rmagick'
gem "fog", "~> 1.3.1"


# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
 group :development do
   gem "rspec-rails", "~> 2.8"
   gem 'annotate', '2.4.0' 
   gem 'sqlite3'
 end                                

group :test do
  gem "rspec-rails", "~> 2.8"
	gem 'factory_girl_rails', '1.0'
  gem 'sqlite3'
end

group :production do
  gem 'pg'
  gem 'rails_12factor' #fixes logging in production
end