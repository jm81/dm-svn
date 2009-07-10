require 'rubygems'
require 'dm-core'
require 'dm-aggregates' # Only needed by specs, but this seems the easiest place to require.
require 'dm-validations'
require 'svn/client'

module DmSvn
end

%w{config svn model}.each do |f|
  require File.expand_path(File.dirname(__FILE__) + "/dm-svn/#{f}.rb")
end