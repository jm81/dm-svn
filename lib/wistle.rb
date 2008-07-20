require 'svn/client'

module Wistle
end

%w{config svn model svn_sync}.each do |f|
  require File.dirname(__FILE__) + "/wistle/#{f}.rb"
end