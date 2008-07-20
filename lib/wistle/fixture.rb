require "fileutils"
require "svn/core"
require "svn/fs"
require "svn/repos"

module Wistle
  module Fixture
    
    def self.svn_time(val)
      if val.respond_to?(:strftime)
        return val.strftime("%Y-%m-%dT%H:%M:%S.000000Z")
      end
      return val
    end
    
    class Repository
      @@repositories = {}
      BASE_PATH = ::File.dirname(__FILE__) + "/tmp/"
      
      attr_reader :repos, :ctx, :wc_path
      
      class << self
        def get(name)
          @@repositories[name] ||= Repository.new(name)
        end
      end  
      
      def initialize(name)
        @name = name
        @repos_path = BASE_PATH + 'repo_' + name
        @wc_path = BASE_PATH + 'wc_' + name
        @revisions = []
      end
      
      def revision(name, msg, options = {}, &block)
        @revisions << Revision.new(self, name, msg, options, &block)
      end
      
      # Partly based on setup_repository method from
      # http://svn.collab.net/repos/svn/trunk/subversion/bindings/swig/ruby/test/util.rb
      def create
        FileUtils.rm_rf(@repos_path)
        FileUtils.rm_rf(@wc_path)
        FileUtils.mkdir_p(@repos_path)
        FileUtils.mkdir_p(@wc_path)
        ::Svn::Repos.create(@repos_path)
        @repos = ::Svn::Repos.open(@repos_path)
  
        # Setup context and working copy
        @repos_uri = "file://" + ::File.expand_path(@repos_path)
        @ctx = ::Svn::Client::Context.new
   
        # I don't understand the auth_baton and log_baton, so I set them here,
        # then use revision properties.
        @ctx.add_username_prompt_provider(0) do |cred, realm, username, may_save|
           cred.username = "ANON"
        end
        @ctx.set_log_msg_func {|items| [true, ""]}
        
        @ctx.checkout(@repos_uri, @wc_path)
        self
      end
  
      def commit(to_commit = nil)
        to_commit = @revisions if to_commit.nil?
        to_commit = [to_commit] if (!to_commit.respond_to?(:each) || to_commit.kind_of?(String))
        
        to_commit.each do | rev |
          rev = @revisions.find{ |r| r.name == rev } unless rev.kind_of?(Revision)
          rev.commit
        end
      end
      
    end
  
    class Revision
      attr_reader :name
      
      def initialize(repo, name, message = "", options = {}, &block)
        @repo, @name, @message, @block = repo, name, message, block
        @author = options.delete(:author)
        @time = Fixture::svn_time(options.delete(:date))
        @root = Directory.new(@repo, @repo.wc_path)
      end
      
      def commit
        @root.instance_eval(&@block)
        ci = @repo.ctx.ci(@repo.wc_path)
        if ci # Ensure something changed
          rev = ci.revision
          @repo.repos.fs.set_prop('svn:log', @message, rev) if @message
          @repo.repos.fs.set_prop('svn:author', @author, rev) if @author
          @repo.repos.fs.set_prop('svn:date', @time, rev) if @time
        else
          puts "Warning: No change in revision #{name} (Wistle::Fixture::Revision#commit)"
        end
        return true
      end
    end
    
    class Directory
      def initialize(repo, path)
        @repo = repo
        @path = path + "/"
      end
      
      def dir(name, &block)
        path = @path + name
        unless ::File.directory?(path)
          FileUtils.mkdir_p(path)
          @repo.ctx.add(path)
        end
        d = Directory.new(@repo, path)
        d.instance_eval(&block) if block_given?
      end
      
      def file(name, &block)
        path = @path + name
        unless ::File.file?(path)
          FileUtils.touch(path)
          @repo.ctx.add(path)
        end
        f = File.new(@repo, path)
        f.instance_eval(&block) if block_given?
      end
      
      def move(from, to)
        @repo.ctx.mv(@path + from, @path + to)
      end
      
      def copy(from, to)
        @repo.ctx.cp(@path + from, @path + to)
      end
      
      def delete(name)
        @repo.ctx.delete(@path + name)
      end
      
      def prop(name, value)
        @repo.ctx.propset(name, Fixture::svn_time(value), @path)
      end
    end
    
    class File
      def initialize(repo, path)
        @repo, @path = repo, path
      end
      
      def prop(name, value)
        @repo.ctx.propset(name, Fixture::svn_time(value), @path)
      end
      
      def body(val)
        ::File.open(@path, 'w') { |f| f.write(val) }
      end
    end
  end
end

def svn_repo(name, &block)
  r = Wistle::Fixture::Repository.get(name)
  r.instance_eval(&block) if block_given?
  r
end
