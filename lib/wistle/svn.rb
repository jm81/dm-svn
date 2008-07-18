module Wistle
  module Svn
    class << self
      def included(klass) # Set a few 'magic' properties        
        klass.property :svn_created_at, DateTime
        klass.property :svn_updated_at, DateTime
        klass.property :svn_created_rev, String
        klass.property :svn_updated_rev, String
      end
    end
  end
end