module Wistle
  module Svn

    # A Node (file or directory) at a path and revision [Changeset].
    # In particular, this class exists to determine the type (file or directory)
    # of the node and retrieve the body of a node (for files),
    # and other properties, either stored in yaml or a Subversion properties
    class Node
      
      attr_reader :path
      
      def initialize(changeset, path)
        @changeset, @path = changeset, path
      end
      
      # Shortened path (from Changeset#short_path)
      def short_path
        @changeset.short_path(@path)
      end
      
      # Body of the node (nil for a directory)
      def body
        return nil unless file?
        has_yaml_props? ?
          yaml_split[1] :
          data[0]
      end
      
      # Properties of the node. The properties are accessed from three sources,
      # listed by order of precedence:
      # 1. YAML properties, either in meta.yml (directories), or at the
      #    beginning of a file, between "---" and "..." lines.
      # 2. Properties stored in subversion's property mechanism.
      # 3. svn_updated_[rev|at|by] as determined by revision properties.
      def properties
        rev_properties.merge(svn_properties).merge(yaml_properties)
      end
      
      # Is the Node a file?
      def file?
        repos.stat(path, revision).file?
      end
    
      # Is the Node a directory?
      def directory?
        repos.stat(path, revision).directory?
      end
      
      # Methods derived from Changeset instance variables.
      %w{revision author repos date config}.each do |f|
        define_method(f) do
          @changeset.__send__(f)
        end
      end
    
      private
      
      # Get data as array of body, properties
      def data
        @data ||= file? ?
          repos.file(path, revision) :
          repos.dir(path, revision)
      end
      
      # Properties based on the revision information: svn_updated_[rev|at|by]
      # as a hash
      def rev_properties
        {
          'svn_updated_at' => @changeset.date,
          'svn_updated_by' => @changeset.author,
          'svn_updated_rev' => @changeset.revision
        }
      end
    
      # Get properties stored as subversion properties, that begin with the
      # Config#property_prefix.
      def svn_properties
        props = {}
        data[1].each do |name, val|
          if name =~ /\A#{config.property_prefix}(.*)/
            props[$1] = val
          end
        end
        props
      end
    
      # Get YAML properties. For a directory, these are stored in meta.yml,
      # for a file, they are stored at the beginning of the file: the first line
      # will be "---" and the YAML will end before a line containing "..."
      def yaml_properties
        if directory?
          yaml_path = File.join(@path, 'meta.yml')
          repos.stat(yaml_path, revision) ?
            YAML.load(self.class.new(@changeset, yaml_path).body) :
            {}
        else
          has_yaml_props? ?
            YAML.load(yaml_split[0]) :
            {}
        end
      end
      
      # Determine if file has yaml properties, by checking if the file starts
      # with three leading dashes
      def has_yaml_props?
        file? && data[0][0..2] == "---"
      end
      
      # Split a file between properties and body at a line with three dots.
      # Left trim the body and there may have been blank lines added for
      # clarity.
      def yaml_split
        data[0].gsub!("\r", "")
        ary = data[0].split("\n...\n")
        ary[1] = ary[1].lstrip
        ary
      end

    end
  end
end
   