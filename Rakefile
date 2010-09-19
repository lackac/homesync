# encoding: utf-8
$:.unshift File.expand_path("lib", File.dirname(__FILE__))

require 'rubygems'
require 'rubygems/specification'

def gemspec
  @gemspec ||= begin
    file = File.expand_path('homesync.gemspec', File.dirname(__FILE__))
    eval(File.read(file), binding, file)
  end
end

task :default => :spec

begin
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts  = %w(-c -fp)
  end

rescue LoadError
  task :spec do
    abort "Run `gem install rspec` to be able to run specs"
  end
end

begin
  require 'rake/gempackagetask'
rescue LoadError
  task(:gem) { $stderr.puts '`gem install rake` to package gems' }
else
  Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.gem_spec = gemspec
  end
  task :gem => [:gemspec]
end

task :install => :repackage do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end
