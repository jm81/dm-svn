require 'svn/client'

module Wistle
end

%w{config svn model}.each do |f|
  require File.expand_path(File.dirname(__FILE__) + "/wistle/#{f}.rb")
end