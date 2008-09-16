module Wistle
  module Svn

    # Store information about a particular changeset, and runs the actual
    # updates for that changeset. Aside from handling the
    # list of changes, it can be passed to methods that need the revision,
    # date and author.
    class Changeset
      include Comparable
      
      attr_reader :changes, :revision, :date, :author, :repos, :config
      
      def initialize(changes, revision, author, date, sync)
        @changes, @revision, @author, @date = changes, revision, author, date
        @model, @config, @repos = sync.model, sync.config, sync.repos
      end
      
      # Changesets are sorted by revision number, ascending.
      def <=>(other)
        self.revision <=> other.revision
      end
      
      # Process this changeset.
      # This doesn't account for possible move/replace conflicts (A node is moved,
      # then the old node is replaced by a new one). I assume those are rare
      # enough that I won't code around them, for now.
      def process
        modified, deleted, copied = [], [], []
        
        changes.each_pair do |path, change|
          next if short_path(path).blank?
          
          case change.action
          when "M", "A", "R" # Modified, Added or Replaced
            modified << path if @repos.stat(path, @revision).file?
          when "D"
            deleted << path
          end
          copied << [path, change.copyfrom_path] if change.copyfrom_path        
        end
              
        # Perform moves
        copied.each do |copy|
          del = deleted.find { |d| d == copy[1] }
          if del
            # Change the path. No need to perform other updates, as this is an
            # "A" or "R" and thus is in the +modified+ Array.
            record = get(del)
            if record
              record.path = short_path(copy[0])
              record.save
            end
          end
        end
        
        # Perform deletes
        deleted.each do |path|
          record = get(path)
          record.destroy if record # May have been moved or refer to a directory
        end
        
        # Perform modifies and adds
        modified.each do |path|
          next if @config.extension && path !~ /\.#{@config.extension}\Z/
          
          record = get(path) || new_record
  
          # update record
          node = Node.new(self, path)
          record.update_from_svn(node)
        end      
      end
    
      # Get the relative path from config.uri
      def short_path(path)
        path = path[@config.path_from_root.length..-1].to_s
        path = path[1..-1] if path[0] == ?/
        path.sub!(/\.#{@config.extension}\Z/, '') if @config.extension
        path
      end
    
      private
      
      # Get an object of the @model, by path.
      def get(path)
        @model.first(:svn_name => short_path(path))
      end
      
      # Create a new object of the @model
      def new_record
        @model.new
      end
      
    end
  end
end
