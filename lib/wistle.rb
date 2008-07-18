module Wistle
end

%w{svn}.each do |f|
  require File.dirname(__FILE__) + "/wistle/#{f}.rb"
end