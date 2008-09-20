require 'rubygems'
require 'merb-core'
require 'spec' # Satiates Autotest and anyone else not using the Rake tasks

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end

# for temporarily disabling one set of specs.
def dont_describe(*args)
  nil
end

# auto_migrate one or more models
def migrate(*klasses)
  klasses.each do |klass|
    klass.auto_migrate!
  end
end

# Delete all entries in one or more models
def clean(*klasses)
  klasses.each do |klass|
    klass.all.each {|entry| entry.destroy}
  end
end
