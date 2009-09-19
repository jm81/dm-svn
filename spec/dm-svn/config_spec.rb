require 'spec_helper'

describe DmSvn::Config do
  before(:each) do
    @c = DmSvn::Config.new
  end
  
  it "should initialize @body_property to 'body'" do
    @c.body_property.should == 'body'
  end

  it "should modify @body_property" do
    @c.body_property = 'contents'
    @c.body_property.should == 'contents'
  end
  
  it "should initialize @property_prefix to 'ws:'" do
    @c.property_prefix.should == 'ws:'
  end
  
  it "should initialize @extension to 'txt'" do
    @c.extension.should == 'txt'
  end
  
  it "should load config options from database.yml" do
    Merb = Object.new
    def Merb.root
      '/path/to/merb'
    end
    
    def Merb.env(*args)
      :test
    end
    
    f = "#{Merb.root}/config/database.yml"
    yaml = File.read(File.dirname(__FILE__) + '/database.yml')
    IO.should_receive(:read).with(f).and_return(yaml)
 
    c = DmSvn::Config.new
    c.username.should == 'login'
    c.password.should == 'pw1234'
    c.extension.should == 'doc'
    c.body_property.should == 'body' # Didn't change
    Object.__send__(:remove_const, :Merb)
  end
  
  after(:all) do
    # ensure this happens
    Object.__send__(:remove_const, :Merb) if Object.const_defined?(:Merb)
  end
end
