module Wistle
end

%w{config svn model}.each do |f|
  require File.dirname(__FILE__) + "/wistle/#{f}.rb"
end