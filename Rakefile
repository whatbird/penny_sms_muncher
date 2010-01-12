require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "penny_sms_muncher"
    gem.summary = %Q{A little bit of code to make PennySMS XML requests.}
    gem.description = %Q{A little bit of code to make PennySMS XML requests. But not JSON requests right now.}
    gem.email = "chris@whatbirdthings.com"
    gem.homepage = "http://github.com/whatbird/penny_sms_muncher"
    gem.authors = ["chris A", "Matthew Shanley"]
  
    gem.add_development_dependency "rspec", ">= 1.2.9"

    gem.add_dependency('addressable', '>= 2.1.1')
    gem.add_dependency('libxml-ruby', '>= 1.1.3')
  
  
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "penny_sms_muncher #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
