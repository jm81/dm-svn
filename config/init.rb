# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
  require 'lib/wistle.rb'
  
  # jm81-paginate
  DataMapper::Collection.__send__(:include, Paginate::DM)
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  
  # Recaptcha keys should be placed in recaptcha.yml. Copy recaptcha_sample.yml
  # and add your keys.
  Merb::Plugins.config[:merb_recaptcha] = YAML.load_file(File.join(File.dirname(__FILE__), 'recaptcha.yml'))
end

Merb.add_mime_type(:txt, nil, %w[text/plain])
