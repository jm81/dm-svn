# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-svn}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jared Morgan"]
  s.date = %q{2009-07-10}
  s.email = %q{jmorgan@morgancreative.net}
  s.files = [
    ".gitignore",
     "Rakefile",
     "VERSION",
     "lib/dm-svn.rb",
     "lib/dm-svn/config.rb",
     "lib/dm-svn/model.rb",
     "lib/dm-svn/svn.rb",
     "lib/dm-svn/svn/categorized.rb",
     "lib/dm-svn/svn/changeset.rb",
     "lib/dm-svn/svn/node.rb",
     "lib/dm-svn/svn/sync.rb",
     "spec/dm-svn/config_spec.rb",
     "spec/dm-svn/database.yml",
     "spec/dm-svn/fixtures/articles_comments.rb",
     "spec/dm-svn/fixtures/fiction_site.rb",
     "spec/dm-svn/fixtures/news_site.rb",
     "spec/dm-svn/model_spec.rb",
     "spec/dm-svn/spec_helper.rb",
     "spec/dm-svn/svn/categorized_spec.rb",
     "spec/dm-svn/svn/changeset_spec.rb",
     "spec/dm-svn/svn/node_spec.rb",
     "spec/dm-svn/svn/sync_spec.rb",
     "spec/dm-svn/svn_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/jm81/dm-svn}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Sync content from a Subversion repository to a DataMapper model}
  s.test_files = [
    "spec/dm-svn/config_spec.rb",
     "spec/dm-svn/fixtures/articles_comments.rb",
     "spec/dm-svn/fixtures/fiction_site.rb",
     "spec/dm-svn/fixtures/news_site.rb",
     "spec/dm-svn/model_spec.rb",
     "spec/dm-svn/spec_helper.rb",
     "spec/dm-svn/svn/categorized_spec.rb",
     "spec/dm-svn/svn/changeset_spec.rb",
     "spec/dm-svn/svn/node_spec.rb",
     "spec/dm-svn/svn/sync_spec.rb",
     "spec/dm-svn/svn_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, [">= 0"])
      s.add_runtime_dependency(%q<dm-aggregates>, [">= 0"])
      s.add_runtime_dependency(%q<dm-validations>, [">= 0"])
      s.add_runtime_dependency(%q<jm81-svn-fixture>, [">= 0.1.1"])
    else
      s.add_dependency(%q<dm-core>, [">= 0"])
      s.add_dependency(%q<dm-aggregates>, [">= 0"])
      s.add_dependency(%q<dm-validations>, [">= 0"])
      s.add_dependency(%q<jm81-svn-fixture>, [">= 0.1.1"])
    end
  else
    s.add_dependency(%q<dm-core>, [">= 0"])
    s.add_dependency(%q<dm-aggregates>, [">= 0"])
    s.add_dependency(%q<dm-validations>, [">= 0"])
    s.add_dependency(%q<jm81-svn-fixture>, [">= 0.1.1"])
  end
end
