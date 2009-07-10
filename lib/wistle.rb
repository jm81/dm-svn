require 'rubygems'
require 'dm-core'
require 'dm-aggregates' # Only needed by specs, but this seems the easiest place to require.
require 'dm-validations'
require 'svn/client'

module Wistle
end

%w{config svn model}.each do |f|
  require File.expand_path(File.dirname(__FILE__) + "/wistle/#{f}.rb")
end