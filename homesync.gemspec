# encoding: utf-8

$:.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'homesync/version'

Gem::Specification.new do |s|
  s.name         = "homesync"
  s.version      = HomeSync::VERSION
  s.authors      = ["Laszlo Bacsi"]
  s.email        = "lackac@icanscale.com"
  s.homepage     = "http://github.com/lackac/homesync"
  s.summary      = "HomeSync helps you synchronize your files with other machines through Dropbox."
  s.description  = <<-EOH
HomeSync makes it easy to synchronize any file under your home directory
with other machines through Dropbox by providing a simple commandline
interface for adding and removing symlinks to your files. Furthermore,
it knows how to handle several key directories correctly and how to
synchronize application preferences and data.
  EOH

  s.files        = Dir['bin/*','lib/**/*','spec/**/*'] + %w(README.md LICENSE Gemfile Gemfile.lock)
  s.executables  = %w(homesync)
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = 'nowarning'
  s.required_rubygems_version = '>= 1.3.6'

  s.add_runtime_dependency "thor", "~> 0.14.0"
  s.add_development_dependency "rspec", "~> 2.0.0.beta.22"
end
