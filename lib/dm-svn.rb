require 'rubygems'
require 'dm-core'
require 'dm-aggregates' # Only needed by specs, but this seems the easiest place to require.
require 'dm-validations'
require 'svn/client'

module DmSvn
  VERSION = '0.2.3'
end

require 'dm-svn/config'
require 'dm-svn/svn'
require 'dm-svn/model'
