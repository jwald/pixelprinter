source :gemcutter

gem "rails", "~> 3.2"
gem 'liquid', :git => 'git://github.com/Shopify/liquid.git', :ref => '05d997', :require => 'liquid'
gem 'airbrake'

group :production do
  gem "memcached", "1.4.1"
end

group :development do
  gem "mysql"
end


group :test do
  gem "mocha"
  gem "context", git: 'git://github.com/jm/context.git'
end
