module Wistle
end

%w{config svn}.each do |f|
  require File.dirname(__FILE__) + "/wistle/#{f}.rb"
end