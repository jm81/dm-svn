# Update to Wistle::Svn to make it "Site-aware"

module SiteSvn
end

%w{sync changeset}.each do |f|
  require File.dirname(__FILE__) + "/site_svn/#{f}.rb"
end
